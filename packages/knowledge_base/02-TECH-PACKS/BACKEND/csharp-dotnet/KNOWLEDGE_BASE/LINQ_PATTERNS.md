# 💎 LINQ Patterns: Manipulación Declarativa de Datos

> **LINQ:** Language Integrated Query
> **Scope:** Colecciones en memoria + LINQ to Entities (DB)
> **Filosofía:** Functional Programming dentro de C#
> **Date:** 30 de Enero de 2026

LINQ es la respuesta de C# a "¿cómo hago que trabajar con datos sea elegante?". La respuesta: hazlo declarativo, no imperativo.

---

## 📖 Table of Contents

1. [Query vs Method Syntax](#query-vs-method-syntax)
2. [Operadores Principales](#operadores-principales)
3. [Deferred Execution](#deferred-execution)
4. [Proyecciones (Select)](#proyecciones-select)
5. [Joins y Grouping](#joins-y-grouping)
6. [Anti-Patterns](#anti-patterns)

---

## Query vs Method Syntax

### Query Syntax (SQL-like)

```csharp
// ✅ Legible para analistas SQL
var result = from user in users
             where user.Age > 18
             orderby user.Name
             select user.Email;
```

### Method Syntax (Lambdas Fluent)

```csharp
// ✅ Moderno, composable (SoftArchitect prefiere esto)
var result = users
    .Where(u => u.Age > 18)
    .OrderBy(u => u.Name)
    .Select(u => u.Email)
    .ToList();
```

### Equivalencia Exacta

```csharp
// ❌ BAD: Imperativo (bucles manuales)
var adults = new List<string>();
foreach (var user in users) {
    if (user.Age > 18) {
        adults.Add(user.Email);
    }
}

// ✅ GOOD: Declarativo (LINQ)
var adults = users
    .Where(u => u.Age > 18)
    .Select(u => u.Email)
    .ToList();

// Ambos producen el mismo resultado, pero el 2do es:
// 1. Menos código
// 2. Más legible
// 3. Más fácil de testear
// 4. Más fácil de encadenar operaciones
```

---

## Operadores Principales

### Filtering

```csharp
// Where: Filtrar por condición
var adults = users.Where(u => u.Age >= 18);

// OfType: Filtrar por tipo (cast seguro)
var adminUsers = users.OfType<AdminUser>();

// Distinct: Eliminar duplicados
var uniqueEmails = users.Select(u => u.Email).Distinct();

// Skip & Take: Paginación
var page2 = users.Skip(10).Take(10);  // Items 11-20
```

### Sorting

```csharp
// OrderBy: Ascendente
users.OrderBy(u => u.Name)

// OrderByDescending: Descendente
users.OrderByDescending(u => u.CreatedAt)

// ThenBy: Ordenamiento secundario
users
    .OrderBy(u => u.Department)
    .ThenBy(u => u.Name)
    .ToList()
```

### Aggregation

```csharp
// Count: Contar elementos
int totalUsers = users.Count();
int adults = users.Count(u => u.Age >= 18);

// Sum, Average, Min, Max
decimal totalSpent = orders.Sum(o => o.Amount);
double avgAge = users.Average(u => u.Age);
int youngest = users.Min(u => u.Age);

// FirstOrDefault: Primero (o null)
var first = users.FirstOrDefault();
var firstAdult = users.FirstOrDefault(u => u.Age >= 18);

// SingleOrDefault: Exactamente uno (o null)
var singleAdmin = users.FirstOrDefault(u => u.Role == "Admin");

// Any: ¿Existe alguno?
bool hasAdults = users.Any(u => u.Age >= 18);

// All: ¿Todos cumplen?
bool allAdults = users.All(u => u.Age >= 18);
```

---

## Deferred Execution

### La Clave: Queries No se Ejecutan hasta Materializarse

```csharp
// ✅ GOOD: Deferred execution
IEnumerable<User> query = users
    .Where(u => u.Age >= 18)
    .OrderBy(u => u.Name);

// La query NO se ejecuta aquí
// Pero si cambias `users` ahora, la query verá los cambios nuevos

var results = query.ToList();  // ← AQUÍ se ejecuta

// ✅ GOOD: Con LINQ to Entities (Database)
var dbQuery = context.Users
    .Where(u => u.Age >= 18)
    .OrderBy(u => u.Name);

// No hay query SQL aún

var results = await dbQuery.ToListAsync();  // ← AQUÍ se ejecuta SQL
```

### Implicaciones

```csharp
// ❌ BAD: Materializar demasiado pronto
var allUsers = context.Users.ToList();  // ← Trae TODO

// Luego filtrar en memoria (lento)
var adults = allUsers.Where(u => u.Age >= 18).ToList();

// ✅ GOOD: Filtrar EN LA BASE DE DATOS
var adults = context.Users
    .Where(u => u.Age >= 18)
    .ToListAsync();  // ← SQL con WHERE cláusula
```

---

## Proyecciones (Select)

### Select Simple

```csharp
// Transformar cada elemento
var names = users.Select(u => u.Name).ToList();

// Proyectar a DTO
var dtos = users
    .Select(u => new UserDto {
        Id = u.Id,
        Name = u.Name,
        Email = u.Email
    })
    .ToList();

// O con records (más conciso)
var dtos = users
    .Select(u => new UserDto(u.Id, u.Name, u.Email))
    .ToList();
```

### SelectMany (Flatmap)

```csharp
// ✅ Aplanar listas anidadas
public record User {
    public string Name { get; set; }
    public List<Order> Orders { get; set; }
}

// Traer TODOS los orders de TODOS los users
var allOrders = users
    .SelectMany(u => u.Orders)
    .ToList();

// Traer orders CON el nombre del usuario
var ordersWithUserName = users
    .SelectMany(
        u => u.Orders,
        (user, order) => new {
            UserName = user.Name,
            OrderId = order.Id,
            Amount = order.Amount
        }
    )
    .ToList();
```

### Proyectar Solo Lo Necesario (Performance)

```csharp
// ❌ BAD: Traer todo de la DB
var users = context.Users
    .ToList();  // ← Trae todos los campos

// Luego filtrar en memoria
var result = users
    .Select(u => new { u.Name, u.Email })
    .ToList();

// ✅ GOOD: Proyectar ANTES de materializare
var result = context.Users
    .Select(u => new { u.Name, u.Email })
    .ToListAsync();  // ← SQL SELECT Name, Email
```

---

## Joins y Grouping

### Inner Join

```csharp
// ✅ Sintaxis LINQ
var result = users
    .Join(
        orders,
        user => user.Id,              // Foreign key en users
        order => order.UserId,        // Foreign key en orders
        (user, order) => new {
            UserName = user.Name,
            OrderAmount = order.Amount
        }
    )
    .ToList();

// O con query syntax
var result = from user in users
             join order in orders on user.Id equals order.UserId
             select new {
                 UserName = user.Name,
                 OrderAmount = order.Amount
             };

// Con LINQ to Entities (automatic SQL JOIN)
var result = context.Users
    .Include(u => u.Orders)  // LEFT JOIN
    .Select(u => new {
        UserName = u.Name,
        OrderCount = u.Orders.Count
    })
    .ToListAsync();
```

### Group By

```csharp
// Agrupar por departamento
var byDepartment = users
    .GroupBy(u => u.Department)
    .Select(g => new {
        Department = g.Key,
        Count = g.Count(),
        AvgSalary = g.Average(u => u.Salary)
    })
    .ToList();

// Resultado:
// { Department: "IT", Count: 5, AvgSalary: 85000 }
// { Department: "HR", Count: 2, AvgSalary: 60000 }
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: N+1 Query

```csharp
// ❌ BAD: Un query por usuario
var users = context.Users.ToList();  // 1 query

foreach (var user in users) {
    var orders = context.Orders
        .Where(o => o.UserId == user.Id)
        .ToList();  // ← N queries más

    // Total: 1 + N queries
}

// ✅ GOOD: Una query (JOIN)
var users = context.Users
    .Include(u => u.Orders)  // LEFT JOIN
    .ToListAsync();  // ← 1 query

// O con Select (projection)
var result = context.Users
    .Select(u => new {
        User = u,
        OrderCount = u.Orders.Count
    })
    .ToListAsync();  // ← 1 query
```

### ❌ ANTI-PATTERN 2: Materializar Antes de Filtrar

```csharp
// ❌ BAD: Traer todo, filtrar en memoria
var allUsers = context.Users
    .ToList();  // ← Millones de registros en RAM

var adults = allUsers
    .Where(u => u.Age >= 18)  // ← En memoria
    .ToList();

// ✅ GOOD: Filtrar en la base de datos
var adults = context.Users
    .Where(u => u.Age >= 18)  // ← SQL WHERE
    .ToListAsync();
```

### ❌ ANTI-PATTERN 3: Ejecutar Queries en Bucles

```csharp
// ❌ BAD: Query dentro de loop
foreach (var userId in userIds) {
    var user = context.Users
        .FirstOrDefault(u => u.Id == userId);  // ← N queries
}

// ✅ GOOD: Una query con IN
var users = context.Users
    .Where(u => userIds.Contains(u.Id))  // ← SELECT ... WHERE Id IN (...)
    .ToListAsync();
```

### ❌ ANTI-PATTERN 4: Usar .Count() para Verificar Existencia

```csharp
// ❌ BAD: Contar para verificar
if (users.Count(u => u.Age >= 18) > 0) {
    // ...
}  // ← Cuenta TODOS (innecesario)

// ✅ GOOD: Usar Any()
if (users.Any(u => u.Age >= 18)) {
    // ...
}  // ← Para apenas encuentra uno, retorna
```

---

## Checklist: LINQ Bien Formado

```bash
# ✅ 1. Sintaxis
[ ] Usar Method Syntax (lambdas) por defecto
[ ] Query Syntax solo si es significativamente más legible
[ ] No mezclar sintaxis en el mismo método

# ✅ 2. Performance
[ ] Filtrar ANTES de materializar (.ToList())
[ ] Proyectar solo campos necesarios (SELECT)
[ ] Usar .Any() en lugar de .Count() > 0

# ✅ 3. EF Core
[ ] .Include() para relaciones (LEFT JOIN)
[ ] .Select() para proyecciones
[ ] .AsNoTracking() para read-only

# ✅ 4. Composition
[ ] Dividir queries complejas en métodos
[ ] Usar extension methods para consultas comunes
[ ] IEnumerable para composición, IAsyncEnumerable para async

# ✅ 5. Anti-patterns
[ ] NO N+1 queries (Include o Select)
[ ] NO materializar antes de filtrar
[ ] NO queries dentro de bucles
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ LINQ MASTERY READY
**Responsable:** ArchitectZero AI Agent
