# 🚀 Django ORM Performance: Query Optimization Masterclass

> **Versión:** Django 4.2+
> **Objetivo:** Evitar N+1 queries y matar la base de datos
> **Métrica:** < 100ms para queries típicas en tablas 1M+
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [El Problema N+1](#el-problema-n1)
2. [select_related: SQL JOIN](#selectrelated-sql-join)
3. [prefetch_related: Python Join](#prefetchrelated-python-join)
4. [only() & defer(): Columnas Selectivas](#only--defer-columnas-selectivas)
5. [Aggregation & Annotation](#aggregation--annotation)
6. [Índices en Django](#índices-en-django)
7. [Query Analysis con EXPLAIN](#query-analysis-con-explain)
8. [Caching con queryset](#caching-con-queryset)

---

## El Problema N+1

### ¿Qué es N+1?

```python
# Query 1: Traer todos los libros
books = Book.objects.all()

# Query N: Para cada libro, traer el autor
for book in books:
    print(book.author.name)  # ❌ Dispara 1 query por libro

# Resultado: 1 query + N queries = N+1 consultas 💥
```

**Ejemplo Real:**
- 1000 libros → 1 query + 1000 queries = **1001 consultas**
- Si cada query toma 5ms → 5 segundos totales = **INACEPTABLE**

### Detectar N+1

```bash
# En Django shell
python manage.py shell

>>> from django.db import connection
>>> connection.queries  # Ver todas las queries
>>> len(connection.queries)  # Contar consultas

# Si esperas 10 queries y ves 100+, tienes N+1
```

---

## select_related: SQL JOIN

### Cuándo Usar

**Usar `select_related` para relaciones Single-Valued (1:1 o FK):**
- `ForeignKey`
- `OneToOneField`

Crea UN **SQL JOIN**, recupera todo en 1 query.

### Ejemplo

```python
# Modelos
class Author(models.Model):
    name = models.CharField(max_length=100)

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)


# ❌ INCORRECTO (N+1)
books = Book.objects.all()
for book in books:
    print(f"{book.title} by {book.author.name}")
# Queries: 1 (books) + 1000 (authors) = 1001 ❌


# ✅ CORRECTO (select_related)
books = Book.objects.select_related('author')
for book in books:
    print(f"{book.title} by {book.author.name}")
# Queries: 1 (LEFT JOIN) ✅


# ✅ MÚLTIPLES NIVELES (nested ForeignKeys)
class Publisher(models.Model):
    name = models.CharField(max_length=100)
    country = models.CharField(max_length=50)

class Author(models.Model):
    name = models.CharField(max_length=100)
    publisher = models.ForeignKey(Publisher, on_delete=models.CASCADE)

class Book(models.Model):
    title = models.CharField(max_length=200)
    author = models.ForeignKey(Author, on_delete=models.CASCADE)

# Traer todo en 1 query (2 JOINS)
books = Book.objects.select_related('author__publisher')
for book in books:
    print(f"{book.title} by {book.author.name} ({book.author.publisher.name})")
# Queries: 1 ✅
```

### SQL Generado

```sql
-- ❌ Sin select_related (N+1)
SELECT * FROM books;  -- Query 1
SELECT * FROM authors WHERE id = 1;  -- Query 2
SELECT * FROM authors WHERE id = 2;  -- Query 3
-- ... (1000 veces)

-- ✅ Con select_related
SELECT books.*, authors.*
FROM books
LEFT JOIN authors ON books.author_id = authors.id;
-- Query única
```

---

## prefetch_related: Python Join

### Cuándo Usar

**Usar `prefetch_related` para relaciones Multi-Valued (N:N, Reverse FK):**
- `ManyToManyField`
- Reverse relations (`book_set`)

Django hace **2 queries separadas** y las une en memoria con Python.

### Ejemplo

```python
# Modelos
class Author(models.Model):
    name = models.CharField(max_length=100)

class Book(models.Model):
    title = models.CharField(max_length=200)
    authors = models.ManyToManyField(Author, related_name='books')


# ❌ INCORRECTO (N+1)
authors = Author.objects.all()
for author in authors:
    book_count = author.books.count()  # 1 query por autor
    print(f"{author.name}: {book_count} books")
# Queries: 1 (authors) + 1000 (counts) = 1001 ❌


# ✅ CORRECTO (prefetch_related)
authors = Author.objects.prefetch_related('books')
for author in authors:
    book_count = author.books.count()  # Usa caché en memoria
    print(f"{author.name}: {book_count} books")
# Queries: 1 (authors) + 1 (books) = 2 ✅


# ✅ MÚLTIPLES PREFETCHES
authors = Author.objects.prefetch_related(
    'books',           # Todos los libros de cada autor
    'books__publisher' # El publisher de cada libro
)
```

### SQL Generado

```sql
-- ✅ Con prefetch_related
SELECT * FROM authors;  -- Query 1
SELECT * FROM books_authors
WHERE author_id IN (1, 2, 3, ...);  -- Query 2
-- Luego Python une los resultados en memoria
```

### Prefetch vs Select

| Relación | Tipo | Herramienta | SQL |
|:---|:---|:---|:---|
| FK, O2O | 1:1 | `select_related` | JOIN |
| ManyToMany | N:N | `prefetch_related` | 2 queries + Python |
| Reverse FK | 1:N | `prefetch_related` | 2 queries + Python |

---

## only() & defer(): Columnas Selectivas

### only(): Traer Solo Ciertas Columnas

```python
# ❌ INCORRECTO: Trae todas las columnas (incluyendo bio gigante)
user = User.objects.get(id=1)  # Trae id, name, email, bio (100KB)

# ✅ CORRECTO: Solo trae lo que necesitas
user = User.objects.only('id', 'name', 'email').get(id=1)
print(user.name)  # ✅ Acceso rápido

# ❌ Acceder a columna no traída dispara otra query
print(user.bio)  # ❌ 1 query extra (Lazy loading)
```

### defer(): Lo Opuesto - Excluir Columnas

```python
# Si la tabla tiene 50 columnas pero solo 2 son gigantes

# ✅ CORRECTO: Excluir bio y media_blob
users = User.objects.defer('bio', 'media_blob')
print(users[0].name)  # ✅ Rápido (no trae bio)
```

### Cuándo Usar

```python
# ✅ USAR only() si:
# - Tabla tiene muchas columnas (>20)
# - Algunas columnas son enormes (TEXT, BLOB)
# - Queries frecuentes solo necesitan 2-3 campos

users = User.objects.only('id', 'email').filter(active=True)

# ❌ NO USAR si:
# - Vas a acceder la mayoría de los campos igual
# - La tabla tiene <10 columnas
```

---

## Aggregation & Annotation

### Aggregation: Estadísticas Simples

```python
from django.db.models import Count, Avg, Max

# COUNT
total_books = Book.objects.count()

# AVERAGE PRICE
avg_price = Book.objects.aggregate(Avg('price'))
# Resultado: {'price__avg': 15.99}

# MÚLTIPLES AGREGACIONES
stats = Book.objects.aggregate(
    count=Count('id'),
    avg_price=Avg('price'),
    max_price=Max('price')
)
# Resultado: {'count': 1000, 'avg_price': 15.99, 'max_price': 99.99}
```

**Query SQL generado:**
```sql
SELECT COUNT(*), AVG(price), MAX(price) FROM books;
-- 1 query, resultado en 1ms
```

### Annotation: Agregación por Grupo

```python
from django.db.models import Count

# Contar libros por autor
authors = Author.objects.annotate(
    book_count=Count('books')
).order_by('-book_count')

for author in authors:
    print(f"{author.name}: {author.book_count} books")

# SQL generado:
# SELECT authors.*, COUNT(books.id) as book_count
# FROM authors
# LEFT JOIN books ON authors.id = books.author_id
# GROUP BY authors.id
# ORDER BY book_count DESC
```

### Filtrar Después de Annotate

```python
# Autores con >5 libros
prolific_authors = Author.objects.annotate(
    book_count=Count('books')
).filter(book_count__gt=5)

# ⚠️ CUIDADO: Usar Q para lógica compleja
from django.db.models import Q

authors = Author.objects.annotate(
    book_count=Count('books')
).filter(
    Q(book_count__gt=10) | Q(name__startswith='J')
)
```

---

## Índices en Django

### Definir Índices en el Modelo

```python
class Product(models.Model):
    name = models.CharField(max_length=100)
    sku = models.CharField(max_length=50)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    category = models.ForeignKey(Category, on_delete=models.CASCADE)

    class Meta:
        # Índice en columna única
        indexes = [
            models.Index(fields=['sku'], name='idx_sku'),

            # Índice compuesto
            models.Index(fields=['category', '-price'], name='idx_category_price'),

            # Índice condicional
            models.Index(
                fields=['price'],
                condition=Q(is_active=True),
                name='idx_active_price'
            ),
        ]
```

### Aplicar Índices

```bash
# Crear migración
python manage.py makemigrations

# Aplicar a la BD
python manage.py migrate
```

---

## Query Analysis con EXPLAIN

### Ver el Plan de Ejecución

```python
from django.db import connection
from django.test.utils import CaptureQueriesContext

# Opción 1: Ver queries en consola
from django.conf import settings
settings.DEBUG = True

users = User.objects.all()
for query in connection.queries:
    print(query['sql'])


# Opción 2: Usar CaptureQueriesContext
with CaptureQueriesContext() as context:
    books = Book.objects.select_related('author').all()
    print(f"Queries ejecutadas: {len(context)}")
    for query in context:
        print(query['sql'])
```

### Interpretar Lentitud

```python
# ❌ LENTO: Sin índice en WHERE
books = Book.objects.filter(title__icontains='Django')

# ✅ RÁPIDO: Con índice
class Book(models.Model):
    title = models.CharField(max_length=200, db_index=True)
```

---

## Caching con Queryset

### Queryset Caching (Automático)

```python
# Iteración 1: Ejecuta query
books = Book.objects.all()
for book in books:
    print(book.title)

# Iteración 2: USA CACHÉ (sin query)
for book in books:
    print(book.title)
```

### Evitar Recachos

```python
# ❌ INCORRECTO: Nueva query cada vez
for i in range(3):
    print(Book.objects.count())  # 3 queries

# ✅ CORRECTO: Cachear el valor
book_count = Book.objects.count()  # 1 query
for i in range(3):
    print(book_count)  # Sin queries extra
```

---

## Resumen: Optimización Step-by-Step

### Checklist de Performance

```python
# 1. Detectar N+1
from django.db import connection
queries_before = len(connection.queries)

books = Book.objects.all()
for book in books:
    print(book.author.name)

queries_after = len(connection.queries)
print(f"Queries: {queries_after - queries_before}")  # Si > 100, tienes N+1

# 2. Aplicar select_related o prefetch_related
books = Book.objects.select_related('author')  # FK → select_related
authors = Author.objects.prefetch_related('books')  # M2M → prefetch_related

# 3. Usar only() si tablas son grandes
users = User.objects.only('id', 'email', 'name')

# 4. Crear índices en columnas de queries frecuentes
class Meta:
    indexes = [models.Index(fields=['email'])]

# 5. Monitorear con Django Debug Toolbar
# pip install django-debug-toolbar
```

---

## Benchmark Real

```python
# Tabla: 100,000 libros, 1,000 autores

# ❌ N+1 Problem
books = Book.objects.all()
for book in books:
    print(book.author.name)
# Tiempo: 1001 queries × 5ms = 5 segundos ❌

# ✅ select_related
books = Book.objects.select_related('author')
for book in books:
    print(book.author.name)
# Tiempo: 1 query × 100ms = 100ms ✅

# MEJORA: 50x MÁS RÁPIDO 🚀
```

Django ORM optimizado = bases de datos felices. 🏃‍♂️⚡
