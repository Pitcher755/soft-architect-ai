# 🆔 Tech Profile: .NET (C# 12+)

> **Categoría:** Enterprise Application Framework (Unified Platform)
> **Versión:** .NET 8 LTS (Long-Term Support)
> **Lenguaje:** C# 12+
> **Fecha:** 30 de Enero de 2026

La plataforma unificada de Microsoft. Desde web APIs hasta desktop, desde cloud hasta machine learning. TODO con el mismo ecosistema.

---

## 📖 Tabla de Contenidos

1. [Visión de .NET](#visión-de-net)
2. [Casos de Uso](#casos-de-uso)
3. [Pilares Técnicos](#pilares-técnicos)
4. [Comparación con Java](#comparación-con-java)
5. [DevOps & Deployment](#devops--deployment)

---

## Visión de .NET

### Qué es .NET

Una plataforma **Open Source** (MIT License) que permite escribir una sola lógica de negocio y deployarla en:

- **Web:** ASP.NET Core (APIs REST, gRPC, GraphQL)
- **Desktop:** WinForms, WPF, MAUI
- **Mobile:** .NET MAUI (Cross-Platform)
- **Cloud:** Azure (nativa)
- **IoT:** .NET IoT
- **Gaming:** Unity (C#)
- **Data:** Azure Services

### Evolución del Nombre

```
.NET Framework (2002-2019) - Windows only
    ↓
.NET Core 3.1 (2019) - Cross-platform
    ↓
.NET 5+ (2020+) - Unificado (Core + Framework)
    ↓
.NET 8 LTS (2023+) - Producción moderna
```

---

## Casos de Uso

### ✅ Ideal Para .NET

| Caso | Razón | Benchmark |
|:---|:---|:---|
| **APIs de Alto Rendimiento** | Async/await nativo, TechEmpower Top 5 | ~110k req/s |
| **Sistemas Azure-First** | Integración cero-latencia con Azure | SDK oficial |
| **Enterprise .NET Existente** | Migración desde .NET Framework | Drop-in upgrade |
| **Arquitecturas Limpias** | DI container nativo, structure fomentada | Built-in |
| **Microservicios** | gRPC nativo, containerización simple | Docker first-class |
| **Real-Time:** WebSockets, SignalR | Excelente soporte | < 1ms latency |

### ❌ NO Usar .NET Para

| Caso | Mejor Alternativa | Razón |
|:---|:---|:---|
| **Scripts pequeños** | Bash, Python | Overhead de .NET |
| **CLI utilities** | Go, Rust | Startup time |
| **Backend de startups cash-strapped** | Node.js, Python | Curva de aprendizaje C# |
| **Máquina Linux legacy (sin .NET)** | Java, Go | Deployment friction |

---

## Pilares Técnicos

### 1. LINQ (Language Integrated Query)

La **joya técnica** de C#. Manipulación de datos declarativa sobre colecciones o bases de datos.

```csharp
// ✅ LINQ sobre objetos
var adults = users
    .Where(u => u.Age >= 18)
    .OrderByDescending(u => u.CreatedAt)
    .Select(u => new { u.Name, u.Email })
    .ToList();

// ✅ LINQ sobre SQL (Entity Framework)
var activeOrders = context.Orders
    .Where(o => o.Status == OrderStatus.Active)
    .Include(o => o.Items)  // JOIN
    .ToListAsync();
```

**Ventaja sobre Java:** No necesitas bibliotecas externas (Stream API). LINQ es estándar.

### 2. Async/Await (Nativo desde 2012)

C# inventó este patrón. JavaScript y Python lo copiaron después.

```csharp
// ✅ Async/await integrado
async Task<User> GetUserAsync(int id) {
    var response = await httpClient.GetAsync($"/users/{id}");
    return await response.Content.ReadAsAsync<User>();
}

// Bajo el capó: State machine, no threads
```

**Ventaja:** Async por defecto, no "callback hell".

### 3. Dependency Injection (Built-in)

No necesitas Spring. `IServiceCollection` y `IServiceProvider` vienen con .NET.

```csharp
// Startup.cs o Program.cs (Minimal APIs)
builder.Services.AddScoped<IUserService, UserService>();
builder.Services.AddSingleton<ICacheService, RedisCacheService>();
builder.Services.AddHttpClient<IExternalApiClient, ExternalApiClient>();

// En el Controller
public class UserController {
    public UserController(IUserService userService) {
        // DI automático
    }
}
```

### 4. Entity Framework Core (ORM)

```csharp
// Fluent API (Type-safe)
modelBuilder.Entity<User>()
    .HasMany(u => u.Orders)
    .WithOne(o => o.User)
    .OnDelete(DeleteBehavior.Cascade);

// O Data Annotations
[HasKey(u => u.Id)]
public class User {
    [Required]
    public string Email { get; set; }
}
```

### 5. Tipos Nulos Seguros (Nullable Reference Types)

```csharp
#nullable enable

public class User {
    public string Name { get; set; }  // ← No-null (error si null)
    public string? Bio { get; set; }  // ← Nullable (explícito)
}

var user = new User { Name = null };  // ❌ Compiler warning
var user = new User { Name = "" };    // ✅ OK
```

---

## Comparación con Java

| Aspecto | Java | C# / .NET | Ganador |
|:---|:---|:---|:---|
| **Async** | CompletableFuture (verbose) | async/await (conciso) | 🏆 C# |
| **Queries** | Streams API + SpringData | LINQ (nativo) | 🏆 C# |
| **ORM** | Hibernate (complejo) | EF Core (moderno) | 🏆 C# |
| **DI** | Spring (potente, overhead) | Built-in | 🏆 C# |
| **Performance** | Muy bueno | Excelente (TechEmpower #4) | 🏆 C# |
| **Cross-Platform** | Java everywhere | .NET 5+ everywhere | 🏆 Empate |
| **Job Market** | Masivo | Creciente (+15% YoY) | 🏆 Java |
| **Curva de Aprendizaje** | Media | Media-Alta (LINQ, async) | 🏆 Java |

---

## DevOps & Deployment

### Container (Docker)

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8 AS runtime
FROM mcr.microsoft.com/dotnet/sdk:8 AS builder

WORKDIR /app
COPY . .

RUN dotnet publish -c Release -o out

FROM runtime
COPY --from=builder /app/out .
ENTRYPOINT ["dotnet", "MyApp.dll"]
```

### Deployment Targets

| Target | Tool | Tiempo |
|:---|:---|:---|
| **Azure App Service** | `az webapp up` | 30s |
| **Docker/Kubernetes** | Docker Desktop, Helm | 5m |
| **Self-hosted Linux** | systemd, Nginx | 10m |
| **Azure Container Instances** | `az container create` | 1m |

### Performance (TechEmpower Round 22)

| Framework | Req/s | Lenguaje |
|:---|---:|:---|
| Actix-web | 240k | Rust |
| **ASP.NET Core** | **110k** | **C#** |
| Spring Boot | 60k | Java |
| Express | 18k | Node.js |
| Django | 4k | Python |

---

## Checklist: .NET Project Setup

```bash
# ✅ 1. Crear proyecto
[ ] dotnet new webapi -n MyApi
[ ] Target .NET 8 (TFM = net8.0)
[ ] C# 12 language version

# ✅ 2. Nugets Esenciales
[ ] Microsoft.EntityFrameworkCore.SqlServer
[ ] Serilog (logging)
[ ] AutoMapper (DTO mapping)
[ ] FluentValidation (DTOs validation)
[ ] MediatR (CQRS pattern, optional)

# ✅ 3. Estructura Carpetas
[ ] src/Domain (entities, interfaces)
[ ] src/Application (services, DTOs)
[ ] src/Infrastructure (DB, external APIs)
[ ] src/Web (controllers, middleware)
[ ] tests/ (unit, integration tests)

# ✅ 4. Program.cs
[ ] DI services registered
[ ] Middleware pipeline configured
[ ] Exception handling
[ ] CORS if needed

# ✅ 5. Seguridad
[ ] Authentication (JWT)
[ ] Authorization (roles)
[ ] Rate limiting
[ ] Input validation

# ✅ 6. DevOps
[ ] Dockerfile for containerization
[ ] .dockerignore configured
[ ] GitHub Actions CI/CD
[ ] Health checks (/health endpoint)
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ .NET ECOSYSTEM OVERVIEW
**Responsable:** ArchitectZero AI Agent

**Próximo Paso:** LINQ_PATTERNS.md & EF_CORE.md
