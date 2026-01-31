# ⚡ Combine Patterns: Reactive Swift

> **Framework:** Combine (Apple's Reactive Framework)
> **iOS:** 13+
> **Uso:** Binding de UI, Async Streams, Event Merging
> **Nota:** Async/await para operaciones simples; Combine para flujos continuos
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Conceptos Core](#conceptos-core)
2. [Publisher-Subscriber Pattern](#publisher-subscriber-pattern)
3. [Debounce & Search](#debounce--search)
4. [Merge & Combine](#merge--combine)
5. [Errores Comunes](#errores-comunes)

---

## Conceptos Core

### Publisher-Subscriber Tríada

```swift
// 1. PUBLISHER (Fuente de datos)
let numberPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

// 2. OPERATORS (Transformación)
numberPublisher
    .map { _ in Int.random(in: 1...100) }  // Transformar
    .filter { $0 > 50 }  // Filtrar

// 3. SUBSCRIBER (Consumidor)
    .sink { value in
        print("Received: \(value)")
    }
```

**Flujo:**
```
Publisher emite → Operators transforman → Subscriber recibe
```

---

## Publisher-Subscriber Pattern

### AnyCancellable: Memory Management

```swift
class UserViewModel: ObservableObject {
    @Published var user: User?

    // Contenedor de suscripciones (cancellables)
    private var cancellables = Set<AnyCancellable>()

    func setup() {
        // Suscripción 1
        $user
            .dropFirst()  // Ignorar el valor inicial
            .sink { newUser in
                print("User changed: \(newUser?.name ?? "nil")")
            }
            .store(in: &cancellables)  // ✅ Guardar para limpieza posterior

        // Cuando el ViewModel muere, cancellables se limpia automáticamente
    }
}
```

**Sin .store() → Memory leak** 💥
**Con .store() → Limpieza automática** ✅

### @Published & $

```swift
class UserViewModel: ObservableObject {
    @Published var searchText: String = ""

    // $ crea un Publisher del @Published
    var searchPublisher: AnyPublisher<String, Never> {
        $searchText  // Publisher que emite cada cambio
            .eraseToAnyPublisher()
    }
}

// Uso
$searchText
    .sink { text in
        print("Búsqueda: \(text)")
    }
    .store(in: &cancellables)
```

---

## Debounce & Search

### El Patrón Clásico

```swift
@MainActor
class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [SearchResult] = []
    @Published var isSearching: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init(searchService: SearchService) {
        self.searchService = searchService
        setupSearch()
    }

    private func setupSearch() {
        $searchText
            // 1. DEBOUNCE: Esperar 500ms sin escribir
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)

            // 2. REMOVE DUPLICATES: No buscar lo mismo 2 veces
            .removeDuplicates()

            // 3. FILTER: Ignorar strings vacíos
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

            // 4. FLAT MAP: Convertir búsqueda en su resultado
            .flatMap { [weak self] query -> AnyPublisher<[SearchResult], Never> in
                self?.isSearching = true
                return self?.searchService.search(query: query)
                    .catch { error in
                        Just([])  // Si error, retornar vacío
                    }
                    .eraseToAnyPublisher()
                    ?? Just([]).eraseToAnyPublisher()
            }

            // 5. MAIN THREAD: Asegurar ejecución en UI thread
            .receive(on: DispatchQueue.main)

            // 6. ASSIGN: Asignar resultado a @Published
            .sink { [weak self] results in
                self?.results = results
                self?.isSearching = false
            }
            .store(in: &cancellables)
    }
}
```

**Timeline:**

```
Usuario escribe: "j o h n"
                j   o   h   n
Debounce:       ⏳   ⏳   ⏳   [envía "john"]
                500ms después del último carácter
```

### Versión Simplificada

```swift
$searchText
    .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
    .removeDuplicates()
    .filter { !$0.isEmpty }
    .sink { [weak self] in
        self?.performSearch($0)
    }
    .store(in: &cancellables)
```

---

## Merge & Combine

### CombineLatest: AND Logic

```swift
// Habilitar botón si email ES válido Y contraseña ES válida

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isFormValid: Bool = false

    private var cancellables = Set<AnyCancellable>()

    init() {
        setupFormValidation()
    }

    private func setupFormValidation() {
        Publishers.CombineLatest(
            $email.map { isValidEmail($0) },
            $password.map { $0.count >= 8 }
        )
        .map { isEmailValid, isPasswordValid in
            isEmailValid && isPasswordValid  // AND
        }
        .assign(to: &$isFormValid)  // Escribir en @Published
    }
}

// Uso en View
struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

    var body: some View {
        VStack {
            TextField("Email", text: $viewModel.email)
            SecureField("Password", text: $viewModel.password)

            Button("Login") { /* ... */ }
                .disabled(!viewModel.isFormValid)  // Deshabilitado si no válido
        }
    }
}
```

### Merge: OR Logic

```swift
// Actualizar vista si email cambia O si profile cambia

let emailPublisher = $email
let profilePublisher = $profile

Publishers.Merge(emailPublisher, profilePublisher)
    .sink { _ in
        print("Email o Profile cambió")
    }
    .store(in: &cancellables)
```

### ZipLatest: Pairing

```swift
// Obtener User ID y sus Preferences juntos

Publishers.Zip(
    userIDPublisher,
    preferencesPublisher
)
.sink { userId, preferences in
    print("User \(userId) has preferences: \(preferences)")
}
.store(in: &cancellables)
```

---

## Future vs Async/Await

### Cuándo usar Combine

```swift
// ✅ USAR COMBINE si:
// 1. Hay múltiples valores en el tiempo
// 2. Necesitas transformaciones complejas (debounce, merge)
// 3. Bindings complejos

class StockPriceViewModel: ObservableObject {
    @Published var priceHistory: [Double] = []

    func startPriceFeed() {
        // Emite precio cada segundo
        Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .flatMap { _ in
                self.stockService.currentPrice()
            }
            .sink { price in
                self.priceHistory.append(price)
            }
            .store(in: &cancellables)
    }
}
```

### Cuándo usar Async/Await

```swift
// ✅ USAR ASYNC/AWAIT si:
// 1. Una operación de una sola vez
// 2. Request-Response simple
// 3. Código más limpio/legible

func loadUser() async {
    do {
        let user = try await apiService.fetchUser(id: "123")
        self.user = user
    } catch {
        self.error = error
    }
}
```

---

## Errores Comunes

### Error 1: Memory Leak (No Guardar Cancellable)

```swift
// ❌ INCORRECTO
$searchText
    .sink { text in
        // Esta suscripción NUNCA se limpia → Memory leak
    }

// ✅ CORRECTO
$searchText
    .sink { text in
        // ...
    }
    .store(in: &cancellables)
```

### Error 2: Usar [self] Strong en Closure

```swift
// ❌ INCORRECTO: Crear ciclo de referencia
$email
    .sink { [self] in  // self fuerte
        print(self.email)
    }
    .store(in: &cancellables)

// ✅ CORRECTO: Weak self
$email
    .sink { [weak self] in
        print(self?.email)
    }
    .store(in: &cancellables)
```

### Error 3: FlatMap vs Map

```swift
// ❌ INCORRECTO: Map devuelve Publisher<Publisher<...>>
$searchText
    .map { query in
        searchService.search(query: query)  // Devuelve Publisher
    }
    // Result es Publisher<Publisher<...>>

// ✅ CORRECTO: FlatMap "aplana" los Publishers
$searchText
    .flatMap { query in
        searchService.search(query: query)
    }
    // Result es Publisher<...>
```

---

## Resumen: Combine Mastery

✅ **Cuándo usar Combine:**
- Debounce/Throttle
- Merge de múltiples eventos
- Transformaciones complejas
- Binding continuo de valores

✅ **Mejores Prácticas:**
- Siempre usar `[weak self]`
- Siempre `.store(in: &cancellables)`
- Prefer `async/await` para simple requests
- Use `@Published` para state

Combine es el poder reactivo de iOS. ⚡✨
