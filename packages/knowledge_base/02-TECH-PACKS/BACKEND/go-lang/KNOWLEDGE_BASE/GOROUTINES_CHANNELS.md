# 🔄 Goroutines & Channels: Concurrencia CSP

> **Modelo:** Communicating Sequential Processes (CSP)
> **Mantra:** "Do not communicate by sharing memory; instead, share memory by communicating."
> **Fecha:** 30 de Enero de 2026

La filosofía de Go: procesos ligeros que se comunican por canales, no threads pesados que comparten memoria.

---

## 📖 Tabla de Contenidos

1. [Goroutines: Threads Ligeros](#goroutines-threads-ligeros)
2. [Channels: Tuberías de Comunicación](#channels-tuberías-de-comunicación)
3. [Patrones: Worker Pool](#patrones-worker-pool)
4. [Patrones: Fan-Out/Fan-In](#patrones-fan-outfan-in)
5. [Select: Multiplexing](#select-multiplexing)
6. [Anti-Patterns](#anti-patterns)

---

## Goroutines: Threads Ligeros

### Qué es una Goroutine

Una función que corre en paralelo, gestionada por el runtime de Go. **NO es un thread del SO** (que cuesta ~1MB RAM). Una goroutine cuesta ~2KB RAM.

```go
// Crear goroutine: simplemente anteponer "go"
go function()

// En un bucle
for i := 0; i < 1000000; i++ {
    go processRequest(i)  // 1 millón de goroutines = ~2GB RAM (vs 1TB con threads)
}
```

### El Problema: "Fire and Forget"

```go
// ❌ BAD: main() termina antes de que la goroutine haga algo
func main() {
    go println("Hello from goroutine")
    // main termina, la goroutine muere sin ejecutarse
}

// Salida: (ninguna)

// ✅ GOOD: Esperar a que termine
func main() {
    go println("Hello from goroutine")
    time.Sleep(1 * time.Second)  // Esperar
}

// Salida: Hello from goroutine
```

### Sincronización con sync.WaitGroup

```go
// ✅ GOOD: Esperar a múltiples goroutines
func main() {
    var wg sync.WaitGroup

    urls := []string{
        "https://api.example.com/users",
        "https://api.example.com/posts",
        "https://api.example.com/comments",
    }

    for _, url := range urls {
        wg.Add(1)  // +1 a contar
        go func(u string) {
            defer wg.Done()  // -1 cuando termine

            resp, err := http.Get(u)
            if err != nil {
                fmt.Printf("Error fetching %s: %v\n", u, err)
                return
            }
            fmt.Printf("Got status %d from %s\n", resp.StatusCode, u)
        }(url)
    }

    wg.Wait()  // Bloquea hasta que todas Done()
    fmt.Println("All fetches complete")
}
```

### Goroutines con Return Values

```go
// Problema: goroutines no retornan valores
// Solución: usar canales

func fetchURL(url string, results chan<- string) {
    resp, err := http.Get(url)
    if err != nil {
        results <- fmt.Sprintf("Error: %v", err)
        return
    }
    results <- fmt.Sprintf("Status: %d", resp.StatusCode)
}

func main() {
    results := make(chan string, 3)

    go fetchURL("https://example.com/1", results)
    go fetchURL("https://example.com/2", results)
    go fetchURL("https://example.com/3", results)

    // Recibir resultados (en cualquier orden)
    for i := 0; i < 3; i++ {
        fmt.Println(<-results)
    }
}
```

---

## Channels: Tuberías de Comunicación

### Crear y Usar Canales

```go
// Crear canal (debe especificar tipo)
ch := make(chan int)        // Unbuffered (blocking)
ch := make(chan int, 10)    // Buffered (10 items before blocking)

// Enviar
ch <- 42

// Recibir
value := <-ch

// Recibir con ok (¿está cerrado?)
value, ok := <-ch  // ok=false si canal cerrado

// Cerrar
close(ch)

// Iterar sobre canal (hasta que cierre)
for value := range ch {
    fmt.Println(value)
}
```

### Unbuffered vs Buffered

```go
// ❌ PROBLEM: Unbuffered (deadlock)
func main() {
    ch := make(chan int)
    ch <- 42  // Bloquea aquí (nadie escucha)
    val := <-ch
    fmt.Println(val)
}

// ✅ GOOD: Unbuffered con goroutine
func main() {
    ch := make(chan int)
    go func() {
        ch <- 42  // Envia en goroutine
    }()
    val := <-ch  // Recibe en main
    fmt.Println(val)
}

// ✅ GOOD: Buffered (no bloquea hasta llenar)
func main() {
    ch := make(chan int, 1)
    ch <- 42  // OK (buffer tiene espacio)
    val := <-ch
    fmt.Println(val)
}
```

### Directional Channels

```go
// Canal que solo envía
func Sender(ch chan<- int) {
    ch <- 42
}

// Canal que solo recibe
func Receiver(ch <-chan int) {
    value := <-ch
    fmt.Println(value)
}

// Canal bidireccional
func BiDirectional(ch chan int) {
    ch <- 42
    value := <-ch
}

// Usar
func main() {
    ch := make(chan int)
    go Sender(ch)       // Pass como send-only
    Receiver(ch)        // Pass como receive-only
}
```

---

## Patrones: Worker Pool

Procesar N jobs con M workers (limitar concurrencia).

```go
// Worker procesa jobs del canal
func Worker(id int, jobs <-chan int, results chan<- string) {
    for job := range jobs {
        fmt.Printf("Worker %d processing job %d\n", id, job)
        time.Sleep(1 * time.Second)
        results <- fmt.Sprintf("Result of job %d", job)
    }
}

func main() {
    jobs := make(chan int, 100)
    results := make(chan string, 100)

    // Lanzar 3 workers (no 100!)
    numWorkers := 3
    for w := 0; w < numWorkers; w++ {
        go Worker(w, jobs, results)
    }

    // Enviar 100 jobs
    for j := 1; j <= 100; j++ {
        jobs <- j
    }
    close(jobs)  // Signal: no más jobs

    // Leer resultados
    for r := 1; r <= 100; r++ {
        fmt.Println(<-results)
    }
}
```

**Output (en paralelo):**
```
Worker 0 processing job 1
Worker 1 processing job 2
Worker 2 processing job 3
Worker 0 processing job 4
...
```

---

## Patrones: Fan-Out/Fan-In

Distribuir trabajo a múltiples workers y recopilar resultados.

```go
// Fan-Out: distribuir a múltiples workers
func FanOut(ch <-chan int, numWorkers int) []<-chan string {
    channels := make([]<-chan string, numWorkers)

    for w := 0; w < numWorkers; w++ {
        out := make(chan string)
        channels[w] = out

        go func(id int, input <-chan int, output chan<- string) {
            for job := range input {
                output <- fmt.Sprintf("W%d: Result %d", id, job*2)
            }
            close(output)
        }(w, ch, out)
    }

    return channels
}

// Fan-In: recopilar de múltiples workers
func FanIn(channels ...<-chan string) <-chan string {
    var wg sync.WaitGroup
    out := make(chan string)

    send := func(c <-chan string) {
        defer wg.Done()
        for value := range c {
            out <- value
        }
    }

    wg.Add(len(channels))
    for _, ch := range channels {
        go send(ch)
    }

    go func() {
        wg.Wait()
        close(out)
    }()

    return out
}

func main() {
    // Source: canal con números
    source := make(chan int)
    go func() {
        for i := 1; i <= 10; i++ {
            source <- i
        }
        close(source)
    }()

    // Fan-Out: distribuir a 3 workers
    workers := FanOut(source, 3)

    // Fan-In: recopilar resultados
    results := FanIn(workers...)

    // Leer resultados
    for result := range results {
        fmt.Println(result)
    }
}
```

---

## Select: Multiplexing

Escuchar múltiples canales a la vez (como `switch` para canales).

```go
// ✅ GOOD: Escuchar múltiples canales
func main() {
    ch1 := make(chan string)
    ch2 := make(chan string)

    go func() {
        time.Sleep(1 * time.Second)
        ch1 <- "One second elapsed"
    }()

    go func() {
        time.Sleep(2 * time.Second)
        ch2 <- "Two seconds elapsed"
    }()

    // Esperar a cualquiera que esté listo
    select {
    case msg1 := <-ch1:
        fmt.Println(msg1)
    case msg2 := <-ch2:
        fmt.Println(msg2)
    }

    time.Sleep(1 * time.Second)
}

// Salida: One second elapsed
```

### Select con Timeout

```go
// ✅ GOOD: Timeout pattern
func FetchWithTimeout(url string, timeout time.Duration) (string, error) {
    results := make(chan string)

    go func() {
        resp, _ := http.Get(url)
        // Simular delay
        results <- "Got response"
    }()

    select {
    case result := <-results:
        return result, nil
    case <-time.After(timeout):
        return "", fmt.Errorf("timeout after %v", timeout)
    }
}

func main() {
    result, err := FetchWithTimeout("https://example.com", 2*time.Second)
    if err != nil {
        fmt.Println("Error:", err)
    } else {
        fmt.Println(result)
    }
}
```

### Select con Context

```go
// ✅ GOOD: Cancel pattern
func FetchWithContext(ctx context.Context, url string) (string, error) {
    results := make(chan string)

    go func() {
        resp, _ := http.Get(url)
        results <- "Got response"
    }()

    select {
    case result := <-results:
        return result, nil
    case <-ctx.Done():
        return "", ctx.Err()  // context.Canceled o context.DeadlineExceeded
    }
}

func main() {
    ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
    defer cancel()

    result, err := FetchWithContext(ctx, "https://example.com")
    if err != nil {
        fmt.Println("Error:", err)
    }
}
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Goroutine Leak

```go
// ❌ BAD: Goroutine nunca termina
func ProcessForever(ch <-chan int) {
    for {
        value := <-ch  // Si canal nunca cierra, loop infinito
    }
}

func main() {
    ch := make(chan int)
    go ProcessForever(ch)
    ch <- 1
    // ProcessForever sigue esperando forever
}

// ✅ GOOD: Cerrar canal cuando termine
func ProcessUntilClose(ch <-chan int) {
    for value := range ch {  // Termina cuando cierra
        fmt.Println(value)
    }
}

func main() {
    ch := make(chan int)
    go ProcessUntilClose(ch)
    ch <- 1
    close(ch)  // Goroutine termina
}
```

### ❌ ANTI-PATTERN 2: Deadlock

```go
// ❌ BAD: Deadlock (ambos esperan)
func main() {
    ch := make(chan int)
    ch <- 42     // Bloquea esperando receptor
    value := <-ch  // Nunca se ejecuta
}

// ✅ GOOD: Usar goroutine
func main() {
    ch := make(chan int)
    go func() {
        ch <- 42  // Envia en goroutine
    }()
    value := <-ch  // Recibe
    fmt.Println(value)
}
```

### ❌ ANTI-PATTERN 3: Usar Mutex sin Necesidad

```go
// ❌ BAD: Mutex complejo
var mu sync.Mutex
var counter int

func Increment() {
    mu.Lock()
    defer mu.Unlock()
    counter++
}

// ✅ GOOD: Usar canal (simpler, less error-prone)
func main() {
    count := make(chan int)

    go func() {
        for {
            count <- 1  // Enviar incremento
        }
    }()

    for i := 0; i < 1000; i++ {
        <-count
    }
}
```

---

## Checklist: Concurrency Patterns

```bash
# ✅ 1. Goroutines
[ ] Usar sync.WaitGroup para esperar
[ ] Nunca "fire and forget" sin sincronización
[ ] defer wg.Done() en cada goroutine

# ✅ 2. Channels
[ ] Cerrar canal cuando no hay más datos (close())
[ ] Recibidor espera close() (for range ch)
[ ] Directional channels (chan<- int, <-chan int)

# ✅ 3. Patterns
[ ] Worker pool para limitar concurrencia
[ ] Fan-out/Fan-in para distribuir trabajo
[ ] Select para multiplexing
[ ] Context para cancelación

# ✅ 4. Error Handling
[ ] Manejar errores en goroutines (no panics)
[ ] Retornar errors vía canal
[ ] Wrap errors con fmt.Errorf("%w", err)

# ✅ 5. Performance
[ ] Benchmark (go test -bench)
[ ] Profiling (pprof)
[ ] GOMAXPROCS control si es needed

# ✅ 6. Debugging
[ ] go run -race para race conditions
[ ] Logs estructurados en concurrencia
[ ] Timeout para prevenir deadlocks
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ CSP CONCURRENCY PATTERNS READY
**Responsable:** ArchitectZero AI Agent
