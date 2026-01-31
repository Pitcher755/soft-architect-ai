# 📏 Tech Governance Rules: Go

> **Tooling:** `gofmt`, `go vet`, `golangci-lint`
> **Filosofía:** "Idiomatic Go"
> **Principio:** Explicit > Implicit
> **Fecha:** 30 de Enero de 2026

Las reglas que rigen Go. No son sugerencias. Son la ley. El compilador y la comunidad te los recordarán.

---

## 📖 Tabla de Contenidos

1. [Manejo de Errores](#manejo-de-errores)
2. [Naming Conventions](#naming-conventions)
3. [Interfaces & Embedding](#interfaces--embedding)
4. [Resource Management](#resource-management)
5. [Concurrency Rules](#concurrency-rules)
6. [Anti-Patterns](#anti-patterns)

---

## Manejo de Errores

### Regla de Oro: Los Errores Son Valores

Go **NO tiene excepciones**. Los errores se retornan como valores.

```go
// ✅ GOOD: Retornar error como valor
func OpenFile(filename string) (*File, error) {
    f, err := os.Open(filename)
    if err != nil {
        return nil, fmt.Errorf("failed to open file %s: %w", filename, err)
    }
    return &File{file: f}, nil
}

// Caller DEBE manejar el error
f, err := OpenFile("data.txt")
if err != nil {
    // Handle error (log, retry, return upstream)
    log.Fatal(err)
}

// ❌ BAD: Ignorar error (compilation error en algunos linters)
f, _ := os.Open("data.txt")  // Panic waiting to happen

// ❌ BAD: No retornar error (oculta problemas)
func OpenFile(filename string) *File {
    f, _ := os.Open(filename)
    return &File{file: f}  // Silent failure
}
```

### Wrapping Errors (Go 1.13+)

```go
// ✅ GOOD: Usar %w para preservar la cadena de errores
if err != nil {
    return fmt.Errorf("failed to process: %w", err)  // Preserva err
}

// ❌ BAD: Usar %v pierde info
if err != nil {
    return fmt.Errorf("failed to process: %v", err)  // Lose original error
}

// Caller puede unwrap
if errors.Is(err, io.EOF) {
    // Handle specific error
}

if errors.As(err, &myCustomError) {
    // Extract specific error type
}
```

### Early Return (No Pyramids)

```go
// ❌ BAD: Pyramid of Doom
func ProcessData(data string) error {
    if len(data) > 0 {
        parsed, err := parse(data)
        if err == nil {
            result, err := process(parsed)
            if err == nil {
                err = save(result)
                return err
            }
        }
    }
    return errors.New("invalid data")
}

// ✅ GOOD: Early return
func ProcessData(data string) error {
    if len(data) == 0 {
        return errors.New("data is empty")
    }

    parsed, err := parse(data)
    if err != nil {
        return fmt.Errorf("parse failed: %w", err)
    }

    result, err := process(parsed)
    if err != nil {
        return fmt.Errorf("process failed: %w", err)
    }

    if err := save(result); err != nil {
        return fmt.Errorf("save failed: %w", err)
    }

    return nil
}
```

---

## Naming Conventions

### Exported vs Unexported (Visibility)

```go
// ✅ Mayúscula = Público (Exported)
func (s *Service) FetchUser(id string) (*User, error) { ... }

// ✅ Minúscula = Privado (Unexported)
func (s *service) fetchUserFromDB(id string) (*User, error) { ... }

// Aplica también a tipos
type User struct { }     // Público
type user struct { }     // Privado

// Y campos
type User struct {
    Name string  // Público (marshals to JSON)
    age  int     // Privado (no marshals)
}
```

### Brevedad en Nombres

Go prefiere nombres cortos pero claros. No `thisIsMyVariableName`.

```go
// ✅ GOOD: Corto pero claro
func NewService(db *Database) *Service { ... }
var ctx context.Context
var err error

// ❌ BAD: Demasiado largo
func NewUserManagementService(database *DatabaseConnection) *UserService { ... }

// Excepto en parámetros de función, donde el contexto lo aclara
func processOrder(ctx context.Context, userID string) error { ... }
```

### Interfaces: Suffix `-er`

```go
// ✅ GOOD: Reader, Writer, Closer, Handler, Logger
type Reader interface {
    Read(p []byte) (n int, err error)
}

type Logger interface {
    Log(msg string)
}

// ❌ BAD: Reader Interface, Readable, Reading
type ReaderInterface interface { }
type Readable interface { }
```

### Package Names

```go
// ✅ GOOD: Nombres cortos y descriptivos
package user
package order
package payment

// ❌ BAD: Nombres genéricos o largos
package userutils
package common
package helpers

// Importar
import "myapp/user"
func main() {
    u := user.NewUser()  // Claro: package.function
}
```

---

## Interfaces & Embedding

### Implicit Interfaces (Duck Typing Tipado)

```go
// ✅ No declare "implements"
type Reader interface {
    Read(p []byte) (int, error)
}

type File struct { }
func (f *File) Read(p []byte) (int, error) { return 0, nil }

// File implementa Reader IMPLÍCITAMENTE
var r Reader = &File{}  // Compila sin "implements"

// Esto permite:
// 1. Interfaces pequeñas
// 2. Implementaciones múltiples
// 3. Sin acoplamiento
```

### Accept Interfaces, Return Structs

```go
// ✅ GOOD: Función acepta interface (flexible)
func Process(input io.Reader) error { ... }

// Puede ser File, Buffer, Network, etc.
Process(os.Stdin)
Process(&bytes.Buffer{})

// ✅ GOOD: Pero retorna struct concreto (predecible)
func NewService(db *Database) *Service { ... }

// ❌ BAD: Retornar interface
func NewService(db *Database) ServiceInterface { ... }

// Problema: Caller no sabe qué métodos tiene
```

### Embedding (Composition over Inheritance)

```go
// ✅ Embedding (composition)
type Reader interface {
    Read(p []byte) (int, error)
}

type File struct { }
func (f *File) Read(p []byte) (int, error) { return 0, nil }

// Embed interface
type LoggingReader struct {
    Reader  // Hereda métodos implícitamente
    log Logger
}

func (lr *LoggingReader) Read(p []byte) (int, error) {
    lr.log.Log("reading...")
    return lr.Reader.Read(p)
}

// Uso
r := &LoggingReader{
    Reader: &File{},
    log: myLogger,
}
r.Read(buf)  // Llama a LoggingReader.Read
```

---

## Resource Management

### defer (Cleanup Garantizado)

```go
// ✅ GOOD: defer limpia recursos SIEMPRE
func ReadFile(filename string) error {
    f, err := os.Open(filename)
    if err != nil {
        return err
    }
    defer f.Close()  // Se ejecuta al salir, incluso si panic

    // Leer archivo...
    return nil
}

// ✅ GOOD: defer múltiples
func ProcessTransaction(db *sql.DB) error {
    tx, err := db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()  // Rollback si error

    // Hacer trabajo...

    return tx.Commit()  // Commit si todo OK
}

// ❌ BAD: Sin defer (resource leak)
func ReadFile(filename string) error {
    f, _ := os.Open(filename)
    data := readData(f)
    if data == nil {
        return errors.New("empty")  // f NO se cierra!
    }
    // ...
}
```

### Defer Order (LIFO - Last In, First Out)

```go
func Setup() error {
    a := acquireA()
    defer releaseA(a)

    b := acquireB()
    defer releaseB(b)

    c := acquireC()
    defer releaseC(c)

    return nil
    // Se ejecutan en orden: releaseC, releaseB, releaseA
}
```

---

## Concurrency Rules

### Goroutines: "Fire and Forget" es Peligroso

```go
// ❌ BAD: main() termina y goroutines mueren
func main() {
    go fetchData(url)
    // main termina, fetchData quizá ni empezó
}

// ✅ GOOD: Usar sync.WaitGroup para esperar
func main() {
    var wg sync.WaitGroup

    urls := []string{"url1", "url2", "url3"}
    for _, url := range urls {
        wg.Add(1)
        go func(u string) {
            defer wg.Done()
            fetchData(u)
        }(url)
    }

    wg.Wait()  // Espera a que todas terminen
}
```

### Channels: Comunicación sobre Memoria Compartida

```go
// ✅ GOOD: Usar canales (CSP)
func Worker(jobs <-chan int, results chan<- int) {
    for job := range jobs {
        results <- job * 2
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan int, 100)

    for i := 0; i < 10; i++ {
        jobs <- i
    }
    close(jobs)

    for i := 0; i < 10; i++ {
        fmt.Println(<-results)
    }
}

// ❌ BAD: Compartir memoria con mutex (propenso a deadlocks)
var mu sync.Mutex
var counter int

// Difícil de razonar, fácil de errar
```

### Context para Cancelación

```go
// ✅ GOOD: Cancelar goroutines con context
func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    results := make(chan string)
    go fetchWithContext(ctx, results)

    select {
    case result := <-results:
        fmt.Println(result)
    case <-ctx.Done():
        fmt.Println("Timeout!")
    }
}

func fetchWithContext(ctx context.Context, results chan<- string) {
    select {
    case <-ctx.Done():
        return  // Cancelada
    case <-time.After(10 * time.Second):
        results <- "done"
    }
}
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: No Manejar Errores

```go
// ❌ BAD
data, _ := ioutil.ReadFile("config.json")
var config Config
json.Unmarshal(data, &config)  // Falla silenciosamente

// ✅ GOOD
data, err := os.ReadFile("config.json")
if err != nil {
    return fmt.Errorf("read config: %w", err)
}

var config Config
if err := json.Unmarshal(data, &config); err != nil {
    return fmt.Errorf("parse config: %w", err)
}
```

### ❌ ANTI-PATTERN 2: Ignorar ctx.Done()

```go
// ❌ BAD: Goroutina ignorada
func fetch(ctx context.Context, url string) {
    for {
        data := http.Get(url)  // Ignora context
        time.Sleep(1 * time.Second)
    }
}

// ✅ GOOD
func fetch(ctx context.Context, url string) {
    for {
        select {
        case <-ctx.Done():
            return  // Respeta cancelación
        case <-time.After(1 * time.Second):
            data := http.Get(url)
        }
    }
}
```

### ❌ ANTI-PATTERN 3: Buffered Channels como Locks

```go
// ❌ BAD: Usar channel como "semáforo"
semaphore := make(chan struct{}, 1)
func Lock() { semaphore <- struct{}{} }
func Unlock() { <-semaphore }

// ✅ GOOD: Usar sync.Mutex
var mu sync.Mutex
func Lock() { mu.Lock() }
func Unlock() { mu.Unlock() }
```

---

## Checklist: Idiomatic Go

```bash
# ✅ 1. Errores
[ ] NUNCA ignorar error con _
[ ] Wrap errores con %w
[ ] Early return (sin pyramids)

# ✅ 2. Naming
[ ] Nombres cortos pero claros
[ ] Uppercase = exported, lowercase = unexported
[ ] Interfaces con suffix -er

# ✅ 3. Interfaces
[ ] Pequeñas (1-3 métodos)
[ ] Implícitas (sin implements)
[ ] Accept interfaces, return structs

# ✅ 4. Concurrency
[ ] Goroutines + WaitGroup
[ ] Canales para comunicación
[ ] Context para cancelación
[ ] defer para cleanup

# ✅ 5. Performance
[ ] No panic en producción
[ ] Reuse buffers (sync.Pool)
[ ] Benchmark critical code (go test -bench)

# ✅ 6. Style
[ ] gofmt (go fmt ./...)
[ ] go vet (go vet ./...)
[ ] golangci-lint para linting exhaustivo
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ IDIOMATIC GO GOVERNANCE
**Responsable:** ArchitectZero AI Agent
