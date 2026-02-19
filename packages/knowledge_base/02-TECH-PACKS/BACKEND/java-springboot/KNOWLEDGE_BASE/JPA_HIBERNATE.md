# 🐘 JPA & Hibernate: Mapeo Objeto-Relacional

> **Estándar:** Jakarta Persistence (JPA 3.2)
> **Implementación:** Hibernate 6.4+
> **Goal:** Persistencia relacional eficiente
> **Date:** 30 de Enero de 2026

ORM es la frontera entre el mundo de objetos (Java) y el mundo relacional (SQL). Aplicamos patrones para no explotar la base de datos.

---

## 📖 Table of Contents

1. [Relaciones y Fetch Types](#relaciones-y-fetch-types)
2. [El Problema N+1](#el-problema-n1)
3. [Entidades vs DTOs](#entidades-vs-dtos)
4. [Lazy Loading Seguro](#lazy-loading-seguro)
5. [Transacciones](#transacciones)
6. [Anti-Patterns](#anti-patterns)

---

## Relaciones y Fetch Types

### Anotaciones de Relación

| Relación | One-Side | Many-Side | Default FetchType |
|:---|:---|:---|:---|
| **One-to-Many** | `@OneToMany` | `mappedBy` | LAZY ✅ |
| **Many-to-One** | `@ManyToOne` | NUNCA | EAGER ❌ (cambiar a LAZY) |
| **Many-to-Many** | `@ManyToMany` | `mappedBy` | LAZY ✅ |
| **One-to-One** | `@OneToOne` | `mappedBy` | EAGER ❌ (cambiar a LAZY) |

### Regla de Oro

> **Todo `ToOne` es EAGER por defecto → CAMBIAR a LAZY**
> **Todo `ToMany` es LAZY por defecto → MANTENER LAZY**

### Examples

```java
// ❌ BAD: ManyToOne EAGER (trae el usuario cada vez que cargas un post)
@Entity
public class Post {
    @Id
    private Long id;

    @ManyToOne(fetch = FetchType.EAGER)  // ← PROBLEMA
    @JoinColumn(name = "user_id")
    private User author;
}

// ✅ GOOD: ManyToOne LAZY (carga bajo demanda)
@Entity
public class Post {
    @Id
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)  // ← CORRECTO
    @JoinColumn(name = "user_id")
    private User author;
}

// ✅ GOOD: OneToMany LAZY (default, pero ser explícito)
@Entity
public class User {
    @Id
    private Long id;

    @OneToMany(mappedBy = "author", fetch = FetchType.LAZY)
    private List<Post> posts;
}

// ❌ BAD: OneToOne EAGER (trae el perfil cada vez)
@Entity
public class User {
    @OneToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "profile_id")
    private Profile profile;
}

// ✅ GOOD: OneToOne LAZY
@Entity
public class User {
    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "profile_id")
    private Profile profile;
}
```

---

## El Problema N+1

La pesadilla del ORM: ejecutas 1 query y terminas ejecutando N queries más.

### Escenario del Problema

```java
// 1. Traer todos los usuarios (1 query)
List<User> users = userRepository.findAll();

// 2. Acceder a los posts de cada usuario en un loop
for (User user : users) {
    List<Post> posts = user.getPosts();  // ← AQUÍ: 100 queries más
    // ...
}

// TOTAL: 1 + 100 = 101 queries ❌
```

### Solución 1: JOIN FETCH (JPQL)

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    // ✅ GOOD: Traer usuarios CON sus posts en un solo JOIN
    @Query("SELECT DISTINCT u FROM User u LEFT JOIN FETCH u.posts")
    List<User> findAllWithPosts();
}

// TOTAL: 1 query ✅
```

### Solución 2: Entity Graphs

```java
@Entity
public class User {
    @Id
    private Long id;

    @OneToMany(mappedBy = "author")
    private List<Post> posts;

    // Definir un "grafo" de objetos relacionados
    @NamedEntityGraph(
        name = "User.withPosts",
        attributeNodes = @NamedAttributeNode("posts")
    )
    public static final String GRAPH_WITH_POSTS = "User.withPosts";
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @EntityGraph(attributePaths = {"posts"})
    List<User> findAll();

    // O con @NamedEntityGraph
    @EntityGraph(User.GRAPH_WITH_POSTS)
    List<User> findAllNamed();
}
```

### Solución 3: Projection (Lo mejor para Read-Only)

```java
// Crear un DTO projection (no carga datos no usados)
public interface UserWithPostsProjection {
    Long getId();
    String getName();
    List<PostProjection> getPosts();

    interface PostProjection {
        String getTitle();
        String getContent();
    }
}

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    List<UserWithPostsProjection> findAllProjectedBy();
}
```

---

## Entidades vs DTOs

### Regla Crítica

> **NUNCA devolver una `@Entity` directamente en un Controller**

### Por Qué

```java
// ❌ BAD: Retornar Entity
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserRepository userRepository;

    @GetMapping("/{id}")
    public User getUser(@PathVariable Long id) {
        return userRepository.findById(id).orElseThrow();  // ← Entity
    }
}

// Problemas:
// 1. Lazy-load en serialización: accedes a `user.getPosts()` y explota
// 2. Ciclos de referencias: User ↔ Post → JSON infinito
// 3. Expones campos internos (passwords, emails de sistema)
// 4. Entity tiene ciclo de vida JPA (cambios se persisten)
```

### La Solución: DTOs (Java Records)

```java
// ✅ GOOD: DTO (Java Record - Immutable)
public record UserDto(
    Long id,
    String name,
    String email
) {}

public record UserDetailedDto(
    Long id,
    String name,
    String email,
    List<PostSummaryDto> posts
) {}

public record PostSummaryDto(
    Long id,
    String title
) {}

// Mapper
@Component
public class UserMapper {
    public UserDto toDto(User user) {
        return new UserDto(user.getId(), user.getName(), user.getEmail());
    }

    public UserDetailedDto toDetailedDto(User user) {
        return new UserDetailedDto(
            user.getId(),
            user.getName(),
            user.getEmail(),
            user.getPosts().stream()
                .map(p -> new PostSummaryDto(p.getId(), p.getTitle()))
                .toList()
        );
    }
}

// Controller
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;
    private final UserMapper userMapper;

    @GetMapping("/{id}")
    public ResponseEntity<UserDetailedDto> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        return ResponseEntity.ok(userMapper.toDetailedDto(user));  // ← DTO
    }
}
```

---

## Lazy Loading Seguro

### El Problema: LazyInitializationException

```java
// ❌ BAD: Sesión cerrada antes de acceder a colección lazy
public User getUserWithPosts(Long id) {
    // La sesión HibernateSession está ABIERTA aquí
    User user = session.find(User.class, id);
    // La sesión se CIERRA aquí

    return user;
}

// Desde el controlador:
User user = getUserWithPosts(1);
user.getPosts().size();  // ← LazyInitializationException (sesión cerrada)
```

### Solución 1: JOIN FETCH (Trae todo en una query)

```java
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    @Query("SELECT u FROM User u JOIN FETCH u.posts WHERE u.id = ?1")
    Optional<User> findByIdWithPosts(Long id);
}

// Seguro: posts ya están cargados
User user = userRepository.findByIdWithPosts(1).orElseThrow();
user.getPosts().size();  // ✅ OK
```

### Solución 2: Hibernate.initialize()

```java
public User getUserWithPostsForced(Long id) {
    User user = userRepository.findById(id).orElseThrow();

    // Forzar carga de la colección mientras sesión está abierta
    Hibernate.initialize(user.getPosts());

    return user;
}
```

### Solución 3: @Transactional

```java
@Service
public class UserService {
    // @Transactional mantiene la sesión abierta para todo el método
    @Transactional(readOnly = true)
    public UserDetailedDto getUserDetailed(Long id) {
        User user = userRepository.findById(id).orElseThrow();
        // Sesión sigue abierta, puedo acceder a lazy collections
        return new UserDetailedDto(
            user.getId(),
            user.getName(),
            user.getPosts().stream()
                .map(p -> new PostDto(p.getId(), p.getTitle()))
                .toList()
        );
    }
}
```

---

## Transacciones

### `@Transactional` Básico

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;

    // ✅ GOOD: Transacción de lectura (más rápido)
    @Transactional(readOnly = true)
    public Order getOrder(Long id) {
        return orderRepository.findById(id).orElseThrow();
    }

    // ✅ GOOD: Transacción de escritura (default)
    @Transactional
    public Order processOrder(OrderDto dto) {
        Order order = new Order(dto);
        orderRepository.save(order);  // Dentro de transacción

        paymentService.charge(order);  // ← También transaccional

        return order;
    }

    // ✅ GOOD: Propagación y aislamiento
    @Transactional(
        propagation = Propagation.REQUIRES_NEW,  // Nueva transacción
        isolation = Isolation.REPEATABLE_READ    // Level de aislamiento
    )
    public void logAudit(Order order) {
        // Nueva transacción independiente
    }
}
```

### Rollback Automático en Excepciones

```java
@Service
public class OrderService {
    @Transactional
    public Order processOrder(OrderDto dto) {
        Order order = new Order(dto);
        orderRepository.save(order);

        // Si esto lanza excepción no-checked, ROLLBACK automático
        paymentService.charge(order);  // ← Si falla, rollback

        return order;
    }
}

// Por defecto:
// - RuntimeException y subclases → ROLLBACK
// - Exception checked → NO rollback (commit)

// Forzar rollback en checked exception
@Transactional(rollbackFor = PaymentException.class)
public void processOrderForced() { ... }
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Eager Todas las Relaciones

```java
// ❌ BAD: Eager para todo (carga el universo)
@Entity
public class User {
    @ManyToOne(fetch = FetchType.EAGER)
    private Department department;

    @OneToMany(fetch = FetchType.EAGER)
    private List<Post> posts;

    @OneToMany(fetch = FetchType.EAGER)
    private List<Comment> comments;

    @OneToMany(fetch = FetchType.EAGER)
    private List<Follower> followers;

    @OneToOne(fetch = FetchType.EAGER)
    private Profile profile;
}

// Traer 1 usuario = Traer departamento, posts, comments, followers, profile
// CARTESIAN PRODUCT: 100 usuarios × 50 posts × 10 comments = 50,000 rows
```

### ❌ ANTI-PATTERN 2: Acceder a Lazy Sin Sesión

```java
// ❌ BAD: LazyInitializationException
public List<User> getActiveUsers() {
    return userRepository.findAll();  // Sin JOIN FETCH
}

// En el controller:
users.forEach(u -> logger.info(u.getPosts().size()));
// ← LazyInitializationException
```

### ❌ ANTI-PATTERN 3: Mutar Entidades en el Controller

```java
// ❌ BAD: Cambios se persisten automáticamente (dirty checking)
@PostMapping("/users/{id}/name")
@Transactional
public User updateUserName(@PathVariable Long id, @RequestBody NameDto dto) {
    User user = userRepository.findById(id).orElseThrow();
    user.setName(dto.name);  // ← Cambio aquí
    // No llamar a save()
    // Transacción termina, Hibernate detecta cambio y hace UPDATE
}

// ✅ GOOD: Explícito
@PostMapping("/users/{id}/name")
@Transactional
public UserDto updateUserName(@PathVariable Long id, @RequestBody NameDto dto) {
    User user = userRepository.findById(id).orElseThrow();
    user.setName(dto.name);
    userRepository.save(user);  // Explícito
    return userMapper.toDto(user);
}
```

### ❌ ANTI-PATTERN 4: Queries Lentas Sin Índices

```java
// ❌ BAD: Query lenta sin índice
@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    // Full table scan
    List<Post> findByContentContaining(String keyword);
}

// ✅ GOOD: Crear índice
@Entity
@Table(indexes = {
    @Index(name = "idx_content", columnList = "content")
})
public class Post {
    private String content;
}
```

---

## Checklist: JPA Hibernate Bien Formado

```bash
# ✅ 1. Relaciones
[ ] ManyToOne y OneToOne con FetchType.LAZY
[ ] OneToMany con FetchType.LAZY (default)
[ ] Bi-directional relationships tienen mappedBy

# ✅ 2. N+1 Prevention
[ ] JOIN FETCH para relaciones necesarias
[ ] @EntityGraph para grafos complejos
[ ] Projections para read-only queries

# ✅ 3. DTOs
[ ] NUNCA retornar Entity en Controller
[ ] Usar Java Records para DTOs
[ ] Mapper bean para conversiones

# ✅ 4. Transactions
[ ] @Transactional en servicios
[ ] readOnly = true para queries
[ ] Propagation configurado si aplica

# ✅ 5. Performance
[ ] Índices en campos que se queryean
[ ] Batch operations para bulk inserts
[ ] AsNoTracking() mental (no hay en JPA)

# ✅ 6. Debugging
[ ] spring.jpa.show-sql=true (desarrollo)
[ ] spring.jpa.properties.hibernate.format_sql=true
[ ] Query en logs para analizar
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ HIBERNATE ORM READY
**Responsable:** ArchitectZero AI Agent
