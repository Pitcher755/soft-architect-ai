# 🌟 Best Practices: Flutter & Riverpod 2.0

> **Versión:** 1.0
> **Framework:** Flutter 3.19+ + Riverpod 2.0
> **Lenguaje:** Dart 3.0+ (Sound Null Safety)
> **Objetivo:** Patrones modernos para generación de código UI robusto

Snippets de oro. El RAG usa estos para entender cómo escribir Flutter "The SoftArchitect Way".

---

## 📖 Tabla de Contenidos

- [1. Gestión de Estado (Riverpod 2.0 + AsyncValue)](#1-gestión-de-estado-riverpod-20--asyncvalue)
- [2. Consumo en Widgets (ConsumerWidget)](#2-consumo-en-widgets-consumerwidget)
- [3. Navegación (GoRouter)](#3-navegación-gorouter)
- [4. Repository Pattern](#4-repository-pattern)
- [5. Model Design (@freezed)](#5-model-design-freezed)
- [6. Error Handling](#6-error-handling)
- [7. Testing (AAA Pattern)](#7-testing-aaa-pattern)
- [8. Performance Optimization](#8-performance-optimization)

---

## 1. Gestión de Estado (Riverpod 2.0 + AsyncValue)

### ❌ Anti-Pattern (Evitar)

```dart
// BAD: setState (Spaghetti code)
class LoginScreen extends StatefulWidget {
  @override
  State createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLoading = false;
  String? error;
  User? user;

  void _login() async {
    setState(() => isLoading = true);
    try {
      final user = await authService.login(email, password);
      setState(() {
        this.user = user;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return CircularProgressIndicator();
    if (error != null) return Text('Error: $error');
    if (user != null) return UserProfile(user: user!);
    return LoginForm(onLogin: _login);
  }
}
```

### ✅ Golden Standard (Riverpod 2.0 with Code Gen)

```dart
// GOOD: @riverpod AsyncNotifier (Clean, Safe, Testable)
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<AuthState> build() async {
    // Check if user is already logged in (persistent)
    final token = await ref.read(tokenStorageProvider).getToken();
    if (token != null) {
      return AuthState.authenticated(User(id: 'user-id'));
    }
    return const AuthState.unauthenticated();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(httpClientProvider).post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final user = User.fromJson(response.data);

      // Persist token
      await ref.read(tokenStorageProvider).saveToken(response.data['token']);

      return AuthState.authenticated(user);
    });
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await ref.read(tokenStorageProvider).deleteToken();
    state = const AsyncValue.data(AuthState.unauthenticated());
  }
}

// State enum with freezed
@freezed
class AuthState with _$AuthState {
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.error(String message) = _Error;
}

// Generated providers for convenience
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authControllerProvider).maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authControllerProvider).maybeWhen(
    authenticated: (user) => user,
    orElse: () => null,
  );
});
```

### AsyncValue Handling

```dart
// AsyncValue tiene 3 estados: loading, data, error
final userState = ref.watch(userProfileControllerProvider);

userState.when(
  data: (user) => UserCard(user: user),           // Success
  loading: () => const LoadingSpinner(),          // Loading
  error: (error, stackTrace) => ErrorWidget(      // Error
    error: error.toString(),
    retry: () => ref.refresh(userProfileControllerProvider),
  ),
);
```

---

## 2. Consumo en Widgets (ConsumerWidget)

### ❌ Anti-Pattern (Evitar)

```dart
// BAD: StatefulWidget con Riverpod (mezcla paradigmas)
class UserScreen extends StatefulWidget {
  @override
  State createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  late final WidgetRef ref; // No se puede acceder a ref en StatefulWidget!

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### ✅ Golden Standard

```dart
// GOOD: ConsumerWidget (auto acceso a WidgetRef)
class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProfileControllerProvider(userId));
    final authState = ref.watch(authControllerProvider);

    return userState.when(
      data: (user) => _buildContent(context, ref, user),
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, st) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileControllerProvider(userId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, User user) {
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            UserAvatar(user: user),
            UserInfo(user: user),
            ElevatedButton(
              onPressed: () => ref.read(authControllerProvider.notifier).logout(),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

// GOOD: ConsumerStatefulWidget (si necesitas animaciones locales)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen();

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: Duration(milliseconds: 500), vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchProviderFamily(_queryController.text));

    return // ...
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 3. Navegación (GoRouter)

### ✅ Golden Standard

```dart
// GOOD: GoRouter configuration with type-safe routes
@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final isLoggedIn = ref.watch(isLoggedInProvider);

  return GoRouter(
    initialLocation: isLoggedIn ? '/home' : '/login',
    redirect: (context, state) {
      // Global redirect logic
      if (!isLoggedIn && state.matchedLocation != '/login') {
        return '/login';
      }
      return null; // No redirect, proceed
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          return UserProfileScreen(userId: userId);
        },
      ),
    ],
  );
}

// Usage in main.dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData.light(),
    );
  }
}

// Navigation example
// In any ConsumerWidget:
context.go('/profile/${user.id}');
context.push('/profile/${user.id}'); // Push (with back)
context.pop(); // Pop
```

---

## 4. Repository Pattern

### ✅ Golden Standard

```dart
// GOOD: Domain interface (pure Dart)
abstract class IUserRepository {
  Future<User> getUserById(String userId);
  Future<void> updateUser(User user);
}

// GOOD: Implementation (with Data Layer)
class UserRepository implements IUserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;

  UserRepository({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User> getUserById(String userId) async {
    try {
      // Try remote first
      final userModel = await remoteDataSource.getUser(userId);
      final user = userModel.toEntity();

      // Cache locally
      await localDataSource.cacheUser(user);

      return user;
    } on ServerException catch (e) {
      // Fallback to local cache
      final cachedUser = await localDataSource.getUser(userId);
      if (cachedUser != null) {
        return cachedUser;
      }
      throw RepositoryException(e.message);
    }
  }

  @override
  Future<void> updateUser(User user) async {
    await remoteDataSource.updateUser(user.toModel());
    await localDataSource.cacheUser(user);
  }
}

// GOOD: Riverpod provider for repository
@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  return UserRepository(
    remoteDataSource: UserRemoteDataSource(ref.read(httpClientProvider)),
    localDataSource: UserLocalDataSource(ref.read(hiveBoxProvider)),
  );
}
```

---

## 5. Model Design (@freezed)

### ✅ Golden Standard

```dart
// GOOD: @freezed immutable model with JSON serialization
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String name,
    @Default(false) bool isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _User;

  factory User.fromJson(Map<String, Object?> json) => _$UserFromJson(json);
}

// GOOD: Usage
final user = User(
  id: '1',
  email: 'john@example.com',
  name: 'John Doe',
);

// Freezed gives you:
// - Immutability
// - Equality (user == user2)
// - copyWith() for immutable updates
final updatedUser = user.copyWith(name: 'Jane Doe');
// - toString() (human-readable)
print(user); // User(id: 1, email: john@..., ...)
// - JSON serialization (toJson/fromJson)
final json = user.toJson();
```

---

## 6. Error Handling

### ✅ Golden Standard

```dart
// GOOD: Custom exceptions with meaningful types
sealed class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class RepositoryException extends AppException {
  RepositoryException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class ValidationException extends AppException {
  ValidationException(String message) : super(message);
}

// GOOD: Use in repository
class AuthRepository implements IAuthRepository {
  Future<User> login(String email, String password) async {
    try {
      if (!_isValidEmail(email)) {
        throw ValidationException('Invalid email format');
      }

      final response = await _httpClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw NetworkException('Network error: ${e.message}');
    } on AppException {
      rethrow; // Custom exception, propagate
    } catch (e) {
      throw RepositoryException('Unknown error: $e');
    }
  }
}

// GOOD: Handle in UI with AsyncValue.guard()
state = await AsyncValue.guard(() async {
  final user = await repository.login(email, password);
  return AuthState.authenticated(user);
});
// AsyncValue catches exceptions automatically
```

---

## 7. Testing (AAA Pattern)

### ✅ Unit Test

```dart
// tests/unit/domain/usecases/test_login_usecase.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('LoginUseCase', () {
    late MockUserRepository mockUserRepository;
    late LoginUseCase loginUseCase;

    setUp(() {
      mockUserRepository = MockUserRepository();
      loginUseCase = LoginUseCase(mockUserRepository);
    });

    test('execute returns User when login is successful', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final expectedUser = User(
        id: '1',
        email: email,
        name: 'Test User',
      );

      when(mockUserRepository.login(email, password))
          .thenAnswer((_) async => expectedUser);

      // Act
      final result = await loginUseCase.execute(email, password);

      // Assert
      expect(result, equals(expectedUser));
      verify(mockUserRepository.login(email, password)).called(1);
    });

    test('execute throws RepositoryException on failure', () async {
      // Arrange
      when(mockUserRepository.login(any, any))
          .thenThrow(RepositoryException('Invalid credentials'));

      // Act & Assert
      expect(
        () => loginUseCase.execute('test@example.com', 'wrong'),
        throwsA(isA<RepositoryException>()),
      );
    });
  });
}
```

### ✅ Widget Test

```dart
// tests/widget_test/screens/test_login_screen.dart
void main() {
  group('LoginScreen', () {
    testWidgets('displays email and password fields', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        ProviderContainer(
          child: MaterialApp(home: LoginScreen()),
        ).listen,
      );

      // Act & Assert
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Email'), findsWidgets);
      expect(find.text('Password'), findsWidgets);
    });

    testWidgets('shows loading spinner on login', (WidgetTester tester) async {
      // Arrange
      final container = ProviderContainer();
      // Mock the auth controller to return loading state

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: LoginScreen()),
        ),
      );

      // Simulate clicking login button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
```

---

## 8. Performance Optimization

### ✅ Watch vs Select

```dart
// BAD: Rebuilds entire widget on any part of controller state change
final state = ref.watch(userControllerProvider);
return Text(state.user.name); // Rebuilds if ANY field changes

// GOOD: Only rebuild if specific field changes
final userName = ref.watch(
  userControllerProvider.select((state) => state.user.name),
);
return Text(userName);
```

### ✅ Caching Strategy

```dart
// GOOD: Use keepAlive to prevent GC of expensive computations
@riverpod
Future<List<User>> getActiveUsers(GetActiveUsersRef ref) {
  ref.keepAlive();
  return ref.read(userRepositoryProvider).getActiveUsers();
}

// GOOD: Manual cache invalidation
void _refreshUserList(WidgetRef ref) {
  ref.invalidate(getActiveUsersProvider);
}
```

---

## 📋 Pre-Commit Checklist

- [ ] ✅ `flutter analyze` runs clean
- [ ] ✅ `dart format lib/` applied
- [ ] ✅ Feature-first architecture (no lib/models/ folders)
- [ ] ✅ All models use `@freezed`
- [ ] ✅ Riverpod providers properly typed
- [ ] ✅ No `print()` statements (use logging)
- [ ] ✅ Null-safe (no `!` without justification)
- [ ] ✅ Tests >80% coverage (unit + widget)
- [ ] ✅ BuildContext safe (check `mounted` after async)
- [ ] ✅ Error handling with custom exceptions

---

**Versión:** 1.0
**Framework:** Flutter 3.19+ + Riverpod 2.0
**Última Actualización:** 30/01/2026
**Validado Por:** ArchitectZero (Dogfooding ✨)
