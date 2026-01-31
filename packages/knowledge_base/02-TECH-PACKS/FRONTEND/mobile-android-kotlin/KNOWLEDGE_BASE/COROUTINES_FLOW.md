# 🌊 Kotlin Coroutines & Flow: Structured Concurrency

> **Concepto:** Lightweight threads, non-blocking async
> **Scope:** Lifecycle-aware (`viewModelScope`, `lifecycleScope`)
> **Min API:** 21+
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Coroutines Basics](#coroutines-basics)
2. [Suspend Functions](#suspend-functions)
3. [Dispatchers](#dispatchers)
4. [ViewModel Scope](#viewmodel-scope)
5. [Flow: Cold Streams](#flow-cold-streams)
6. [StateFlow & SharedFlow](#stateflow--sharedflow)
7. [Error Handling](#error-handling)

---

## Coroutines Basics

### ¿Por Qué Coroutines?

```kotlin
// ❌ Viejo: Callbacks Hell
apiService.getUser("123", object : Callback<User> {
    override fun onSuccess(user: User) {
        apiService.getPosts(user.id, object : Callback<List<Post>> {
            override fun onSuccess(posts: List<Post>) {
                // Nesting profundo = legibilidad mala
                println("User: ${user.name}, Posts: ${posts.size}")
            }

            override fun onError(error: Throwable) {
                // Manejo de error duplicado
            }
        })
    }

    override fun onError(error: Throwable) { }
})

// ✅ Moderno: Coroutines (código secuencial, no bloqueante)
viewModelScope.launch {
    try {
        val user = apiService.getUser("123")
        val posts = apiService.getPosts(user.id)
        println("User: ${user.name}, Posts: ${posts.size}")
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}
```

---

## Suspend Functions

### Qué son Suspend Functions

```kotlin
// "suspend" = puede pausar sin bloquear el hilo
suspend fun fetchUser(id: String): User {
    // Retorna el resultado después de esperar (sin bloquear)
    return withContext(Dispatchers.IO) {
        apiService.getUser(id)  // Llamada de red
    }
}

// Uso: Solo dentro de una corrutina
viewModelScope.launch {
    val user = fetchUser("123")  // ✅ Funciona
}

// ❌ No se puede llamar desde contexto síncrono
// val user = fetchUser("123")  // ❌ Error de compilación
```

### withContext: Cambiar Dispatcher

```kotlin
suspend fun loadData(): String {
    // Por defecto en Main thread

    val result = withContext(Dispatchers.IO) {
        // Cambiar a IO thread para operación de red
        apiService.fetchData()
    }
    // Vuelve a Main thread automáticamente

    return result
}
```

---

## Dispatchers

### Tres Dispatchers Principales

```kotlin
// 1. Dispatchers.Main: UI thread (actualizar UI)
viewModelScope.launch(Dispatchers.Main) {
    updateUI()  // Seguro para UI
}

// 2. Dispatchers.IO: Network/Database I/O
viewModelScope.launch(Dispatchers.IO) {
    val data = apiService.fetchData()  // No bloquea Main
}

// 3. Dispatchers.Default: CPU-intensive
viewModelScope.launch(Dispatchers.Default) {
    val result = heavyComputation()  // No bloquea Main
}
```

### Conversión Entre Threads

```kotlin
suspend fun processUserData(userId: String): User {
    // 1. Cambiar a IO (red)
    val apiData = withContext(Dispatchers.IO) {
        apiService.getUser(userId)
    }

    // 2. Cambiar a Default (procesamiento)
    val processed = withContext(Dispatchers.Default) {
        val normalized = apiData.name.uppercase()
        val validated = validateEmail(apiData.email)
        apiData.copy(name = normalized)
    }

    // 3. Vuelve a Main (UI updates)
    return processed
}
```

---

## ViewModel Scope

### Lifecycle-Aware Coroutines

```kotlin
class UserViewModel : ViewModel() {
    private val _user = MutableLiveData<User>()
    val user: LiveData<User> = _user

    fun loadUser(id: String) {
        // viewModelScope = cancela automáticamente si ViewModel muere
        viewModelScope.launch {
            try {
                val userData = apiService.getUser(id)
                _user.value = userData
            } catch (e: Exception) {
                // Manejo de error
            }
        }
    }

    // Limpieza automática en onCleared()
    override fun onCleared() {
        super.onCleared()
        // viewModelScope.coroutineContext.cancel()  // Automático
    }
}

// Uso en Activity/Fragment
class UserActivity : AppCompatActivity() {
    private val viewModel: UserViewModel by viewModels()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        viewModel.user.observe(this) { user ->
            displayUser(user)
        }

        viewModel.loadUser("123")
    }
}
```

### launch vs async

```kotlin
// launch: "fire and forget"
viewModelScope.launch {
    apiService.uploadData()  // No esperar resultado
}

// async: "esperar resultado"
viewModelScope.launch {
    val result = async { apiService.fetchData() }.await()
    _data.value = result
}

// Múltiples async en paralelo
viewModelScope.launch {
    val user = async { apiService.getUser("123") }
    val posts = async { apiService.getPosts("123") }

    // Esperar ambos
    val userData = user.await()
    val postData = posts.await()
}
```

---

## Flow: Cold Streams

### Qué es Flow

```kotlin
// Flow emite múltiples valores en el tiempo
fun getLocationUpdates(): Flow<Location> {
    return flow {
        while (true) {
            val location = getCurrentLocation()
            emit(location)  // Emitir valor
            delay(1000)  // Cada segundo
        }
    }
}

// Usar Flow
viewModelScope.launch {
    getLocationUpdates()
        .collect { location ->
            println("Location: $location")
        }
}
```

### Flow Operators

```kotlin
// map: Transformar cada valor
fun getUserFlow(): Flow<User> {
    return apiService.getUsersFlow()
        .map { user ->
            user.copy(name = user.name.uppercase())
        }
}

// filter: Filtrar valores
val activeUsersFlow = getUsersFlow()
    .filter { user -> user.isActive }

// debounce: Esperar antes de emitir
val searchFlow = searchQueryFlow
    .debounce(300)  // Esperar 300ms sin nuevos valores

// distinctUntilChanged: Ignorar duplicados
val locationFlow = getLocationUpdates()
    .distinctUntilChanged()

// flatMapLatest: Solo usar el último valor
val user = userIdFlow
    .flatMapLatest { id ->
        apiService.getUserFlow(id)
    }

// combineLatest: Combinar dos flujos
val userWithPosts = combine(
    userFlow,
    postsFlow
) { user, posts ->
    Pair(user, posts)
}

// catch: Manejo de errores
userFlow
    .catch { e ->
        println("Error: ${e.message}")
    }
    .collect { user -> /* ... */ }
```

---

## StateFlow & SharedFlow

### StateFlow: Single Current State

```kotlin
class UserViewModel : ViewModel() {
    // StateFlow: tiene un valor actual, multicasting
    private val _state = MutableStateFlow<UiState>(UiState.Loading)
    val state: StateFlow<UiState> = _state.asStateFlow()

    fun loadUser(id: String) {
        viewModelScope.launch {
            _state.value = UiState.Loading

            try {
                val user = apiService.getUser(id)
                _state.value = UiState.Success(user)
            } catch (e: Exception) {
                _state.value = UiState.Error(e.message)
            }
        }
    }
}

// En View (Compose)
@Composable
fun UserScreen(viewModel: UserViewModel) {
    val state by viewModel.state.collectAsState()

    when (state) {
        is UiState.Loading -> ProgressBar()
        is UiState.Success -> UserCard((state as UiState.Success).user)
        is UiState.Error -> ErrorCard((state as UiState.Error).message)
    }
}
```

### SharedFlow: Event Broadcasting

```kotlin
// SharedFlow para eventos (sin estado anterior)
class EventBus {
    private val _events = MutableSharedFlow<Event>()
    val events: SharedFlow<Event> = _events.asSharedFlow()

    suspend fun emit(event: Event) {
        _events.emit(event)
    }
}

// Uso
viewModelScope.launch {
    eventBus.events
        .filter { it is Event.UserDeleted }
        .collect { event ->
            println("User deleted!")
        }
}
```

---

## Error Handling

### Try-Catch en Corrutinas

```kotlin
viewModelScope.launch {
    try {
        val user = apiService.getUser("123")
        _user.value = user
    } catch (e: HttpException) {
        _error.value = "HTTP Error: ${e.code()}"
    } catch (e: IOException) {
        _error.value = "Network error"
    } catch (e: Exception) {
        _error.value = "Unknown error"
    }
}
```

### Flow Error Handling

```kotlin
userFlow
    .catch { e ->
        // Manejo de error
        _error.value = e.message
        emit(User())  // O emitir valor por defecto
    }
    .collect { user -> /* ... */ }

// Alternativamente
userFlow
    .catch { e -> println("Error: $e") }
    .retry(3)  // Reintentar 3 veces
    .collect { user -> /* ... */ }
```

---

## Ejemplo Completo: User Search

```kotlin
class SearchViewModel : ViewModel() {
    private val _searchQuery = MutableStateFlow("")
    private val _results = MutableStateFlow<List<User>>(emptyList())

    val results: StateFlow<List<User>> = _results.asStateFlow()

    init {
        viewModelScope.launch {
            _searchQuery
                .debounce(300)  // Esperar 300ms
                .distinctUntilChanged()
                .filter { it.isNotEmpty() }  // Ignorar vacíos
                .flatMapLatest { query ->
                    apiService.searchUsers(query)  // Llamada de red
                        .catch { e ->
                            _results.value = emptyList()
                            emit(emptyList())
                        }
                }
                .collect { users ->
                    _results.value = users
                }
        }
    }

    fun updateQuery(query: String) {
        _searchQuery.value = query
    }
}

// En UI
@Composable
fun SearchScreen(viewModel: SearchViewModel) {
    var query by remember { mutableStateOf("") }
    val results by viewModel.results.collectAsState()

    Column {
        TextField(
            value = query,
            onValueChange = {
                query = it
                viewModel.updateQuery(it)
            }
        )

        LazyColumn {
            items(results) { user ->
                UserListItem(user)
            }
        }
    }
}
```

---

## Resumen: Coroutines Mastery

✅ **Principios:**
- `suspend` = pausa sin bloquear
- `Dispatchers` para cambiar contexto
- `viewModelScope` para lifecycle-aware
- `Flow` para streams continuos

✅ **Mejores Prácticas:**
- Siempre usar `viewModelScope` (nunca `GlobalScope`)
- `StateFlow` para estado UI
- `Flow` con `collect` para streams
- Manejo de errores con `try-catch` o `.catch()`

Coroutines son el alma asincrónica de Kotlin/Android. 🌊✨
