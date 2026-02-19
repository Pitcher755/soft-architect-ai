# 🐘 PostgreSQL JSONB Patterns: Hybrid SQL/NoSQL

> **Version:** PostgreSQL 14+
> **Tipo:** JSON Binary (Indexable, Queryable)
> **Caso de Uso:** Datos semi-estructurados, atributos dinámicos, metadatos variables
> **Filosofía:** "Best of Both Worlds" - Integridad Relacional + Flexibilidad NoSQL
> **Status:** ✅ Establecido
> **Date:** 30/01/2026

---

## 📖 Table of Contents

1. [Visión PostgreSQL Híbrida](#visión-postgresql-híbrida)
2. [JSONB vs JSON vs Tabla Relacional](#jsonb-vs-json-vs-tabla-relacional)
3. [Estructura de Tabla Híbrida](#estructura-de-tabla-híbrida)
4. [Indexación GIN (Generalized Inverted Index)](#indexación-gin)
5. [Query Patterns & Operators](#query-patterns--operators)
6. [Performance & Best Practices](#performance--best-practices)
7. [Casos de Uso Reales](#casos-de-uso-reales)
8. [Migración desde MongoDB](#migración-desde-mongodb)

---

## Visión PostgreSQL Híbrida

PostgreSQL 14+ no es solo una base de datos relacional. Con JSONB nativo, es también una **base de datos documental tipo MongoDB** pero con las garantías ACID de SQL.

### ¿Por qué no usar solo MongoDB?

| Aspecto | PostgreSQL + JSONB | MongoDB |
|:---|:---|:---|
| **Foreign Keys** | ✅ Sí | ❌ No (application-level) |
| **Transactions ACID** | ✅ Sí (Serializable) | ⚠️ Sí (desde 4.0, limitado) |
| **Joins** | ✅ Sí (relacional) | ❌ No ($lookup, subóptimo) |
| **Schema Evolution** | ✅ Flexible (JSONB) | ✅ Flexible (default) |
| **Cost** | ✅ Open Source | ⚠️ Caro en cloud |
| **Indexes** | ✅ GIN (rápidos) | ⚠️ BTree (menos flexible) |

**Conclusion:** Usa PostgreSQL + JSONB cuando necesites tanto **relaciones** como **flexibilidad**.

---

## JSONB vs JSON vs Tabla Relacional

### 1. JSON vs JSONB

```sql
-- JSON: Texto puro (lento en queries, sin índices)
CREATE TABLE logs_json (
    id SERIAL,
    metadata JSON NOT NULL
);

-- JSONB: Binario comprimido (indexable, queryable, más rápido)
CREATE TABLE logs_jsonb (
    id SERIAL,
    metadata JSONB NOT NULL
);

-- JSONB es siempre la opción correcta.
-- JSON solo si necesitas preservar orden de claves (raro).
```

**Benchmark (Query pequeño):**
- JSON: ~5ms (sin índice, full scan)
- JSONB + índice: ~0.5ms (GIN index)

### 2. Cuándo usar JSONB vs Tabla Relacional

**Usa Tabla Relacional cuando:**
- Datos centrales del dominio (ej: `Users`, `Orders`, `Products`)
- Necesitas Foreign Keys, constraints
- Queries muy frecuentes sobre ese campo
- Múltiples joins sobre el campo

```sql
-- ✅ CORRECTO: Tabla relacional
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL
);
```

**Usa JSONB cuando:**
- Atributos dinámicos o variables entre registros
- Metadatos que cambian frecuentemente
- Datos semi-estructurados
- Configuraciones por usuario/producto

```sql
-- ✅ CORRECTO: JSONB para atributos dinámicos
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    attributes JSONB NOT NULL  -- Color, talla, peso, etc (varían por producto)
);

-- Producto 1
INSERT INTO products (sku, name, attributes) VALUES (
    'SHIRT-001',
    'T-Shirt Red',
    '{"color": "red", "size": "XL", "material": "cotton", "weight_g": 180}'
);

-- Producto 2
INSERT INTO products (sku, name, attributes) VALUES (
    'CHAIR-001',
    'Office Chair',
    '{"color": "black", "legs": 5, "adjustable_height": true, "max_weight_kg": 120}'
);
-- Note: Campos completamente diferentes, pero en la misma tabla.
```

---

## Estructura de Tabla Híbrida

El patrón estándar: **Núcleo Relacional + Periferia Flexible**.

```sql
-- Patrón: Core Relational + Flexible JSONB

CREATE TABLE products (
    -- Relacional: PK, búsquedas frecuentes, joins
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    category_id INTEGER NOT NULL REFERENCES categories(id),
    created_at TIMESTAMP DEFAULT NOW(),

    -- JSONB: Todo lo flexible
    attributes JSONB NOT NULL DEFAULT '{}',
    metadata JSONB NOT NULL DEFAULT '{}'
);

-- Indexes estratégicos
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_sku ON products(sku);

-- ✅ GIN Index en JSONB (permite queries rápidas)
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);
CREATE INDEX idx_products_metadata ON products USING GIN (metadata);
```

**Ventajas:**
- PK, Foreign Keys, Constraints en columnas relacional
- Escalabilidad de esquema con JSONB
- Búsquedas rápidas en ambos lados

---

## Indexación GIN

Sin índice en JSONB = Full Table Scan. Con índice GIN = Acceso O(log N).

### Crear Indexes

```sql
-- 1. Índice en todo el documento JSONB
CREATE INDEX idx_attributes_all ON products USING GIN (attributes);

-- 2. Índice en una clave específica (operador ->)
CREATE INDEX idx_attributes_color ON products USING GIN ((attributes->'color'));

-- 3. Índice con operator class (búsquedas específicas)
CREATE INDEX idx_attributes_containment ON products USING GIN (
    attributes jsonb_ops  -- @> operator support
);

-- 4. Índice en array dentro de JSONB
CREATE INDEX idx_attributes_tags ON products USING GIN ((attributes->'tags'));
```

### Verificar Indexes

```sql
-- Ver índices creados
SELECT indexname, indexdef FROM pg_indexes
WHERE tablename = 'products' AND indexname LIKE 'idx_attributes%';

-- Verificar si un índice es usado (analizar query)
EXPLAIN ANALYZE
SELECT * FROM products WHERE attributes @> '{"color": "red"}';
-- Buscar en el plan: "Index Scan" o "Bitmap Index Scan" (bueno)
-- Evitar: "Seq Scan" (malo para JSONB sin índice)
```

---

## Query Patterns & Operators

### 1. Operador `@>` (Contiene)

```sql
-- Encuentra productos con color="red"
SELECT * FROM products
WHERE attributes @> '{"color": "red"}';

-- Encuentra productos con múltiples propiedades
SELECT * FROM products
WHERE attributes @> '{"color": "red", "material": "cotton"}';

-- ✅ Usa GIN index automaticamente (rápido)
```

### 2. Operador `->` y `->>` (Extrae valores)

```sql
-- -> devuelve JSONB (para más queries)
SELECT id, attributes->'color' AS color_json
FROM products;

-- ->> devuelve TEXT (para visualización)
SELECT id, attributes->>'color' AS color_text
FROM products;

-- Acceso nested
SELECT attributes->'specs'->'weight_g' AS weight_json
FROM products;

SELECT attributes->>'specs'->>'weight_g' AS weight_text
FROM products;
```

### 3. Operador `?` (Existe clave)

```sql
-- Encuentra productos que tienen la clave "warranty"
SELECT * FROM products
WHERE attributes ? 'warranty';

-- Encuentra productos que tengan "color" O "size"
SELECT * FROM products
WHERE attributes ?| ARRAY['color', 'size'];

-- Encuentra productos que tengan "color" Y "size"
SELECT * FROM products
WHERE attributes ?& ARRAY['color', 'size'];
```

### 4. Unpack JSONB a Filas (Unnest)

```sql
-- Convierte array JSON en filas SQL
-- Si attributes = {tags: ["red", "cotton", "mens"]}
SELECT id, jsonb_array_elements_text(attributes->'tags') as tag
FROM products;

-- Resultado:
-- id | tag
-- 1  | red
-- 1  | cotton
-- 1  | mens

-- ✅ Útil para: Joins entre tablas y arrays JSONB
SELECT p.id, p.name, tag
FROM products p,
     jsonb_array_elements_text(attributes->'tags') as tag
WHERE tag = 'red';
```

### 5. Funciones de Transformación

```sql
-- jsonb_set: Actualizar una clave sin reescribir todo el JSON
UPDATE products
SET attributes = jsonb_set(attributes, '{color}', '"blue"')
WHERE id = 1;

-- jsonb_insert: Insertar en array
UPDATE products
SET attributes = jsonb_insert(attributes, '{tags,0}', '"premium"')
WHERE id = 1;

-- jsonb_agg: Agregar múltiples JSONB en un array
SELECT category_id, jsonb_agg(attributes) as all_attributes
FROM products
GROUP BY category_id;

-- jsonb_object_agg: Crear objeto a partir de columnas
SELECT jsonb_object_agg(sku, attributes) as product_map
FROM products;
```

---

## Performance & Best Practices

### 1. ¿Cuándo Desnormalizar?

**Desnormalizar (incluir en JSONB) si:**
- Campo nunca cambia (o cambia raramente)
- No necesitas joinear ese dato
- La clave es secundaria

```sql
-- ✅ CORRECTO: Desnormalizar metadata inmutable
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id),
    created_at TIMESTAMP,
    shipping_address JSONB NOT NULL,  -- Inmutable (snapshots)
    billing_address JSONB NOT NULL    -- Inmutable
);
```

**NO Desnormalizar (usar Foreign Key) si:**
- Datos cambian frecuentemente
- Necesitas joins
- Datos centrales del dominio

```sql
-- ❌ INCORRECTO: Desnormalizar datos que cambian
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_data JSONB NOT NULL  -- ❌ Si user_data cambia, ¿actualizar todos los orders?
);

-- ✅ CORRECTO:
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id)  -- FK, datos siempre actualizados
);
```

### 2. Límite de Tamaño

```sql
-- Mantener JSONB pequeño (<1KB es ideal, <10KB aceptable)
-- Si attributes crece mucho, separar en tabla relacional

-- ❌ INCORRECTO: Almacenar todo en un JSONB gigante
attributes: {
    "all_history": [...1000 items...],
    "all_comments": [...5000 items...]
}

-- ✅ CORRECTO: Separar en tabla relacional para historial
CREATE TABLE product_history (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    change_type VARCHAR(50),
    changed_at TIMESTAMP
);
```

### 3. Validación de Estructura

```sql
-- Crear constraint para validar estructura JSONB
ALTER TABLE products
ADD CONSTRAINT check_attributes_structure CHECK (
    -- Verificar que attributes tiene claves esperadas
    (attributes ? 'color')
    AND (attributes ? 'size')
    OR (attributes IS NULL)  -- O puede ser NULL
);

-- O usar esquema JSON formal (PG 15+)
CREATE TABLE products_strict (
    id SERIAL PRIMARY KEY,
    attributes JSONB NOT NULL
        CHECK (
            attributes IS JSON SCHEMA '{
                "type": "object",
                "properties": {
                    "color": {"type": "string"},
                    "size": {"enum": ["XS", "S", "M", "L", "XL"]},
                    "weight_g": {"type": "number"}
                },
                "required": ["color", "size"]
            }'
        )
);
```

### 4. Estrategia de Indexación

```sql
-- ❌ Evitar: Índice en JSONB muy grande (>100MB)
-- ✅ Estrategia selectiva:

-- Para búsquedas frecuentes, índice en clave específica
CREATE INDEX idx_attr_color ON products USING GIN ((attributes->'color'));

-- Para metadatos raros, sin índice (económico)
-- (solo @> cuando sea necesario)

-- Monitorear tamaño de índice
SELECT pg_size_pretty(pg_relation_size('idx_attr_color'));
```

---

## Casos de Uso Reales

### Caso 1: E-commerce Product Catalog

```sql
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE,
    name VARCHAR(100),
    category_id INTEGER REFERENCES categories(id),
    price DECIMAL(10, 2),

    -- JSONB para atributos dinámicos por categoría
    attributes JSONB NOT NULL DEFAULT '{}',

    created_at TIMESTAMP DEFAULT NOW()
);

-- Ropa
INSERT INTO products (sku, name, category_id, attributes) VALUES (
    'SHIRT-001', 'T-Shirt',
    1,  -- categoria_ropa
    '{"color": "red", "size": "M", "material": "100% cotton", "care": "wash cold"}'
);

-- Electrónica
INSERT INTO products (sku, name, category_id, attributes) VALUES (
    'LAPTOP-001', 'MacBook Pro',
    2,  -- categoria_electronics
    '{"processor": "M3", "ram_gb": 16, "storage_gb": 512, "warranty_months": 12}'
);

-- Query múltiple
SELECT p.*, a.color, a.processor
FROM products p
LEFT JOIN LATERAL (
    SELECT attributes->>'color' as color, attributes->>'processor' as processor
    FROM (SELECT attributes) AS json_data
) a ON true
WHERE p.category_id IN (1, 2);
```

### Caso 2: User Settings & Preferences

```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100),

    -- Preferencias dinámicas por usuario
    preferences JSONB NOT NULL DEFAULT '{"theme": "light", "notifications": true}',

    created_at TIMESTAMP DEFAULT NOW()
);

-- Actualizar preferencia sin reescribir todo
UPDATE users
SET preferences = jsonb_set(preferences, '{theme}', '"dark"')
WHERE id = 1;

-- Buscar usuarios con tema oscuro
SELECT * FROM users WHERE preferences->>'theme' = 'dark';
```

### Caso 3: Event Sourcing / Audit Log

```sql
CREATE TABLE audit_log (
    id SERIAL PRIMARY KEY,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    action VARCHAR(20),  -- INSERT, UPDATE, DELETE

    -- JSONB para datos antes y después
    before_state JSONB,
    after_state JSONB,

    changed_by INTEGER REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT NOW()
);

-- Query: Ver todos los cambios de un producto
SELECT * FROM audit_log
WHERE entity_type = 'product' AND entity_id = 123
ORDER BY changed_at DESC;

-- Query: Encontrar cambios de precio (before != after)
SELECT id, before_state->>'price', after_state->>'price'
FROM audit_log
WHERE entity_type = 'product'
  AND before_state->>'price' != after_state->>'price';
```

---

## Migración desde MongoDB

Si vienes de MongoDB y necesitas PostgreSQL:

### Paso 1: Importar MongoDB JSON a PostgreSQL

```bash
# Exportar de MongoDB
mongoexport --db mydb --collection products --out products.jsonl

# Importar a PostgreSQL (usando COPY o cliente)
psql -c "COPY products(attributes) FROM STDIN" < products.jsonl
```

### Paso 2: Crear Indexes

```sql
-- Después de la migración, crear índices GIN
CREATE INDEX idx_products_attributes ON products USING GIN (attributes);

-- Analizar performance
ANALYZE products;
```

### Paso 3: Validar Integridad

```sql
-- Buscar documentos con estructura inconsistente
SELECT id, attributes
FROM products
WHERE NOT (attributes ? 'name' AND attributes ? 'sku');
```

---

## Resumen: Cuándo Usar Postgres + JSONB

| Situación | Postgres + JSONB | MongoDB | Decision |
|:---|:---:|:---:|:---|
| Datos estructurados + flexibles | ✅ | ✅ | **Postgres** (ACID) |
| Escalamiento horizontal | ⚠️ | ✅ | **MongoDB** (sharding nativo) |
| Relaciones complejas | ✅ | ⚠️ | **Postgres** (joins, FK) |
| Operacional de bajo costo | ✅ | ⚠️ | **Postgres** (open source) |
| Prototipado rápido | ⚠️ | ✅ | **MongoDB** (schema-less) |

**Recomendación SoftArchitect:** Postgres + JSONB es la opción estándar para **95% de aplicaciones**. Cambiar a MongoDB solo si necesitas sharding horizontal o no tienes restricciones de costo. 🐘💾
