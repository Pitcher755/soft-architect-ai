# 🗄️ Entity Framework Core: ORM Moderno

> **Estándar:** EF Core 8.0+
> **Enfoque:** Code First (Recomendado)
> **Soporte:** SQL Server, PostgreSQL, MySQL, SQLite
> **Date:** 30 de Enero de 2026

El ORM moderno de .NET. Reemplaza Hibernate en el mundo Java. Más limpio, más rápido, mejor tipado.

---

## 📖 Table of Contents

1. [Code First vs Database First](#code-first-vs-database-first)
2. [DbContext & Configuration](#dbcontext--configuración)
3. [Relaciones & Navigation](#relaciones--navigation)
4. [Change Tracking](#change-tracking)
5. [AsNoTracking & Performance](#asnoftracking--performance)
6. [Migraciones](#migraciones)

---

## Code First vs Database First

### Code First (RECOMENDADO)

**Workflow:** Clases C# → Migraciones → Base de Datos

```csharp
// 1. Definir clases (Domain Models)
public class User {
    public int Id { get; set; }
    public string Name { get; set; }
    public string Email { get; set; }

    // Relación
    public List<Order> Orders { get; set; } = [];
}

public class Order {
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public int UserId { get; set; }

    // Navigation property
    public User User { get; set; }
}

// 2. DbContext
public class AppDbContext : DbContext {
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
}

// 3. Crear migración
// dotnet ef migrations add InitialCreate

// 4. Aplicar a base de datos
// dotnet ef database update
```

**Ventajas:**
- ✅ Tipado (compilador verifica cambios)
- ✅ Versionable (migraciones en Git)
- ✅ Testeable (en-memoria con InMemoryDatabase)

### Database First (LEGACY)

**Workflow:** Base de Datos → Scaffolding → Clases C#

```bash
# Para bases de datos existentes (legacy)
dotnet ef dbcontext scaffold "Server=.;Database=MyDB" Microsoft.EntityFrameworkCore.SqlServer -o Models
```

**Desventajas:**
- ❌ Scaffolding regenera clases (pierde customizaciones)
- ❌ Migraciones manuales (propenso a errores)
- ❌ Menos idiómatico en .NET

---

## DbContext & Configuration

### DbContext Básico

```csharp
public class AppDbContext : DbContext {
    // DbSets
    public DbSet<User> Users { get; set; }
    public DbSet<Order> Orders { get; set; }
    public DbSet<Product> Products { get; set; }

    // Constructor
    public AppDbContext(DbContextOptions<AppDbContext> options)
        : base(options) { }

    // Configuration (Fluent API)
    protected override void OnModelCreating(ModelBuilder modelBuilder) {
        // Configurar User
        modelBuilder.Entity<User>()
            .HasKey(u => u.Id);

        modelBuilder.Entity<User>()
            .Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(255);

        modelBuilder.Entity<User>()
            .HasIndex(u => u.Email)
            .IsUnique();

        // Configurar relación
        modelBuilder.Entity<Order>()
            .HasOne(o => o.User)
            .WithMany(u => u.Orders)
            .HasForeignKey(o => o.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
```

### Inyectar en Program.cs

```csharp
var builder = WebApplicationBuilder.CreateBuilder(args);

// ✅ Registrar DbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"))
);

var app = builder.Build();

// ✅ Aplicar migraciones automáticamente
using (var scope = app.Services.CreateScope()) {
    var db = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    db.Database.Migrate();  // Aplica pendientes
}

app.Run();
```

---

## Relaciones & Navigation

### One-to-Many (Usuario → Órdenes)

```csharp
public class User {
    public int Id { get; set; }
    public string Name { get; set; }

    // Navigation property (collection)
    public List<Order> Orders { get; set; } = [];
}

public class Order {
    public int Id { get; set; }
    public decimal Amount { get; set; }
    public int UserId { get; set; }  // Foreign key

    // Navigation property (single)
    public User User { get; set; }
}

// Fluent API (DbContext)
modelBuilder.Entity<Order>()
    .HasOne(o => o.User)
    .WithMany(u => u.Orders)
    .HasForeignKey(o => o.UserId);
```

### Many-to-Many (Usuarios ↔ Roles)

```csharp
public class User {
    public int Id { get; set; }
    public List<UserRole> UserRoles { get; set; } = [];
}

public class Role {
    public int Id { get; set; }
    public List<UserRole> UserRoles { get; set; } = [];
}

// Tabla junction automática
public class UserRole {
    public int UserId { get; set; }
    public int RoleId { get; set; }

    public User User { get; set; }
    public Role Role { get; set; }
}

// Configuration
modelBuilder.Entity<UserRole>()
    .HasKey(ur => new { ur.UserId, ur.RoleId });

modelBuilder.Entity<UserRole>()
    .HasOne(ur => ur.User)
    .WithMany(u => u.UserRoles);

modelBuilder.Entity<UserRole>()
    .HasOne(ur => ur.Role)
    .WithMany(r => r.UserRoles);
```

### One-to-One (Usuario ↔ Perfil)

```csharp
public class User {
    public int Id { get; set; }
    public int ProfileId { get; set; }

    public Profile Profile { get; set; }
}

public class Profile {
    public int Id { get; set; }
    public string Bio { get; set; }
}

// Configuration
modelBuilder.Entity<User>()
    .HasOne(u => u.Profile)
    .WithOne()
    .HasForeignKey<User>(u => u.ProfileId);
```

---

## Change Tracking

### Cómo Funciona

```csharp
using var context = new AppDbContext();

// 1. Cargar un user (estado: Unchanged)
var user = context.Users.First();

// 2. Modificar
user.Name = "Juan";  // Hibernate lo detecta automáticamente

// 3. SaveChanges
await context.SaveChangesAsync();  // ← Genera UPDATE automáticamente
```

### DetectChanges Manual

```csharp
var user = context.Users.First();
user.Name = "Juan";

// EF detecta automáticamente
context.ChangeTracker.DetectChanges();

// O ver cambios
var entries = context.ChangeTracker.Entries();
foreach (var entry in entries) {
    Console.WriteLine($"{entry.Entity.GetType().Name}: {entry.State}");
}
```

### Estados

| Estado | Significado |
|:---|:---|
| **Detached** | No tracked (fuera de contexto) |
| **Unchanged** | Cargar sin cambios |
| **Added** | Nuevo objeto, no persistido |
| **Modified** | Cambios detectados |
| **Deleted** | Marcado para borrar |

---

## AsNoTracking & Performance

### El Problema: Change Tracking es Costoso

```csharp
// ❌ BAD: Traer 10,000 usuarios y EF los trackea
var users = context.Users.ToList();  // Memory spike

// EF crea ChangeTracker para cada uno (overhead)
```

### Solución: AsNoTracking() para Read-Only

```csharp
// ✅ GOOD: Lectura pura (sin tracking)
var users = context.Users
    .AsNoTracking()  // ← No trackear
    .ToList();

// 30% más rápido, sin overhead de tracking
```

### Casos de Uso

```csharp
// ✅ READ-ONLY (Usar AsNoTracking)
public async Task<List<UserDto>> GetActiveUsers() {
    return await context.Users
        .AsNoTracking()
        .Where(u => u.IsActive)
        .Select(u => new UserDto(u.Id, u.Name))
        .ToListAsync();
}

// ✅ WRITE (NO usar AsNoTracking)
public async Task UpdateUser(int id, UserUpdateDto dto) {
    var user = await context.Users.FindAsync(id);  // ← Tracked
    user.Name = dto.Name;
    await context.SaveChangesAsync();  // ← Detecta cambios
}

// ✅ DELETE (Debe estar tracked)
public async Task DeleteUser(int id) {
    var user = await context.Users.FindAsync(id);  // ← Tracked
    context.Users.Remove(user);
    await context.SaveChangesAsync();
}
```

---

## Migraciones

### Crear Migración

```bash
# Crear (genera archivo de migración)
dotnet ef migrations add AddUserTable

# Listar migraciones
dotnet ef migrations list

# Ver SQL que se ejecutará
dotnet ef migrations script

# Ver SQL de una migración específica
dotnet ef migrations script AddUserTable NextMigration
```

### Aplicar Migraciones

```bash
# Aplicar todas las pendientes
dotnet ef database update

# Aplicar hasta una específica
dotnet ef database update AddUserTable

# Revertir una migración
dotnet ef database update PreviousMigration
```

### Ejemplo de Migración Generada

```csharp
public partial class AddUserTable : Migration {
    protected override void Up(MigrationBuilder migrationBuilder) {
        migrationBuilder.CreateTable(
            name: "Users",
            columns: table => new
            {
                Id = table.Column<int>(type: "int", nullable: false)
                    .Annotation("SqlServer:Identity", "1, 1"),
                Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false)
            },
            constraints: table =>
            {
                table.PrimaryKey("PK_Users", x => x.Id);
            });

        migrationBuilder.CreateIndex(
            name: "IX_Users_Email",
            table: "Users",
            column: "Email",
            unique: true);
    }

    protected override void Down(MigrationBuilder migrationBuilder) {
        migrationBuilder.DropTable(name: "Users");
    }
}
```

### Seed Data (Datos Iniciales)

```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder) {
    modelBuilder.Entity<Role>().HasData(
        new Role { Id = 1, Name = "Admin" },
        new Role { Id = 2, Name = "User" },
        new Role { Id = 3, Name = "Guest" }
    );
}

// En migración:
protected override void Up(MigrationBuilder migrationBuilder) {
    migrationBuilder.InsertData(
        table: "Roles",
        columns: new[] { "Id", "Name" },
        values: new object[] { 1, "Admin" }
    );
}
```

---

## Checklist: Entity Framework Core Bien Formado

```bash
# ✅ 1. DbContext
[ ] Una clase DbContext heredando DbContext
[ ] DbSet<T> por cada entidad
[ ] Inyectado en Program.cs

# ✅ 2. Configuration
[ ] Fluent API en OnModelCreating
[ ] Data Annotations [Required], [MaxLength]
[ ] Índices definidos
[ ] Foreign keys configuradas

# ✅ 3. Relaciones
[ ] One-to-Many con HasMany/WithMany
[ ] Many-to-Many con tabla junction explícita
[ ] One-to-One con HasOne/WithOne
[ ] OnDelete comportamiento (Cascade/Restrict)

# ✅ 4. Queries
[ ] .AsNoTracking() para lectura
[ ] .Include() para relaciones
[ ] .Select() para proyecciones
[ ] Evitar N+1 queries

# ✅ 5. Migraciones
[ ] Migraciones en Git
[ ] db.Database.Migrate() en startup
[ ] Seed data definido
[ ] Versionado consistente

# ✅ 6. Performance
[ ] Índices en foreign keys
[ ] Proyectar campos necesarios
[ ] Batch operations para bulk
[ ] Connection pooling configurado
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ EF CORE MASTERY READY
**Responsable:** ArchitectZero AI Agent
