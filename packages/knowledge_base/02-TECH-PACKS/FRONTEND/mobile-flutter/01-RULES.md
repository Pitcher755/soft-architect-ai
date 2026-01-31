# 📏 Tech Governance Rules: Flutter & Dart

> **Framework:** Flutter 3.19+
> **Lenguaje:** Dart 3.0+ (Sound Null Safety)
> **Objetivo:** Evitar "Widget Hell" y mantener código limpio, tipado, mantenible

Reglas estáticas de calidad para proyectos Flutter en SoftArchitect. **Estas son obligatorias, no opcionales.**

---

## 📖 Tabla de Contenidos

- [1. Convenciones de Naming (Dart Style Guide)](#1-convenciones-de-naming-dart-style-guide)
- [2. Principios Arquitectónicos](#2-principios-arquitectónicos)
- [3. Gestión de Estado (Riverpod)](#3-gestión-de-estado-riverpod)
- [4. Patrones de Seguridad](#4-patrones-de-seguridad)
- [5. Linting & Analysis](#5-linting--analysis)
- [6. Developer Checklist](#6-developer-checklist)

---

## 1. Convenciones de Naming (Dart Style Guide)

### Tabla de Convenciones

| Elemento | Convención | Ejemplo | Descripción |
|:---|:---|:---|:---|
| **Archivos Dart** | `snake_case.dart` | `user_profile_screen.dart` | Minúsculas, guiones bajos. |
| **Clases** | `PascalCase` | `UserProfileScreen`, `LoginNotifier` | Siempre mayúscula inicial. |
| **Variables** | `lowerCamelCase` | `isLoading`, `userName`, `userController` | Descriptivo, camelCase. |
| **Constantes** | `lowerCamelCase` o `k` prefix | `kAnimationDuration`, `pageSize` | Prefix `k` es opcional pero común. |
| **Enums** | `PascalCase` (tipo) + `lowerCamelCase` (valores) | `enum UserRole { admin, user }` | Tipo Pascal, valores camel. |
| **Imports** | `snake_case` paths | `import 'features/auth/data/...';` | Rutas relativas, snake_case. |
| **Private members** | Prefix `_` | `_privateField`, `_buildUI()` | Underscore para privados. |

### Ejemplos Expandidos

```dart
// ✅ GOOD: Naming correcto
class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(userProfileControllerProvider);
    return _buildUI(isLoading);
  }

  Widget _buildUI(AsyncValue<User> state) {
    return state.when(
      data: (user) => Text(user.name),
      loading: () => const CircularProgressIndicator(),
      error: (err, st) => Text('Error: $err'),
    );
  }
}

// ❌ BAD: Violaciones de naming
class userprofile extends StatefulWidget {  // Debe ser PascalCase
  final String user_id;  // Debe ser userId (camelCase)

  final isLoading;  // Debe tener tipo explícito

  @override
  State createState() => _userprofileState();  // Debe ser PascalCase
}

class _userprofileState extends State<userprofile> {
  bool loading = false;  // Poco descriptivo, debe ser isLoading

  void GetUser() {  // Debe ser getUser (camelCase)
    setState(() {
      loading = true;
    });
  }
}
```

---

## 2. Principios Arquitectónicos

### Regla #1: Feature-First Architecture (NO Layer-Based)

**Definición:** Organizar proyecto por **funcionalidad** (feature), no por tipo de archivo.

```
❌ BAD: Layer-based (Evitar)
lib/
├── models/
│   ├── user.dart
│   ├── product.dart
│   └── order.dart
├── screens/
│   ├── login_screen.dart
│   ├── home_screen.dart
│   └── product_screen.dart
├── controllers/
│   ├── user_controller.dart
│   ├── product_controller.dart
│   └── order_controller.dart

✅ GOOD: Feature-first (Usar)
lib/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── user_repository.dart
│   │   │   └── remote_data_source.dart
│   │   ├── domain/
│   │   │   └── user_entity.dart
│   │   └── presentation/
│   │       ├── login_screen.dart
│   │       ├── register_screen.dart
│   │       └── controllers/
│   │           └── auth_controller.dart
│   └── products/
│       ├── data/
│       ├── domain/
│       └── presentation/
```

**Por qué:** Un junior ve `features/auth/` y sabe exactamente dónde está todo relacionado a autenticación. Escalabilidad sin límite.

### Regla #2: Immutability (Siempre)

**Definición:** Todas las clases de Estado, DTOs y Modelos deben ser `@immutable` y final.

```dart
// ✅ GOOD: Immutable with freezed
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required int id,
    required String email,
    required String name,
    @Default(false) bool isActive,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

// ✅ GOOD: Immutable sin freezed (fallback)
@immutable
class User {
  final int id;
  final String email;

  const User({
    required this.id,
    required this.email,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ email.hashCode;
}

// ❌ BAD: Mutable class (Evitar)
class User {
  int id;
  String email;
  String name;

  User({required this.id, required this.email, required this.name});
}
```

### Regla #3: Composición over Inheritance

**Definición:** Flutter favorece composición. Evitar herencia profunda de Widgets.

```dart
// ❌ BAD: Herencia profunda
class BaseButton extends StatelessWidget {
  const BaseButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(onPressed: () {}, child: Text(label));
  }
}

class PrimaryButton extends BaseButton {
  const PrimaryButton({required String label}) : super(label: label);
}

class SecondaryButton extends PrimaryButton {  // Herencia triple!
  const SecondaryButton({required String label}) : super(label: label);
}

// ✅ GOOD: Composición
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final ButtonStyle? style;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: style ?? _primaryButtonStyle(),
      child: Text(label),
    );
  }

  static ButtonStyle _primaryButtonStyle() => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
  );
}

// Uso: Composición flexible
CustomButton(
  label: "Click me",
  onPressed: () {},
  style: _primaryButtonStyle(),
)
```

### Regla #4: Null Safety (Strict)

**Definición:** Prohibido usar `!` (bang operator) sin 100% garantía. Usar `?` y `??`.

```dart
// ✅ GOOD: Null-safe patterns
String? getName(User? user) {
  // Opción 1: ?. (conditional access)
  return user?.name;

  // Opción 2: ?? (coalesce)
  return user?.name ?? 'Unknown';

  // Opción 3: guard clause
  if (user == null) return 'Unknown';
  return user.name;
}

// ❌ BAD: Bang operator (Evitar)
String getName(User? user) {
  return user!.name;  // Crash en runtime si user es null!
}

// ❌ BAD: Unsafe lateinate
late String username;
// ... si username no se inicializa antes de usar, crash!
```

---

## 3. Gestión de Estado (Riverpod)

### Regla #1: Usar @riverpod Anotación (Code Gen)

**Definición:** Riverpod 2.0 con generación de código automática.

```dart
// ✅ GOOD: @riverpod con FutureOr (lazy loading)
@riverpod
Future<User> userProfile(UserProfileRef ref, int userId) async {
  return await ref.read(userRepositoryProvider).getUser(userId);
}

// ✅ GOOD: @riverpod para simple providers
@riverpod
String apiBaseUrl(ApiBaseUrlRef ref) {
  return 'https://api.example.com';
}

// ✅ GOOD: AsyncNotifier para lógica compleja
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthState> build() async {
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      return AuthState.authenticated(user);
    });
  }
}

// ❌ BAD: StateNotifier (Riverpod <2.0, deprecated)
class OldAuthNotifier extends StateNotifier<AuthState> {
  // Evitar: menos seguro, más boilerplate
}

// ❌ BAD: Provider sin tipado
final userProvider = FutureProvider((ref) async {  // ¿Qué tipo devuelve?
  return ref.read(userRepositoryProvider).getUser(1);
});
```

### Regla #2: Jamás setState para lógica

**Definición:** `setState` solo para animaciones efímeras o cambios locales de UI (checkbox, expandable).

```dart
// ✅ GOOD: Lógica en Riverpod
@riverpod
class IsExpandedController extends _$IsExpandedController {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

class ExpandableCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isExpanded = ref.watch(isExpandedControllerProvider);
    return GestureDetector(
      onTap: () => ref.read(isExpandedControllerProvider.notifier).toggle(),
      child: AnimatedSize(
        duration: Duration(milliseconds: 300),
        child: isExpanded ? Text('Content') : SizedBox.shrink(),
      ),
    );
  }
}

// ❌ BAD: setState para lógica
class ExpandableCard extends StatefulWidget {
  @override
  State<ExpandableCard> createState() => _ExpandableCardState();
}

class _ExpandableCardState extends State<ExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => isExpanded = !isExpanded),  // Anti-patrón!
      child: // ...
    );
  }
}
```

---

## 4. Patrones de Seguridad

### 🔒 Patrón #1: BuildContext Safety

**Definición:** Nunca usar `BuildContext` en métodos async después de `await` sin `mounted`.

```dart
// ✅ GOOD: Verificar mounted
void _showLoadingDialog(BuildContext context) async {
  showDialog(context: context, builder: (_) => LoadingDialog());
  await _performAsyncWork();
  // BuildContext puede ser inválido (widget desmontado)
  if (mounted && context.mounted) {
    Navigator.pop(context);
  }
}

// ❌ BAD: Usar BuildContext después de await
void _showLoadingDialog(BuildContext context) async {
  showDialog(context: context, builder: (_) => LoadingDialog());
  await _performAsyncWork();
  Navigator.pop(context);  // CRASH si widget fue desmontado!
}
```

### 🔒 Patrón #2: Error Handling en Async

**Definición:** Capturar errores explícitamente. Nunca ignorar excepciones.

```dart
// ✅ GOOD: Manejo explícito
@riverpod
class LoginController extends _$LoginController {
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).login(email, password);
      return AuthState.authenticated(user);
    });
  }
}

// ❌ BAD: Ignorar errores
Future<void> login() async {
  try {
    await authRepository.login(email, password);
  } catch (e) {
    // No hacer nada, silent fail!
  }
}
```

---

## 5. Linting & Analysis

### Tool Chain (Obligatorio)

| Tool | Propósito | Config |
|:---|:---|:---|
| **flutter_lints** (o **very_good_analysis**) | Análisis estática de código | `analysis_options.yaml` |
| **Dart formatter** | Formato automático (integrado en SDK) | Automático |
| **IDE support** | Warnings en tiempo real | VS Code Flutter extension |

### Verificación Local

```bash
# Análisis estática
flutter analyze

# Formatear código
dart format lib/

# Correr linter + format juntos
dart fix --apply && dart format lib/

# Build para verificar
flutter build apk --no-obfuscate  # (Android)
flutter build ios                  # (iOS)
```

### analysis_options.yaml (SoftArchitect estándar)

```yaml
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    - avoid_print
    - prefer_const_constructors
    - prefer_final_in_for_each
    - unnecessary_await_in_return
    - sized_box_for_whitespace
```

---

## 6. Developer Checklist

**Antes de hacer PUSH, verifica:**

- [ ] ✅ Ejecuté `flutter analyze` sin errores o warnings ignorables
- [ ] ✅ Ejecuté `dart format lib/` (código está formateado)
- [ ] ✅ Todas las clases son `@immutable` (o `@freezed`)
- [ ] ✅ Feature-first architecture: carpetas por funcionalidad
- [ ] ✅ Riverpod providers tipados (no dynamic)
- [ ] ✅ NO usé `setState` para lógica de negocio
- [ ] ✅ Null-safe: sin `!` operator sin justificación
- [ ] ✅ Manejé errores explícitamente en async functions
- [ ] ✅ Verifico `mounted` / `context.mounted` después de async
- [ ] ✅ Escribí tests unitarios (>80% coverage en lógica)
- [ ] ✅ No hay `print()` en src/ (usar logger)
- [ ] ✅ Documenté funciones públicas con docstring

---

**Última Actualización:** 30/01/2026
**Versión de Reglas:** 1.0
**Enforcement:** Analysis + Pre-commit hooks
