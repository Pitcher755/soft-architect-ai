# 🍏 SwiftUI Architecture: MVVM & Data Flow

> **Paradigma:** Declarativo (View as Function of State)
> **Min iOS:** 16+
> **Prohibido:** Storyboards (`.storyboard`), NIBs (`.xib`), UIKit imperative
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [La Revolución Declarativa](#la-revolución-declarativa)
2. [MVVM Trinity](#mvvm-trinity)
3. [Property Wrappers Masterclass](#property-wrappers-masterclass)
4. [Modifiers & Composition](#modifiers--composition)
5. [Navigation con NavigationStack](#navigation-con-navigationstack)
6. [Preview & Testing](#preview--testing)
7. [Errores Comunes](#errores-comunes)

---

## La Revolución Declarativa

### ¿Por Qué SwiftUI vs UIKit?

```swift
// ❌ UIKit (Imperativo - Dile QUÉ hacer paso a paso)
let button = UIButton(type: .system)
button.setTitle("Press me", for: .normal)
button.addTarget(self, action: #selector(onPressed), for: .touchUpInside)
view.addSubview(button)
// + Constraints o frames
// + Delegate methods
// + State management manual

// ✅ SwiftUI (Declarativo - Describe CUÁL es el resultado deseado)
Button("Press me") {
    // Action
}
// Estado automático, redraw automático
```

**Ventaja:** SwiftUI automáticamente redibuja la vista cuando el estado cambia. Cero callbacks.

---

## MVVM Trinity

### 1. Model (Structs)

```swift
// 📦 Datos puros e inmutables (Single Source of Truth)
struct User: Identifiable, Codable {
    let id: UUID
    let name: String
    let email: String
    let profileImage: URL?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case profileImage = "profile_image"
    }
}

// Relaciones
struct Post: Identifiable, Codable {
    let id: UUID
    let title: String
    let content: String
    let author: User
    let createdAt: Date
}
```

**Protocolos Importantes:**
- `Identifiable` - Para listas con `.id` único
- `Codable` - Para serialización JSON
- `Hashable` - Para usar en Sets/Dictionaries

### 2. ViewModel (ObservableObject)

```swift
// 🧠 Lógica de negocio + Estado de UI

@MainActor  // Asegura updates en Main Thread (seguro para UI)
class UserViewModel: ObservableObject {
    // @Published: Notifica a las vistas cuando cambia
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiService: APIService
    private let analyticsService: AnalyticsService

    init(apiService: APIService = .shared,
         analyticsService: AnalyticsService = .shared) {
        self.apiService = apiService
        self.analyticsService = analyticsService
    }

    // Async/await (elegante, asincrónico)
    func loadUser(id: String) async {
        isLoading = true
        defer { isLoading = false }

        do {
            let user = try await apiService.fetchUser(id: id)
            self.user = user
            analyticsService.track("user_loaded", properties: ["user_id": id])
        } catch let error as APIError {
            self.errorMessage = error.userMessage
            analyticsService.track("user_load_error", properties: ["error": error.localizedDescription])
        } catch {
            self.errorMessage = "Unexpected error"
        }
    }

    func logout() {
        user = nil
        isLoading = false
        errorMessage = nil
    }
}
```

**Patrón @MainActor:**
- Todos los cambios en el estado deben ocurrir en el main thread (UI thread)
- SwiftUI automáticamente observa cambios y redibuja

### 3. View (SwiftUI View)

```swift
// 👀 Rendería el estado del ViewModel

struct UserDetailView: View {
    // @StateObject: La vista es DUEÑA del ciclo de vida del ViewModel
    // Se crea UNA VEZ cuando entra la vista, se mantiene vivo mientras la vista vive
    @StateObject private var viewModel = UserViewModel()

    var body: some View {
        ZStack {
            // Loading state
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }
            // Success state
            else if let user = viewModel.user {
                ScrollView {
                    VStack(spacing: 16) {
                        // Profile image
                        if let imageURL = user.profileImage {
                            AsyncImage(url: imageURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 200)
                                        .clipped()
                                case .failure:
                                    Color.gray
                                        .frame(height: 200)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }

                        // User info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(user.name)
                                .font(.title)
                                .bold()
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()

                        Spacer()
                    }
                }
            }
            // Error state
            else if let error = viewModel.errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("Error")
                        .font(.headline)
                    Text(error)
                        .font(.body)
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        Task {
                            // Retry loading
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            // Empty state
            else {
                VStack(spacing: 16) {
                    Image(systemName: "person.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No User")
                }
            }
        }
        // .task reemplaza onAppear para async/await
        .task {
            await viewModel.loadUser(id: "user-123")
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    UserDetailView()
}
```

---

## Property Wrappers Masterclass

### @State: Local, Primitive Values

```swift
@State private var counter = 0  // Solo para VIEW LOCAL
@State private var isExpanded = false

// ❌ No usar para objetos complejos
// @State private var user: User?  // ❌ NO

// Acceso
Button("Counter: \(counter)") {
    counter += 1  // Redraw automático
}
```

### @Binding: Pass Reference Down

```swift
// Padre
struct ParentView: View {
    @State private var isOn = false

    var body: some View {
        Toggle("Switch", isOn: $isOn)  // $ = binding
        ChildView(isOn: $isOn)  // Pasar binding
    }
}

// Hijo (recibe binding)
struct ChildView: View {
    @Binding var isOn: Bool  // Referencia al padre

    var body: some View {
        if isOn {
            Text("It's ON")
        }
    }
}
```

### @StateObject: ViewModel Ownership

```swift
// Crear ViewModel (primera y única vez)
struct ScreenA: View {
    @StateObject private var viewModel = MyViewModel()
    // viewModel vive mientras ScreenA vive
}
```

### @ObservedObject: ViewModel Injection

```swift
// Pasar ViewModel existente
struct ScreenB: View {
    @ObservedObject var viewModel: MyViewModel  // Ya existe, no crear

    var body: some View {
        Text(viewModel.data)
    }
}

// Uso
let vm = MyViewModel()
ScreenB(viewModel: vm)
```

### @EnvironmentObject: Global State

```swift
// Padre (arriba en la jerarquía)
@main
struct MyApp: App {
    @StateObject private var globalState = GlobalState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(globalState)  // Disponible en todas las vistas
        }
    }
}

// Hijo (acceder sin pasar explícitamente)
struct ChildView: View {
    @EnvironmentObject var globalState: GlobalState

    var body: some View {
        Text(globalState.userName)
    }
}
```

**Resumen de Wrappers:**

| Wrapper | Scope | Uso |
|:---|:---|:---|
| `@State` | Local a View | Bools, contadores, strings simples |
| `@Binding` | Padre ↔ Hijo | Pasar referencia mutable |
| `@StateObject` | Crea ViewModel | Crear una sola vez |
| `@ObservedObject` | Recibe ViewModel | ViewModel inyectado |
| `@EnvironmentObject` | Árbol global | Datos globales (auth, tema) |

---

## Modifiers & Composition

### Modifier Chain

```swift
Text("Hello")
    .font(.headline)  // Modifier 1
    .foregroundColor(.blue)  // Modifier 2
    .padding()  // Modifier 3
    .background(Color.yellow)  // Modifier 4
    .cornerRadius(8)  // Modifier 5

// Orden IMPORTA (se aplican en secuencia)
Text("Hello")
    .padding()
    .background(Color.blue)  // Relleno azul ALREDEDOR del padding

Text("Hello")
    .background(Color.blue)  // ❌ Azul solo tras el texto
    .padding()  // Luego padding blanco
```

### Composición (Extraer Sub-Views)

```swift
// ❌ MONOLÍTICO
struct UserProfileView: View {
    let user: User

    var body: some View {
        VStack {
            // Profile header 20 líneas
            VStack {
                Image(...)
                Text(user.name)
            }

            // Stats section 15 líneas
            HStack {
                StatBox(label: "Followers", value: "1.2K")
                StatBox(label: "Following", value: "342")
            }

            // Bio section 10 líneas
            VStack {
                Text(user.bio)
            }
        }
    }
}

// ✅ COMPOSADO
struct UserProfileView: View {
    let user: User

    var body: some View {
        VStack {
            UserHeaderSection(user: user)
            UserStatsSection(user: user)
            UserBioSection(user: user)
        }
    }
}

// Subcomponentes
struct UserHeaderSection: View {
    let user: User
    var body: some View {
        VStack { /* ... */ }
    }
}
```

---

## Navigation con NavigationStack

### NavigationStack (iOS 16+)

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
        }
    }
}

struct HomeView: View {
    @State private var navigationPath: [User] = []

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(users) { user in
                NavigationLink(value: user) {
                    Text(user.name)
                }
            }
            .navigationDestination(for: User.self) { user in
                UserDetailView(user: user)
            }
        }
    }
}
```

**Ventaja:** Navegar es tipo-seguro y desacoplado.

---

## Preview & Testing

### SwiftUI Previews

```swift
struct UserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Light mode
            UserDetailView()
                .preferredColorScheme(.light)

            // Dark mode
            UserDetailView()
                .preferredColorScheme(.dark)

            // iPad
            UserDetailView()
                .previewDevice(PreviewDevice(rawValue: "iPad Pro (11-inch)"))
        }
    }
}
```

### Testing ViewModels

```swift
import XCTest

@MainActor
class UserViewModelTests: XCTestCase {
    var viewModel: UserViewModel!
    var mockAPI: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPI = MockAPIService()
        viewModel = UserViewModel(apiService: mockAPI)
    }

    func testLoadUserSuccess() async {
        // Arrange
        let expectedUser = User(id: UUID(), name: "John", email: "john@example.com", profileImage: nil)
        mockAPI.userToReturn = expectedUser

        // Act
        await viewModel.loadUser(id: "123")

        // Assert
        XCTAssertEqual(viewModel.user, expectedUser)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLoadUserError() async {
        // Arrange
        mockAPI.errorToThrow = APIError.networkFailure

        // Act
        await viewModel.loadUser(id: "123")

        // Assert
        XCTAssertNil(viewModel.user)
        XCTAssertNotNil(viewModel.errorMessage)
    }
}
```

---

## Errores Comunes

### Error 1: @State en ViewModel

```swift
// ❌ INCORRECTO
class UserViewModel: ObservableObject {
    @State var user: User?  // ❌ @State es solo para View
}

// ✅ CORRECTO
@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?  // ✅ @Published para ViewModel
}
```

### Error 2: Usar @ObservedObject en lugar de @StateObject

```swift
// ❌ INCORRECTO (ViewModel se recrea cada redraw)
struct MyView: View {
    @ObservedObject var viewModel = MyViewModel()
}

// ✅ CORRECTO (ViewModel se crea una sola vez)
struct MyView: View {
    @StateObject private var viewModel = MyViewModel()
}
```

### Error 3: No desuscribirse en Combine

```swift
// ❌ Memory leak
class UserViewModel: ObservableObject {
    private var cancellables: Set<AnyCancellable> = []

    func watchUpdates() {
        userPublisher
            .sink { /* ... */ }
            // ❌ No guardado en cancellables
    }
}

// ✅ CORRECTO
func watchUpdates() {
    userPublisher
        .sink { /* ... */ }
        .store(in: &cancellables)  // ✅ Guardado
}
```

---

## Resumen: SwiftUI Mastery

✅ **Principios:**
- View = función del Estado (Declarativo)
- @StateObject para crear, @ObservedObject para recibir
- @MainActor asegura thread safety
- Composición > Monolito

✅ **Mejores Prácticas:**
- Extraer sub-views para claridad
- Property wrappers según scope
- Previews para cada vista
- Tests en ViewModels

SwiftUI es el presente de iOS. 🍏✨
