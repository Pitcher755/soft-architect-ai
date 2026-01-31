# 🤖 Jetpack Compose: Modern Declarative UI

> **Paradigma:** Declarativo (UI = función del estado)
> **Lenguaje:** Kotlin
> **Min Android:** 5.0+ (API 21+)
> **Prohibido:** XML layouts (`activity_main.xml`), `findViewById`, old `Fragment`
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [La Revolución Declarativa](#la-revolución-declarativa)
2. [Composables Básicos](#composables-básicos)
3. [State Hoisting (Regla de Oro)](#state-hoisting-regla-de-oro)
4. [Layouts & Modifiers](#layouts--modifiers)
5. [Side Effects & LaunchedEffect](#side-effects--launchedeffect)
6. [Temas & Styling](#temas--styling)

---

## La Revolución Declarativa

### XML → Compose

```kotlin
// ❌ Viejo (XML + findViewById)
<!-- activity_main.xml -->
<LinearLayout>
    <EditText android:id="@+id/nameInput"/>
    <Button android:id="@+id/submitButton"/>
</LinearLayout>

// Java/Kotlin
class MainActivity : AppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        val nameInput = findViewById<EditText>(R.id.nameInput)
        val submitBtn = findViewById<Button>(R.id.submitButton)

        submitBtn.setOnClickListener {
            val name = nameInput.text.toString()
            // ...
        }
    }
}

// ✅ Moderno (Compose)
@Composable
fun MyScreen() {
    var name by remember { mutableStateOf("") }

    Column {
        TextField(
            value = name,
            onValueChange = { name = it }
        )
        Button(onClick = { submitForm(name) }) {
            Text("Submit")
        }
    }
}
```

**Ventajas:**
- ✅ Sin XML, todo en Kotlin
- ✅ Actualización automática (recomposition)
- ✅ Type-safe
- ✅ Preview en tiempo de compilación

---

## Composables Básicos

### Crear un Composable

```kotlin
// @Composable: Función que retorna UI
@Composable
fun GreetingCard(name: String) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(text = "Hello, $name!")
            Text(text = "Welcome to Compose")
        }
    }
}

// Usar en Activity
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            GreetingCard("John")
        }
    }
}
```

### Layouts Principales

```kotlin
@Composable
fun LayoutExamples() {
    // COLUMN: Vertical Stack
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text("Item 1")
        Text("Item 2")
        Text("Item 3")
    }

    // ROW: Horizontal Stack
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text("Left")
        Text("Right")
    }

    // BOX: Layering
    Box {
        Image(painter = painterResource(id = R.drawable.bg))
        Text("Overlay text")
    }

    // LAZYCOLUMN: RecyclerView en Compose
    LazyColumn {
        items(userList.size) { index ->
            UserListItem(userList[index])
        }
    }
}
```

### Common Widgets

```kotlin
@Composable
fun Widgets() {
    // Text
    Text("Hello", fontSize = 20.sp, fontWeight = FontWeight.Bold)

    // Button
    Button(onClick = { /* ... */ }) {
        Text("Click me")
    }

    // TextField
    var text by remember { mutableStateOf("") }
    TextField(
        value = text,
        onValueChange = { text = it },
        label = { Text("Enter name") }
    )

    // Checkbox
    var isChecked by remember { mutableStateOf(false) }
    Checkbox(checked = isChecked, onCheckedChange = { isChecked = it })

    // Image
    Image(painter = painterResource(id = R.drawable.ic_launcher), contentDescription = "")

    // Card
    Card(modifier = Modifier.padding(8.dp)) {
        Text("Card content")
    }
}
```

---

## State Hoisting (Regla de Oro)

### ❌ Stateful (Incorrecto)

```kotlin
// ❌ BAD: Composable estateful, difícil de testear/reusar
@Composable
fun Counter() {
    var count by remember { mutableStateOf(0) }

    Column {
        Text("Count: $count")
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}

// Problema: ¿Cómo testear? ¿Cómo pasar el estado a otro composable?
```

### ✅ Stateless (Correcto)

```kotlin
// ✅ GOOD: Composable stateless, altamente reutilizable
@Composable
fun Counter(count: Int, onIncrement: () -> Unit) {
    Column {
        Text("Count: $count")
        Button(onClick = onIncrement) {
            Text("Increment")
        }
    }
}

// El padre gestiona el estado
@Composable
fun CounterScreen() {
    var count by remember { mutableStateOf(0) }
    Counter(count = count, onIncrement = { count++ })
}

// Reutilizable y testeable
@Preview
@Composable
fun CounterPreview() {
    Counter(count = 5, onIncrement = {})
}
```

**Regla:** Los datos fluyen HACIA ABAJO, los eventos suben HACIA ARRIBA.

```
Padre
├── estado (count)
│
Child(count = 10, onIncrement = { count++ })
├── Lee count
├── Dispara onIncrement
│
Padre recibe evento y actualiza estado
```

---

## Layouts & Modifiers

### Modifiers Chain

```kotlin
Text("Hello")
    .padding(16.dp)  // Padding interior
    .background(Color.Blue)  // Fondo
    .clickable { /* ... */ }  // Clickeable
    .fillMaxWidth()  // Ancho máximo
    .height(100.dp)  // Alto fijo

// Orden IMPORTA:
// padding ANTES de background → padding blanco + fondo azul
// padding DESPUÉS de background → solo azul
```

### Size & Padding

```kotlin
@Composable
fun SizeExamples() {
    // Tamaño fijo
    Box(modifier = Modifier.size(100.dp))

    // Ancho máximo
    Box(modifier = Modifier.fillMaxWidth())

    // Altura máxima
    Box(modifier = Modifier.fillMaxHeight())

    // Llenar pantalla
    Box(modifier = Modifier.fillMaxSize())

    // Padding (interno)
    Box(modifier = Modifier.padding(16.dp))

    // Aspecto ratio
    Box(modifier = Modifier.aspectRatio(1f))

    // Offset
    Box(modifier = Modifier.offset(x = 10.dp, y = 5.dp))
}
```

### Common Modifiers

```kotlin
@Composable
fun ModifierExamples() {
    // Background + Border
    Text("Hello", modifier = Modifier
        .background(color = Color.LightGray, shape = RoundedCornerShape(8.dp))
        .border(2.dp, Color.Black, RoundedCornerShape(8.dp))
        .padding(8.dp)
    )

    // Shadow
    Box(modifier = Modifier.shadow(elevation = 8.dp))

    // Clickable
    Text("Clickable", modifier = Modifier.clickable {
        println("Clicked!")
    })

    // Alignment
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        Text("Centered")
    }
}
```

---

## Side Effects & LaunchedEffect

### LaunchedEffect: Ejecutar Código Suspendido

```kotlin
@Composable
fun UserScreen(userId: String, viewModel: UserViewModel) {
    // Se ejecuta cuando userId cambia (o al entrar a pantalla)
    LaunchedEffect(userId) {
        viewModel.loadUser(userId)  // Suspend function
    }

    // UI
    when (val state = viewModel.uiState.collectAsState().value) {
        is UiState.Loading -> ProgressBar()
        is UiState.Success -> UserCard(state.user)
        is UiState.Error -> ErrorCard(state.message)
    }
}

// Limpieza automática si userId cambia o composable se desmonta
```

### remember: Mantener Estado Entre Recomposiciones

```kotlin
@Composable
fun Stopwatch() {
    // ✅ elapsed se mantiene entre recomposiciones
    var elapsed by remember { mutableStateOf(0L) }

    // ❌ Sin remember, elapsed se reinicia cada render
    // var elapsed = 0L

    LaunchedEffect(Unit) {  // Ejecutar UNA VEZ
        while (true) {
            delay(1000)
            elapsed += 1
        }
    }

    Text("Time: $elapsed seconds")
}
```

### DisposableEffect: Cleanup

```kotlin
@Composable
fun LocationScreen() {
    DisposableEffect(Unit) {
        // Setup
        val locationListener = LocationListener { location ->
            println("Location: $location")
        }
        LocationManager.registerListener(locationListener)

        // Cleanup (cuando composable se desmonta)
        onDispose {
            LocationManager.unregisterListener(locationListener)
        }
    }
}
```

---

## Temas & Styling

### Material 3 Theme

```kotlin
@Composable
fun MyApp() {
    MaterialTheme(
        colorScheme = lightColorScheme(
            primary = Color(0xFF6200EE),
            onPrimary = Color.White,
            secondary = Color(0xFF03DAC6),
        ),
        typography = Typography(
            headlineSmall = TextStyle(fontSize = 24.sp, fontWeight = FontWeight.Bold),
            bodyMedium = TextStyle(fontSize = 14.sp),
        )
    ) {
        MyScreen()
    }
}

// Usar tema
@Composable
fun MyScreen() {
    Text(
        "Headline",
        style = MaterialTheme.typography.headlineSmall,
        color = MaterialTheme.colorScheme.primary
    )
}
```

### Dark Mode

```kotlin
@Composable
fun MyApp() {
    val isDarkMode = isSystemInDarkTheme()

    val colorScheme = if (isDarkMode) {
        darkColorScheme(
            primary = Color(0xFFBB86FC),
            surface = Color(0xFF121212)
        )
    } else {
        lightColorScheme(
            primary = Color(0xFF6200EE),
            surface = Color.White
        )
    }

    MaterialTheme(colorScheme = colorScheme) {
        MyScreen()
    }
}
```

---

## Resumen: Compose Mastery

✅ **Principios:**
- Composables son funciones puras
- Estado fluye hacia abajo, eventos hacia arriba
- `remember` para mantener estado entre renders
- `LaunchedEffect` para side effects

✅ **Mejores Prácticas:**
- State Hoisting siempre
- Composables pequeños y reutilizables
- Usar `@Preview` para testing visual
- Prefer `Flow` para async data

Jetpack Compose es el presente de Android. 🤖✨
