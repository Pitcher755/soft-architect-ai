# 🐬 MySQL Indexing & Performance Strategy

> **Motor:** InnoDB (Default, innodb_file_per_table)
> **Estructura:** B-Tree (default, optimizado para range queries)
> **Goal:** Queries < 50ms en tablas con 1M+ filas
> **Filosofía:** "Indexes son una inversión - cada índice tiene costo en INSERT/UPDATE"
> **Status:** ✅ Establecido
> **Date:** 30/01/2026

---

## 📖 Table of Contents

1. [Fundamentos de Indexación](#fundamentos-de-indexación)
2. [Tipos de Indexes en MySQL](#tipos-de-índices-en-mysql)
3. [Clustered Index (Clave Primaria)](#clustered-index-clave-primaria)
4. [Secondary Indexes (B-Tree)](#secondary-indexes-b-tree)
5. [Covering Index (El Truco Maestro)](#covering-index-el-truco-maestro)
6. [Multi-Column Indexes](#multi-column-indexes)
7. [El Comando EXPLAIN](#el-comando-explain)
8. [Anti-patterns y Errores Comunes](#anti-patterns-y-errores-comunes)
9. [Monitoreo y Mantenimiento](#monitoreo-y-mantenimiento)

---

## Fundamentos de Indexación

### ¿Cómo funciona un B-Tree?

Un índice B-Tree es como un **árbol de búsqueda balanceado**. Sin índice:

```
SELECT * FROM users WHERE email = 'alice@example.com';

❌ Sin índice: Leer TODAS las filas (Full Table Scan)
┌─────┬──────────────────────┬─────┐
│ id  │ email                │ ... │
├─────┼──────────────────────┼─────┤
│ 1   │ bob@example.com      │     │  ← No es
│ 2   │ charlie@example.com  │     │  ← No es
│ 3   │ diana@example.com    │     │  ← No es
│ 4   │ alice@example.com    │     │  ← ¡Encontrado!
│ ... │ ... (1M más filas)   │     │  ← Leer todo
└─────┴──────────────────────┴─────┘

Tiempo: O(n) = 1 millón de comparaciones = ⏱️ 5 segundos
```

**Con índice B-Tree:**

```
CREATE INDEX idx_email ON users(email);

✅ Con índice: Búsqueda logarítmica
       [B-Tree Index]
              root
             /    \
          a-m     n-z
          / \     / \
        ...  ...  ... alice@...  ← Directo (O(log n))

Tiempo: O(log n) = ~20 comparaciones = ⏱️ 1ms
```

### Costo de Indexes

**Todo tiene precio:**

```sql
-- ✅ LECTURA (SELECT): Más rápida (índice)
-- ❌ ESCRITURA (INSERT, UPDATE, DELETE): Más lenta (actualizar índice)

INSERT INTO users (id, name, email) VALUES (100, 'Eve', 'eve@example.com');
-- Sin índices: Escribir 1 fila = 1 operación
-- Con 5 índices: Escribir 1 fila + actualizar 5 índices = 6 operaciones

-- ❌ MEMORIA: Cada índice ocupa espacio en disco + RAM
-- Un índice en una tabla de 1GB puede ocupar 200-300MB
```

**Regla:** Indexa solo columnas usadas frecuentemente en `WHERE`, `JOIN`, `ORDER BY`.

---

## Tipos de Indexes en MySQL

### 1. **BTREE** (Defecto, recomendado)
- Balanceado, eficiente para range queries
- Uso: Cualquier columna con valores ordenables

```sql
CREATE INDEX idx_name ON users(name);  -- Implícitamente BTREE
CREATE INDEX idx_age_btree ON users(age) USING BTREE;  -- Explícito
```

### 2. **HASH**
- O(1) para igualdad, NO para ranges
- Motor: Memory (no InnoDB)
- Uso: Raro en producción

```sql
CREATE INDEX idx_hash ON users(email) USING HASH;  -- ❌ No soportado en InnoDB
```

### 3. **FULLTEXT**
- Búsqueda de texto completo (ej: `MATCH ... AGAINST`)
- Uso: Contenido de artículos, descripción de productos

```sql
CREATE FULLTEXT INDEX idx_content ON articles(title, body);

SELECT * FROM articles
WHERE MATCH(title, body) AGAINST('database design' IN BOOLEAN MODE);
```

### 4. **SPATIAL** (R-Tree)
- Coordenadas geográficas, geometría
- Uso: GIS, mapas, geolocalización

```sql
CREATE SPATIAL INDEX idx_location ON restaurants(location);

SELECT * FROM restaurants
WHERE ST_Distance_Sphere(location, POINT(0, 0)) < 5000;  -- < 5km
```

---

## Clustered Index (Clave Primaria)

### La Verdad: En InnoDB, **la tabla ES el Clustered Index**

La clave primaria no es solo un identificador. **Determina el orden físico de los datos en disco.**

```sql
-- ❌ INCORRECTO: UUID sin orden
CREATE TABLE events (
    id CHAR(36) PRIMARY KEY,  -- UUID no ordenado
    created_at TIMESTAMP
);
-- Resultado: Datos esparcidos en disco (random I/O) = Lento

-- ✅ CORRECTO: Autoincremento (ordenado)
CREATE TABLE events (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    created_at TIMESTAMP
);
-- Resultado: Datos secuenciales en disco (sequential I/O) = Rápido

-- ✅ CORRECTO: UUID v7 (tiempo + aleatorio, ordenable)
CREATE TABLE events (
    id CHAR(36) PRIMARY KEY,  -- UUID v7: 2026-01-30-xxx... (ordenado por fecha)
    created_at TIMESTAMP
);
```

**Impacto en Performance:**
- Auto-increment PK: 1ms por insert (sequential I/O)
- UUID sin orden PK: 10-50ms por insert (random I/O, fragmentación)

### Acceso por PK es Ultra-Rápido

```sql
-- ✅ Ultra-rápido: O(1) casi siempre
SELECT * FROM users WHERE id = 123;  -- ~0.1ms

-- ❌ Más lento: O(log n), pero aún rápido
SELECT * FROM users WHERE email = 'alice@example.com';  -- ~1ms (con índice)
```

---

## Secondary Indexes (B-Tree)

Cualquier índice que no sea la PK es **Secondary Index**. Apunta a la PK, no a la fila física.

### Cómo Funciona

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,           -- Clustered Index
    email VARCHAR(100),
    name VARCHAR(100)
);

CREATE INDEX idx_email ON users(email);  -- Secondary Index

SELECT * FROM users WHERE email = 'alice@example.com';

[Flujo de Ejecución]
1. Buscar 'alice@example.com' en idx_email (B-Tree search)
2. Encontrar: id = 42
3. Ir a Clustered Index (tabla) y leer fila completa con id=42
4. Devolver: {id: 42, email: 'alice@example.com', name: 'Alice', ...}

Operaciones: 2 búsquedas B-Tree = ~2ms
```

### Múltiples Indexes = Más Actualizaciones

```sql
-- Supongamos esta tabla con 5 índices
CREATE TABLE products (
    id INT PRIMARY KEY,
    sku VARCHAR(50) UNIQUE,           -- Índice 1
    name VARCHAR(100),
    category_id INT,
    price DECIMAL,
    INDEX idx_category (category_id), -- Índice 2
    INDEX idx_price (price),          -- Índice 3
    INDEX idx_name (name),            -- Índice 4
    UNIQUE KEY idx_sku_cat (sku, category_id)  -- Índice 5
);

-- INSERT una fila
INSERT INTO products VALUES (1, 'A123', 'Widget', 5, 9.99);

-- ¿Qué sucede internamente?
-- 1. Escribir en la tabla (Clustered Index)
-- 2. Actualizar idx_category
-- 3. Actualizar idx_price
-- 4. Actualizar idx_name
-- 5. Actualizar idx_sku_cat
-- Total: 5 operaciones por INSERT

-- Si 1000 INSERTs/sec: 5000 operaciones/sec en índices
-- Costo: Más lento, más carga en disco
```

**Regla de Oro:** Más índices = Lecturas más rápidas, escrituras más lentas. Balance.

---

## Covering Index (El Truco Maestro)

### Concepto: El Índice Contiene TODO

Si el índice tiene **todas las columnas** del SELECT, MySQL **nunca necesita leer la tabla principal** (Lookup Table).

```sql
CREATE TABLE users (
    id INT PRIMARY KEY,
    email VARCHAR(100),
    last_name VARCHAR(100),
    age INT
);

-- Índice COVERING: Contiene todas las columnas del SELECT
CREATE INDEX idx_user_email_covering ON users(email, last_name);

-- ✅ Query 1: COVERING INDEX (Ultra Rápido)
-- El índice ya tiene email y last_name, no necesita ir a la tabla
SELECT email, last_name FROM users WHERE email = 'alice@example.com';
-- Tiempo: ~0.5ms (solo lee el índice)

-- ❌ Query 2: NO COVERING (Más lento)
-- El índice tiene email y last_name, pero falta 'age'
-- MySQL debe leer la tabla principal
SELECT email, last_name, age FROM users WHERE email = 'alice@example.com';
-- Tiempo: ~2ms (lee índice + tabla)
```

### Estrategia Covering Index

```sql
-- Analizar queries frecuentes
-- Query 1: SELECT id, name FROM users WHERE email = ?
-- Query 2: SELECT email FROM users WHERE name = ?

-- ✅ Índice COVERING para Query 1
CREATE INDEX idx_email_covering ON users(email, id, name);
-- Orden: (condición WHERE, luego SELECT columns)

-- ✅ Índice COVERING para Query 2
CREATE INDEX idx_name_covering ON users(name, email);
```

**Ventaja:** Reducir latency de 2-5ms a 0.5ms = **10x más rápido**.

---

## Multi-Column Indexes

El orden de columnas en el índice **importa mucho**.

### Regla: (Igualdad, Rango, Sort)

```sql
-- Patrón de queries típicas
-- WHERE email = ? AND age > ? ORDER BY created_at

CREATE INDEX idx_email_age_created ON users(
    email,         -- 1. Igualdad (WHERE email = ?)
    age,           -- 2. Rango (WHERE age > ?)
    created_at     -- 3. Sort (ORDER BY created_at)
);

-- Flujo de ejecución
SELECT * FROM users
WHERE email = 'alice@example.com' AND age > 25
ORDER BY created_at;

-- MySQL usa el índice así:
-- 1. Buscar email='alice' (eliminar 99%)
-- 2. Entre esos, rango age>25 (eliminar 80%)
-- 3. Ordenar resultado por created_at (lectura secuencial del índice)
-- Resultado: Muy eficiente ✅
```

### Índice INCORRECTO (Orden Equivocado)

```sql
-- ❌ INCORRECTO: Orden aleatorio
CREATE INDEX idx_wrong ON users(age, email, created_at);

-- Si query es: WHERE email = ? AND age > ? ORDER BY created_at
-- MySQL solo puede usar email (no es la primera columna)
-- Pierde eficiencia
```

---

## El Comando EXPLAIN

### Cómo Leer el Plan de Ejecución

```sql
-- ✅ BUENO: EXPLAIN de una query con índice
EXPLAIN
SELECT * FROM users WHERE email = 'alice@example.com';

+----+-------------+-------+------------+------+-------------------------+-------------------------+-------+-------+------+----------+-------+
| id | select_type | table | partitions | type | possible_keys           | key                     | key_len | ref  | rows | filtered | Extra |
+----+-------------+-------+------------+------+-------------------------+-------------------------+-------+-------+------+----------+-------+
| 1  | SIMPLE      | users | NULL       | ref  | idx_email               | idx_email               | 101    | const | 1    | 100.00   | NULL  |
+----+-------------+-------+------------+------+-------------------------+-------------------------+-------+-------+------+----------+-------+

📊 Interpretación:
- type: ref (✅ Bueno, índice usado)
- possible_keys: idx_email (índice candidato)
- key: idx_email (índice elegido)
- rows: 1 (MySQL estima leer 1 fila)
```

### Valores de `type` (De Mejor a Peor)

| type | Descripción | Velocidad |
|:---|:---|:---|
| `system` | 1 fila, tabla sistema | ⚡⚡⚡⚡⚡ |
| `const` | PK o UNIQUE, 1 fila | ⚡⚡⚡⚡ |
| `eq_ref` | JOIN con PK | ⚡⚡⚡ |
| `ref` | Índice no-único | ⚡⚡⚡ |
| `range` | WHERE col > ? | ⚡⚡ |
| `index` | Lectura completa del índice | ⚡ |
| `ALL` | Full table scan ❌ | 🐌 |

### Query Problemas (Red Flags)

```sql
-- ❌ INCORRECTO: Full Table Scan
EXPLAIN
SELECT * FROM users WHERE name LIKE '%alice%';

+----+-----...+------+-------+--------------+
| id | type | rows | Extra            |
+----+-----...+------+-------+--------------+
| 1  | ALL  | 1000000 | Using where   |
+----+-----...+------+-------+--------------+

🚨 Red Flags:
- type: ALL (Full Table Scan)
- rows: 1000000 (leer 1M filas)
- Extra: Using where (filtro en fila completa)

❌ Solución: No hay. LIKE '%...%' no puede usar índice.
```

### Análisis de Índice Covering

```sql
-- ✅ Índice COVERING (ultra-rápido)
EXPLAIN
SELECT email, last_name FROM users WHERE email = 'alice@example.com';

+----+-----...+-------+-----------+
| id | type | Extra         |
+----+-----...+-------+-----------+
| 1  | ref  | Using index   |  ← 🎯 USANDO SOLO EL ÍNDICE
+----+-----...+-------+-----------+

✅ "Using index" = No necesita leer la tabla, solo el índice (10x más rápido)
```

---

## Anti-patterns y Errores Comunes

### Error 1: Indexar Todo

```sql
-- ❌ INCORRECTO: Índice en cada columna
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL,
    category_id INT,
    created_at TIMESTAMP,
    INDEX idx_name (name),          -- Tal vez no necesario
    INDEX idx_description (description),  -- ❌ Texto largo, índice enorme
    INDEX idx_price (price),        -- Tal vez no necesario
    INDEX idx_category (category_id),     -- ✅ Necesario (FK)
    INDEX idx_created (created_at)  -- Tal vez no necesario
);

❌ Problema: 5 índices en 6 columnas
- Escrituras lentas (mantener 5 índices)
- RAM consumida (índices en memoria)
- Mantenimiento complejo

✅ Solución: Solo indexar columnas en WHERE, JOIN, ORDER BY frecuentes
CREATE TABLE products (
    id INT PRIMARY KEY,
    name VARCHAR(100),
    price DECIMAL,
    category_id INT,
    created_at TIMESTAMP,
    INDEX idx_category (category_id),       -- FK
    INDEX idx_price_category (price, category_id)  -- Filtros comunes
);
```

### Error 2: Índice Demasiado Grande

```sql
-- ❌ INCORRECTO: Índice en columna muy larga
CREATE TABLE articles (
    id INT PRIMARY KEY,
    content LONGTEXT,  -- Puede ser 1GB+
    INDEX idx_content (content)  -- ❌ Índice ENORME
);

❌ Problema: Índice puede ser más grande que la tabla
- Lento de crear/mantener
- RAM agotada
- Sin beneficio (LONGTEXT texto libre, no estructurado)

✅ Solución: Usar FULLTEXT si necesitas búsqueda en texto
CREATE TABLE articles (
    id INT PRIMARY KEY,
    title VARCHAR(255),
    content LONGTEXT,
    FULLTEXT INDEX idx_fulltext (title, content)
);

SELECT * FROM articles
WHERE MATCH(title, content) AGAINST('database' IN BOOLEAN MODE);
```

### Error 3: Índice en Columna de Baja Selectividad

```sql
-- ❌ INCORRECTO: Indexar columna con pocos valores únicos
CREATE TABLE users (
    id INT PRIMARY KEY,
    gender ENUM('M', 'F', 'X'),  -- Solo 3 valores distintos
    is_active BOOLEAN,           -- Solo 2 valores distintos
    INDEX idx_gender (gender),   -- ❌ Índice inútil
    INDEX idx_active (is_active) -- ❌ Índice inútil
);

❌ Problema: Selectividad baja = índice no ayuda
- Si 50% de usuarios son 'M' y 50% son 'F'
- Índice no reduce significativamente el conjunto de filas

✅ Solución: Indexar solo columnas con alta selectividad (>90%)
CREATE TABLE users (
    id INT PRIMARY KEY,
    gender ENUM('M', 'F', 'X'),
    is_active BOOLEAN,
    email VARCHAR(100),
    INDEX idx_email (email)  -- ✅ Casi todos únicos (alta selectividad)
);
```

### Error 4: No Usar Índice en JOIN

```sql
-- ❌ INCORRECTO: JOIN sin índice en columna de unión
CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,  -- ❌ Sin índice
    created_at TIMESTAMP
);

SELECT * FROM orders o
JOIN users u ON o.user_id = u.id
WHERE o.created_at > '2026-01-01';

❌ Problema: Join tiene que hacer Full Table Scan en orders
- Si orders tiene 1M filas, leer todas

✅ Solución: Indexar FK y columnas de JOIN
CREATE TABLE orders (
    id INT PRIMARY KEY,
    user_id INT,
    created_at TIMESTAMP,
    INDEX idx_user_id (user_id),  -- ✅ Para JOIN
    INDEX idx_created (created_at)  -- ✅ Para WHERE
);
```

---

## Monitoreo y Mantenimiento

### 1. Ver Indexes de una Tabla

```sql
-- Listar índices
SELECT TABLE_NAME, COLUMN_NAME, INDEX_NAME, NON_UNIQUE
FROM INFORMATION_SCHEMA.STATISTICS
WHERE TABLE_NAME = 'users' AND TABLE_SCHEMA = 'mydb';

+-----------+-------------+------------------+------------+
| table_name | column_name | index_name       | non_unique |
+-----------+-------------+------------------+------------+
| users     | id          | PRIMARY          | 0          |
| users     | email       | idx_email        | 1          |
| users     | created_at  | idx_created      | 1          |
+-----------+-------------+------------------+------------+
```

### 2. Encontrar Indexes Nunca Usados

```sql
-- Indexes que nunca se usan en lecturas
SELECT OBJECT_SCHEMA, OBJECT_NAME, INDEX_NAME
FROM performance_schema.table_io_waits_summary_by_index_usage
WHERE COUNT_READ = 0 AND INDEX_NAME != 'PRIMARY'
ORDER BY COUNT_WRITE DESC;

-- Eliminar índices inútiles
DROP INDEX idx_never_used ON users;
```

### 3. Tamaño de Indexes

```sql
-- Ver tamaño de cada índice
SELECT
    TABLE_NAME,
    INDEX_NAME,
    ROUND(STAT_VALUE * @@innodb_page_size / 1024 / 1024, 2) AS size_mb
FROM mysql.innodb_index_stats
WHERE STAT_NAME = 'size'
ORDER BY STAT_VALUE DESC;

-- Si un índice >100MB, considerar eliminarlo
```

### 4. Fragmentación de Índice

```sql
-- Desfragmentar (rebuild) índice
OPTIMIZE TABLE users;

-- O más selectivo
ALTER TABLE users ENGINE=InnoDB;

-- Después
ANALYZE TABLE users;  -- Actualizar estadísticas
```

---

## Resumen: Estrategia de Indexación SoftArchitect

| Fase | Acción | Indicador |
|:---|:---|:---|
| **1. Diseño** | Indexar PK + FK | `PRIMARY KEY`, `FOREIGN KEY` |
| **2. Queries Frecuentes** | Analizar con EXPLAIN | `type = ref` (buen índice) |
| **3. Covering Indexes** | Si queries pequeños | `Extra = Using index` |
| **4. Monitoreo** | Ver índices no usados | `COUNT_READ = 0` → eliminar |
| **5. Mantenimiento** | Rebuild si fragmentado | `OPTIMIZE TABLE` anual |

**Meta:** Queries < 50ms en tablas 1M+ filas. 🐬💨
