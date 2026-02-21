# 🔴 Redis Caching Patterns: High-Speed Data Access

> **Rol:** Cache de Datos en Memoria (Key-Value)
> **Motor:** Almacenamiento Datos Volátil (RAM)
> **Goal:** Reducir latencia de DB (100ms → 1ms)
> **Filosofía:** "La caché es un espejo, no la fuente de verdad. Si se rompe, vuelves a la DB"
> **Status:** ✅ Establecido
> **Date:** 30/01/2026

---

## 📖 Table of Contents

1. [Fundamental: Caché NO es Base de Datos](#fundamental-caché-no-es-base-de-datos)
2. [Cache-Aside Pattern (Recomendado)](#cache-aside-pattern-recomendado)
3. [Write-Through Pattern](#write-through-pattern)
4. [Write-Behind Pattern](#write-behind-pattern)
5. [TTL Strategies](#ttl-strategies)
6. [Problema: Hot Keys](#problema-hot-keys)
7. [Problema: Cache Stampede](#problema-cache-stampede)
8. [Keys Naming Convention](#keys-naming-convention)
9. [Serialización: JSON vs MessagePack](#serialización-json-vs-messagepack)
10. [Redis Pub/Sub vs Streams](#redis-pubsub-vs-streams)
11. [Monitoreo y Troubleshooting](#monitoreo-y-troubleshooting)

---

## Fundamental: Caché NO es Base de Datos

### La Regla de Oro

**Redis es VOLÁTIL.** Puede perder todos los datos en cualquier momento:
- Reinicio del servidor
- OOM (Out of Memory) - evicción de claves
- Failure del nodo

```
🚨 NUNCA hagas esto:

❌ INCORRECTO
CREATE TABLE events (
    id SERIAL PRIMARY KEY
);

App -> Redis (guardar)
App -> Intenta leer de Redis
❌ Redis está caído
❌ Eventos perdidos

✅ CORRECTO
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    created_at TIMESTAMP
);

App -> PostgreSQL (guardar primero)
App -> Redis (cache opcional)
App -> Intenta leer
   ✅ Redis hit: Devuelve desde caché (rápido)
   ❌ Redis miss: Lee de DB, llena caché (lento pero funciona)
```

### Architecture Típica

```
┌──────────────┐
│  Application │
└──────┬───────┘
       │
   ┌───┴────────────────┐
   │                    │
   ↓                    ↓
┌──────────────┐   ┌──────────────┐
│   Redis      │   │  PostgreSQL  │
│  (Caché)     │   │  (Verdad)    │
└──────────────┘   └──────────────┘

Regla:
- ✅ Leer de Redis primero
- ✅ Si miss, leer de DB
- ✅ Guardar SIEMPRE en DB primero
- ✅ Actualizar caché (o invalidar)
```

---

## Cache-Aside Pattern (Recomendado)

### Patrón Estándar en SoftArchitect

La aplicación es responsable de leer/escribir en caché. Redis es pasivo.

### Flujo de Lectura (Get)

```python
def get_user(user_id: int) -> User:
    cache_key = f"users:{user_id}:profile"

    # Paso 1: Buscar en caché
    cached = redis.get(cache_key)
    if cached:
        return User.parse_obj(json.loads(cached))  # ✅ Hit (1ms)

    # Paso 2: Cache miss → Leer de DB
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None  # 404

    # Paso 3: Guardar en caché con TTL
    redis.setex(
        cache_key,
        ttl=3600,  # 1 hora
        value=json.dumps(user.dict())
    )

    return user  # ~100ms (lectura DB)
```

**Resultado:**
- Hit rate 90%: Latencia promedio ≈ 1ms × 0.9 + 100ms × 0.1 = **10ms** ✅
- Hit rate 50%: Latencia promedio = 1ms × 0.5 + 100ms × 0.5 = **50ms** ⚠️

### Flujo de Escritura (Set)

```python
def update_user(user_id: int, data: UserUpdate):
    # Paso 1: Actualizar en DB primero (verdad)
    user = db.query(User).filter(User.id == user_id).first()
    for field, value in data.dict(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()

    # Paso 2: INVALIDAR caché (borrar, no actualizar)
    cache_key = f"users:{user_id}:profile"
    redis.delete(cache_key)  # ✅ Borrar es más seguro que actualizar

    return user
```

**¿Por qué BORRAR y no ACTUALIZAR?**

```
Escenario: Race condition con actualización

❌ Si actualizas el caché:
T1: API recibe request "cambiar email"
T2: DB actualiza email a "nuevo@example.com"
T3: Caché se actualiza a "nuevo@example.com"
T4: Pero en T1.5 llegó otra request del mismo usuario
T5: Lee caché ("nuevo@example.com") pero DB tiene "viejo@example.com"
🚨 Inconsistencia!

✅ Si borras el caché:
T1: API recibe request "cambiar email"
T2: DB actualiza email a "nuevo@example.com"
T3: Caché se borra
T4: Siguiente lectura = miss → lee DB ("nuevo@example.com")
T5: Caché se llena con valor correcto
✅ Siempre consistente!
```

---

## Write-Through Pattern

### Más Seguro pero Más Lento

Escribir SIMULTANEAMENTE en caché y DB. Esperar respuesta de ambos.

```python
def write_through_update(user_id: int, data: UserUpdate):
    cache_key = f"users:{user_id}:profile"

    # Paso 1: Actualizar DB
    user = db.query(User).filter(User.id == user_id).first()
    for field, value in data.dict(exclude_unset=True).items():
        setattr(user, field, value)
    db.commit()

    # Paso 2: Actualizar caché (mismo valor que DB)
    redis.setex(
        cache_key,
        ttl=3600,
        value=json.dumps(user.dict())
    )

    # Note: Esperar a que ambos terminen
    return user
```

**Ventaja:**
- ✅ Caché siempre está actualizado
- ✅ No hay penalidad en el siguiente read (siempre hit)

**Desventaja:**
- ❌ Más lento (esperar caché + DB)
- ❌ Si Redis falla, escritura falla

### Cuándo Usar

```
Usar Write-Through si:
- Escrituras son raras (ej: cambio de perfil usuario)
- Datos críticos (no puedes perder o desincronizar)
- Baja latencia aceptable en escritura (~50-100ms)

Usar Cache-Aside si:
- Escrituras son frecuentes (ej: logs, métricas)
- Datos no críticos
- Baja latencia en escritura es crítico (~10ms)
```

---

## Write-Behind Pattern

### ⚠️ Riesgoso: Write-Behind = Write to Cache, Async Write to DB

```python
def write_behind_dangerous(user_id: int, data: UserUpdate) -> User:
    cache_key = f"users:{user_id}:profile"

    # Paso 1: Escribir SOLO en caché (rápido)
    user_dict = {"id": user_id, **data.dict()}
    redis.setex(cache_key, ttl=3600, value=json.dumps(user_dict))

    # Paso 2: ASINCRONAMENTE escribir en DB (en background)
    background_job_queue.enqueue(
        task=write_to_db,
        user_id=user_id,
        data=data
    )

    # Devolver inmediatamente (ultra-rápido)
    return User(**user_dict)
```

**Ventaja:**
- ⚡ Ultra-rápido (no esperar DB)
- ✅ Latencia < 5ms

**Desventaja:**
- 🚨 **MUY RIESGOSO**: Si Redis falla antes de escribir en DB → datos perdidos
- 🚨 Inconsistencias temporales
- 🚨 Difícil de debuggear

**Regla:** Usar SOLO para datos no críticos (logs, analytics, telemetría).

```python
# ✅ OK para uso no crítico
def log_user_action_write_behind(user_id: int, action: str):
    redis.lpush(f"events:queue", json.dumps({"user_id": user_id, "action": action}))
    # Background worker escribe en DB eventualmente
    # Si pierde algunos events, no es catastrófico

# ❌ NO para datos críticos
def charge_payment_write_behind(user_id: int, amount: float):
    # ❌ NUNCA hacer esto: dinero perdido = demanda legal
    pass
```

---

## TTL Strategies

### Regla: NUNCA guardar sin TTL (a menos que sea inmutable)

```sql
-- ❌ INCORRECTO: Sin TTL
SET users:100:profile '{"name": "Alice", "age": 30}'

-- Redis nunca borra. Si tienes 1M usuarios → RAM llena → 💥 OOM

-- ✅ CORRECTO: Con TTL
SETEX users:100:profile 3600 '{"name": "Alice", "age": 30}'

-- Redis borra automáticamente después de 3600 segundos
```

### Estrategia por Tipo de Dato

| Tipo de Dato | TTL Recomendado | Justificación |
|:---|:---|:---|
| **User Profile** | 1-6 horas | Cambios raros, datos estables |
| **Session Token** | 30 días | Expiración de sesión |
| **Cotización de Acciones** | 1-5 minutos | Datos volátiles, actualizan frecuente |
| **Conteo de Vistas** | 24 horas | Agregación, baja frecuencia |
| **Producto en Catálogo** | 1 hora | Cambios ocasionales |
| **Configuration App** | 12 horas | Muy estable |
| **OTP (One-Time Pass)** | 10 minutos | Crítico, tiempo limitado |

### Implementación en FastAPI + Redis

```python
from redis import Redis
from datetime import timedelta
import json

redis = Redis(host='localhost', port=6379, db=0)

async def cache_with_ttl(key: str, value: any, ttl_seconds: int = 3600):
    """Guardar en caché con TTL automático"""
    redis.setex(
        key,
        time=ttl_seconds,
        value=json.dumps(value, default=str)
    )

async def get_cached_or_db(key: str, ttl: int, db_fetch_fn):
    """Patrón Cache-Aside con TTL"""
    # Buscar en caché
    cached = redis.get(key)
    if cached:
        return json.loads(cached)

    # Miss: ir a DB
    data = await db_fetch_fn()

    # Guardar con TTL
    await cache_with_ttl(key, data, ttl)
    return data

# Uso
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    return await get_cached_or_db(
        key=f"users:{user_id}",
        ttl=3600,  # 1 hora
        db_fetch_fn=lambda: db.query(User).filter(User.id == user_id).first()
    )
```

---

## Problema: Hot Keys

### ¿Qué es un Hot Key?

Una única clave accedida por **cientos o miles de requests/segundo**.

```
Ejemplo: Black Friday, producto "MacBook Pro" 50% off

Key: products:123456:hot_item
Acceso normal: 10 requests/segundo
Durante venta: 10,000 requests/segundo

❌ Problema:
- Single Redis node puede saturarse
- Network bandwidth agotada
- Redis devuelve lentamente
- Usuarios ven timeout
```

### Solución 1: Replicar Caché Localmente

```python
from functools import lru_cache
from datetime import datetime, timedelta

class LocalCache:
    def __init__(self):
        self.cache = {}
        self.expire = {}

    def get(self, key: str):
        if key in self.cache:
            if self.expire[key] > datetime.now():
                return self.cache[key]
            else:
                del self.cache[key]  # Expirado
        return None

    def set(self, key: str, value, ttl_seconds: int):
        self.cache[key] = value
        self.expire[key] = datetime.now() + timedelta(seconds=ttl_seconds)

local_cache = LocalCache()

async def get_hot_product(product_id: int):
    # Paso 1: Caché local (en memoria, muy rápido)
    local_value = local_cache.get(f"products:{product_id}")
    if local_value:
        return local_value  # ~0.1ms (sin network)

    # Paso 2: Redis (si local miss)
    redis_value = redis.get(f"products:{product_id}")
    if redis_value:
        # Llenar caché local
        local_cache.set(f"products:{product_id}", redis_value, ttl=60)
        return redis_value  # ~10ms

    # Paso 3: DB (si Redis miss)
    db_value = db.query(Product).filter(Product.id == product_id).first()
    # Llenar Redis y local
    redis.setex(f"products:{product_id}", 3600, json.dumps(db_value.dict()))
    local_cache.set(f"products:{product_id}", db_value, ttl=3600)
    return db_value  # ~100ms
```

### Solución 2: Sharding

Distribuir hot keys entre múltiples Redis nodes.

```python
def get_shard_id(key: str, num_shards: int) -> int:
    """Determinar qué shard (Redis node) usar"""
    return hash(key) % num_shards

# Redis nodes
redis_shards = [
    Redis(host='redis-1', port=6379),
    Redis(host='redis-2', port=6379),
    Redis(host='redis-3', port=6379),
]

def get_from_cache(key: str):
    shard_id = get_shard_id(key, len(redis_shards))
    redis_node = redis_shards[shard_id]
    return redis_node.get(key)

# Distribución:
# products:123456 → hash → shard 0
# products:123457 → hash → shard 1
# products:123458 → hash → shard 2
# Carga distribuida ✅
```

---

## Problema: Cache Stampede

### ¿Qué es?

Multiple procesos intentan refrescar la misma caché expirada simultáneamente → **todos van a DB** → sobrecarga.

```
Timeline:

10:00:00 - Caché se expira
10:00:01 - 1000 requests llegan simultáneamente
10:00:01 - TODOS ven cache miss
10:00:01 - TODOS van a DB
10:00:01 - DB recibe 1000 queries de golpe 💥
10:00:05 - DB se satura, timeout
```

### Solución: Distributed Lock

```python
import asyncio
from redis import Redis

redis = Redis(host='localhost', port=6379)

async def get_with_lock(key: str, ttl: int, db_fetch_fn):
    """Cache-Aside con lock distribuido para evitar cache stampede"""

    # Paso 1: Buscar en caché
    cached = redis.get(key)
    if cached:
        return json.loads(cached)

    # Paso 2: Lock (evitar que otros procesos vayan a DB)
    lock_key = f"{key}:lock"
    lock = redis.lock(lock_key, timeout=10)  # Lock por 10 segundos max

    if lock.acquire(blocking=False):  # Non-blocking
        try:
            # Paso 3: Yo obtuve el lock, ir a DB
            data = await db_fetch_fn()

            # Paso 4: Guardar en caché
            redis.setex(key, ttl, json.dumps(data, default=str))

            return data
        finally:
            lock.release()
    else:
        # Paso 5: Otro proceso tiene el lock, esperar y reintentar
        for i in range(50):  # Esperar max 5 segundos (50 × 100ms)
            await asyncio.sleep(0.1)
            cached = redis.get(key)
            if cached:
                return json.loads(cached)

        # Si todavía no hay caché, ir a DB de todas formas
        return await db_fetch_fn()

# Resultado: Solo 1 de 1000 requests va a DB 🎯
```

**Resultado:**
- Sin lock: 1000 queries a DB 💥
- Con lock: 1 query a DB ✅ (99.9% reducción)

---

## Keys Naming Convention

### Estándar: Namespace con Dos Puntos

```
Formato: <namespace>:<entity_type>:<entity_id>:<attribute>

Examples:

users:100:profile              # Perfil de usuario 100
users:100:settings            # Preferencias de usuario 100
auth:tokens:abc123xyz         # Token de autenticación
sessions:sid:xyz              # Sesión
cache:products:list:page:1    # Producto lista paginada

cache:reports:sales:monthly:2026-01  # Reporte mensual

inventory:warehouse:001:stock  # Stock en almacén 1
```

### Ventajas

```python
# 1. Fácil de entender
key = "users:100:profile"  # Claro: usuario 100, su perfil

# 2. Fácil de agrupar (con SCAN)
redis.scan_iter("users:*")  # Todas las claves de usuarios
redis.scan_iter("users:100:*")  # Todas las claves del usuario 100

# 3. Invalidar grupos
redis.delete("users:100:*")  # Borrar todo del usuario 100

# 4. Monitoreo y debugging
redis_cli> KEYS "cache:*"  # Ver todas las claves de caché
```

---

## Serialización: JSON vs MessagePack

### JSON (Defecto, Legible)

```python
import json

# Ventajas
# ✅ Legible en CLI
# ✅ Compatible con cualquier lenguaje
# ✅ Fácil debuggear

redis.set("users:100", json.dumps({"name": "Alice", "age": 30}))
redis_cli> GET users:100
# Resultado: {"name":"Alice","age":30}  ✅ Legible

# Desventajas
# ❌ Más lento (parsing texto)
# ❌ Más tamaño (más bytes)
```

### MessagePack (Rápido, Compacto)

```python
import msgpack

# Ventajas
# ✅ 2-3x más rápido que JSON
# ✅ 30-40% más pequeño
# ✅ Ideal para caché con mucho volumen

data = {"name": "Alice", "age": 30}
packed = msgpack.packb(data)

redis.set("users:100", packed)
# Resultado: bytes (no legible en CLI)

unpacked = msgpack.unpackb(redis.get("users:100"))
# Resultado: {"name": "Alice", "age": 30} ✅

# Desventajas
# ❌ No legible directamente
# ❌ Necesita librería
```

### Recomendación

```
Usa JSON si:
- Datos pequeños (<1KB)
- Debugging es importante
- Compatible con múltiples lenguajes

Usa MessagePack si:
- Alto volumen (>100K claves)
- Datos frecuentemente accedidos
- Preocupación por RAM
```

---

## Redis Pub/Sub vs Streams

### Pub/Sub: Fire-and-Forget (Efímero)

```python
# Publicador
redis.publish("notifications", json.dumps({
    "user_id": 100,
    "message": "Tu pedido fue enviado"
}))

# Suscriptor
pubsub = redis.pubsub()
pubsub.subscribe("notifications")

for message in pubsub.listen():
    if message['type'] == 'message':
        data = json.loads(message['data'])
        print(f"Notificación: {data['message']}")
```

**Features:**
- ✅ Rápido (fire-and-forget)
- ❌ No persistente (si suscriptor no está, pierde mensaje)
- ✅ Ideal para: Websocket broadcasts, real-time updates

### Streams: Cola Persistente (Recomendado)

```python
# Productor
redis.xadd("email-queue", {
    "to": "alice@example.com",
    "subject": "Bienvenido",
    "body": "Gracias por registrarte"
})

# Consumidor
messages = redis.xread({"email-queue": "0"}, count=10)

for stream_key, messages_list in messages:
    for message_id, data in messages_list:
        to_email = data[b'to'].decode()
        send_email(to_email, data)

        # Marcar como procesado
        redis.xack("email-queue", "my_group", message_id)
```

**Features:**
- ✅ Persistente (si consumer falla, reinicia desde último mensaje)
- ✅ Grupos de consumidores (distribución de carga)
- ✅ Ideal para: Colas de trabajos, event sourcing

**Cuándo usar qué:**

| Caso de Uso | Pub/Sub | Streams |
|:---|:---:|:---:|
| Real-time Websocket broadcast | ✅ | ❌ |
| Email queue | ❌ | ✅ |
| Notificaciones push | ❌ | ✅ |
| Métricas en vivo | ✅ | ❌ |
| Worker pool de trabajos | ❌ | ✅ |

---

## Monitoreo y Troubleshooting

### 1. Health Check

```python
from redis import Redis
from redis.exceptions import ConnectionError

def redis_health():
    try:
        redis.ping()
        info = redis.info()
        return {
            "status": "healthy",
            "used_memory_mb": info['used_memory'] / 1024 / 1024,
            "connected_clients": info['connected_clients']
        }
    except ConnectionError:
        return {"status": "down"}

# En FastAPI
@app.get("/health/redis")
async def health():
    return redis_health()
```

### 2. Monitorear RAM

```bash
# Conectar a Redis CLI
redis-cli

# Ver memoria
> INFO memory
used_memory:1073741824  # 1GB
maxmemory:2147483648   # 2GB (límite)
maxmemory_policy:allkeys-lru  # Política de evicción

# Ver claves más grandes
> SCAN 0 COUNT 1000
# Revisar manualmente con SIZE

# Ver acceso por clave
> SLOWLOG GET 10  # Top 10 queries lentas
```

### 3. Hit Rate

```python
def redis_stats():
    info = redis.info()

    hits = info.get('keyspace_hits', 0)
    misses = info.get('keyspace_misses', 0)

    if hits + misses == 0:
        hit_rate = 0
    else:
        hit_rate = 100 * hits / (hits + misses)

    return {
        "hit_rate_percent": hit_rate,
        "hits": hits,
        "misses": misses
    }

# Target: > 80% hit rate
# Si < 60%, revisar TTL, tamaño de caché
```

### 4. Evitar OOM (Out of Memory)

```
Configurar en redis.conf:

# Máxima memoria permitida
maxmemory 2gb

# Política de evicción cuando llena:
# allkeys-lru: Borrar cualquier clave LRU (recomendado)
# volatile-lru: Borrar clave con TTL LRU
# noeviction: Error (rechazar nuevas escrituras)
maxmemory-policy allkeys-lru
```

---

## Resumen: Patterns de Caché en SoftArchitect

| Patrón | Lectura | Escritura | Consistencia | Riesgo | Recomendación |
|:---|:---|:---|:---|:---|:---|
| **Cache-Aside** | ⚡⚡⚡ | ⚡⚡ | Media | Bajo | ✅ **ESTÁNDAR** |
| **Write-Through** | ⚡⚡⚡ | ⚡ | Alta | Bajo | ⚠️ Datos críticos |
| **Write-Behind** | ⚡⚡⚡ | ⚡⚡⚡ | Baja | Alto | ❌ Datos no críticos |

**Goal:** Cache-Aside con:
- ✅ TTL por tipo de dato
- ✅ Local cache para hot keys
- ✅ Distributed lock para cache stampede
- ✅ > 80% hit rate
- ✅ < 1GB RAM para caché típico

Latencia objetivo: **P95 < 50ms** (redis hit + DB miss) 🚀

---

## Ejemplo Completo: FastAPI + Redis

```python
from fastapi import FastAPI, HTTPException
from redis import Redis
from sqlalchemy import create_engine, Column, Integer, String
from sqlalchemy.orm import sessionmaker, declarative_base
import json

app = FastAPI()
redis = Redis(host='localhost', port=6379, db=0)

Base = declarative_base()
engine = create_engine("postgresql://localhost/mydb")
SessionLocal = sessionmaker(bind=engine)

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    name = Column(String)
    email = Column(String)

# Cache-Aside Pattern
@app.get("/users/{user_id}")
async def get_user(user_id: int):
    cache_key = f"users:{user_id}:profile"

    # Step 1: Try cache
    cached = redis.get(cache_key)
    if cached:
        return json.loads(cached)

    # Step 2: Cache miss → DB
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404)

    # Step 3: Fill cache
    redis.setex(
        cache_key,
        3600,  # 1 hour TTL
        json.dumps({"id": user.id, "name": user.name, "email": user.email})
    )

    return {"id": user.id, "name": user.name, "email": user.email}

# Invalidate cache on update
@app.put("/users/{user_id}")
async def update_user(user_id: int, name: str, email: str):
    db = SessionLocal()
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404)

    user.name = name
    user.email = email
    db.commit()

    # Invalidate cache
    redis.delete(f"users:{user_id}:profile")

    return {"id": user.id, "name": user.name, "email": user.email}
```

🔴 **Redis Caché Patterns Completado.** 💾✨
