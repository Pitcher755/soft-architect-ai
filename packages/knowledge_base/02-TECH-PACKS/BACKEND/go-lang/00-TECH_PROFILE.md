# 🆔 Tech Profile: Go (Golang)

> **Categoría:** Systems Programming Language
> **Filosofía:** "Simplicity is Complicated"
> **Versión:** Go 1.21+
> **Compilación:** Binario Estático Nativo (Sin dependencias externas)
> **Fecha:** 30 de Enero de 2026

El lenguaje de la nube. Diseñado por Google (2009) para reemplazar a C++ y Java en sistemas distribuidos. Si Docker y Kubernetes existen, es porque Go existe.

---

## 📖 Tabla de Contenidos

1. [Visión de Go](#visión-de-go)
2. [Casos de Uso](#casos-de-uso)
3. [Pilares Técnicos](#pilares-técnicos)
4. [Comparación con Java/Python](#comparación-con-javapython)
5. [DevOps & Deployment](#devops--deployment)

---

## Visión de Go

### Qué es Go

Un lenguaje compilado, tipado estáticamente, diseñado para:

- **Concurrencia Nativa:** Goroutines (millones en simultaneidad)
- **Simplicidad Radical:** 25 palabras reservadas (vs 50+ en Java)
- **Velocidad Extrema:** Compilación a binario nativo en segundos
- **No hay Frameworks Pesados:** La librería estándar es suficiente (net/http, encoding/json, etc.)

### Filosofía

> **"Go is opinionated. We only made hard decisions if we felt there was a clear winner."** - Rob Pike (Go Designer)

Go **NO** te deja:
- ❌ Elegir cómo manejar errores (no try/catch)
- ❌ Elegir cómo iterar (solo `for`)
- ❌ Elegir cómo paralelizar (CSP con canales, no threads)

Go **SÍ** te da:
- ✅ Binario único (sin runtime externo)
- ✅ Inferencia de tipos inteligente
- ✅ Interfaces implícitas ("duck typing" tipado)
- ✅ Garbage collection eficiente

---

## Casos de Uso

### ✅ Ideal Para Go

| Caso | Razón | Ejemplo |
|:---|:---|:---|
| **Microservicios** | Goroutines = 2KB RAM vs Thread Java = 1MB | 100k goroutines = 200MB, 100k threads = 100GB |
| **Network Services** | Net HTTP nativo, ultra-rápido | Proxies, Gateways, Load Balancers |
| **CLI Tools** | Binario único, startup instant | Docker, Kubernetes, Hugo, Terraform |
| **DevOps Tools** | Cross-platform sin dependencias | Prometheus, Grafana, Vault |
| **Cloud Native** | Container-first | AWS Lambda, Google Cloud Functions |

### ❌ NO Usar Go Para

| Caso | Mejor Alternativa | Razón |
|:---|:---|:---|
| **Lógica de Negocio Compleja (DDD)** | Java, C# | Falta de herencia, genéricos limitados |
| **GUI Desktop** | Electron, Java Swing | Go es backend-only |
| **Data Science** | Python | Sin ecosistema ML/numpy |
| **Prototipado Rápido** | Python, JavaScript | Go requiere compilación |

---

## Pilares Técnicos

### 1. Simplicidad Radical

```go
// Go tiene SOLO un tipo de bucle
for i := 0; i < 10; i++ { }      // Counter
for range collection { }           // Iterator
for key, value := range map { }   // Map iterator
for value := range channel { }    // Channel iterator

// No hay while, no hay do-while, no hay foreach special
```

### 2. Goroutines (Concurrencia Ligera)

```go
// Lanzar una función en paralelo en 1 línea
go fetchData(url)  // Goroutine (2KB RAM)

// Vs Java Thread (1MB RAM)
new Thread(() -> fetchData(url)).start();

// En Go, puedes tener MILLONES sin problemas
for i := 0; i < 1_000_000; i++ {
    go processRequest(i)
}
```

### 3. Interfaces Implícitas

```go
// Java: Implementación explícita
interface Reader {
    byte[] read();
}
class FileReader implements Reader { }

// Go: "Duck Typing" tipado (si quacks como pato, es pato)
type Reader interface {
    Read(p []byte) (n int, err error)
}

// CUALQUIER struct con método Read() es un Reader
type File struct { }
func (f *File) Read(p []byte) (int, error) { return 0, nil }

// Sin "implements", sin boilerplate
```

### 4. Errores como Valores

```go
// Go NO tiene excepciones
// Los errores son valores que se retornan

func fetchUser(id string) (*User, error) {
    if id == "" {
        return nil, fmt.Errorf("user id cannot be empty")
    }
    user := &User{ID: id}
    return user, nil
}

// Caller decide qué hacer
user, err := fetchUser("123")
if err != nil {
    log.Fatal(err)  // Manejo explícito
}
```

### 5. Compilación a Binario Nativo

```bash
# Compilar para Linux
GOOS=linux GOARCH=amd64 go build -o app

# Resultado: un ejecutable único (~10-50MB), sin dependencias externas
./app  # Funciona en cualquier Linux

# Vs Java: necesita JRE 300MB+
java -jar app.jar  # Requiere JVM
```

---

## Comparación con Java/Python

| Aspecto | Java | Python | Go | Ganador |
|:---|:---|:---|:---|:---|
| **Velocidad** | Muy rápido | Lento (interpretado) | Ultra-rápido (compilado) | 🏆 Go |
| **Startup** | 1-5s (JVM) | 0.1-0.5s | 0.01s (nativo) | 🏆 Go |
| **Concurrencia** | Threads (pesados) | Threads (Gil lock) | Goroutines (ligeras) | 🏆 Go |
| **Memory** | ~500MB minimo | ~50MB minimo | ~10MB minimo | 🏆 Go |
| **Binario** | JAR + JRE | Python + libs | Executable único | 🏆 Go |
| **Curva Aprendizaje** | Media | Baja | Baja-Media | 🏆 Python |
| **Ecosystem** | Masivo | Excelente | Creciente | 🏆 Java |
| **DevOps Adoption** | Bajo | Medio | MASIVO | 🏆 Go |

---

## DevOps & Deployment

### Docker (Built in Go)

```dockerfile
# Compilar en Linux
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o app .

# Ejecutar (imagen vacía)
FROM scratch
COPY --from=builder /app/app .
ENTRYPOINT ["./app"]
```

**Ventaja:** Imagen final = ~5-10MB (vs 200MB+ de Java)

### Deployment Targets

| Target | Tiempo | Notas |
|:---|:---|:---|
| **Kubernetes** | 1s | Pod inicia instantáneamente |
| **Docker** | 2s | Imagen tiny, startup ultra-rápido |
| **Binary Distribution** | Instant | Un solo archivo, sin dependencias |
| **AWS Lambda** | < 100ms | Go es tier 1 en Lambda |
| **Microservicios** | 30s | Cluster entero sube en segundos |

### Performance (TechEmpower Round 22)

| Framework | Req/s | Lenguaje |
|:---|---:|:---|
| Echo (Go) | 250k | Go |
| Iris (Go) | 220k | Go |
| Actix-web | 240k | Rust |
| ASP.NET Core | 110k | C# |
| Spring Boot | 60k | Java |

---

## Checklist: Go Project Setup

```bash
# ✅ 1. Crear proyecto
[ ] go mod init github.com/username/project
[ ] Go 1.21+ installed
[ ] gofmt configured (auto-format on save)

# ✅ 2. Estructura
[ ] cmd/myapp/main.go (entry point)
[ ] internal/ (private code)
[ ] pkg/ (public libraries)
[ ] api/ (OpenAPI specs)

# ✅ 3. Tools
[ ] go fmt (formatting)
[ ] go vet (static analysis)
[ ] golangci-lint (linter)
[ ] go test ./... (testing)

# ✅ 4. Concurrency
[ ] Goroutines for async operations
[ ] Channels for communication
[ ] sync.WaitGroup for coordination
[ ] context.Context for cancellation

# ✅ 5. Error Handling
[ ] Explicit error checks (if err != nil)
[ ] Wrap errors with %w (go 1.13+)
[ ] No panic in production code

# ✅ 6. DevOps
[ ] Dockerfile con multi-stage build
[ ] .dockerignore configured
[ ] GitHub Actions CI/CD
[ ] Health checks (/health endpoint)
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ GO SYSTEMS PROGRAMMING READY
**Responsable:** ArchitectZero AI Agent

**Próximo Paso:** GOROUTINES_CHANNELS.md & PROJECT_LAYOUT.md
