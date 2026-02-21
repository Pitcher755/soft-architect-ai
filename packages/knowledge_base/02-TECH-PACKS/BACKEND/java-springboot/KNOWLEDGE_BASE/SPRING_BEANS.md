# 🌱 Spring Beans & Dependency Injection: El IoC Container

> **Framework:** Spring Boot 3.2+
> **Java:** 17/21 (LTS - Virutal Threads)
> **Concepto:** Inversion of Control (IoC) & Inyección de Dependencias
> **Date:** 30 de Enero de 2026

La magia de Spring: dejas de escribir `new Service()` y Spring se encarga de gestionar el ciclo de vida de tus objetos.

---

## 📖 Table of Contents

1. [Estereotipos (Anotaciones)](#estereotipos-anotaciones)
2. [Ciclo de Vida del Bean](#ciclo-de-vida-del-bean)
3. [Inyección de Dependencias](#inyección-de-dependencias)
4. [Scopes](#scopes)
5. [`@Bean` vs `@Component`](#bean-vs-component)
6. [Configuration Avanzada](#configuración-avanzada)

---

## Estereotipos (Anotaciones)

Spring escanea tu código buscando estas marcas especiales para crear **Beans** (objetos gestionados por el contenedor).

### Tabla de Estereotipos

| Anotación | Propósito | Capa Arquitectónica | Se Registra |
|:---|:---|:---|:---|
| **`@Component`** | Genérico (fallback) | Utilidades, Helpers, Adaptadores | ✅ Automático |
| **`@Service`** | Lógica de Negocio | Domain Logic, Transacciones | ✅ Automático |
| **`@Repository`** | Acceso a Datos | Data Layer, JPA | ✅ Automático |
| **`@Controller`** | Controlador MVC | Web Controllers (HTML) | ✅ Automático |
| **`@RestController`** | API REST | REST Endpoints (JSON) | ✅ Automático |
| **`@Configuration`** | Configuration | Definir Beans manualmente | ✅ Automático |

### Ejemplo de Uso

```java
// ✅ GOOD: Service con @Service
@Service
@Transactional
public class UserService {
    private final UserRepository repository;

    // Constructor injection (immutable, testable)
    public UserService(UserRepository repository) {
        this.repository = repository;
    }

    public User findById(Long id) {
        return repository.findById(id)
            .orElseThrow(() -> new UserNotFoundException(id));
    }

    @Transactional
    public User save(User user) {
        return repository.save(user);
    }
}

// ✅ GOOD: Repository (Spring Data JPA auto-genera la implementación)
@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByEmail(String email);

    @Query("SELECT u FROM User u WHERE u.status = ?1")
    List<User> findByStatus(UserStatus status);
}

// ✅ GOOD: RestController
@RestController
@RequestMapping("/api/users")
public class UserController {
    private final UserService userService;

    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<UserDto> getUser(@PathVariable Long id) {
        User user = userService.findById(id);
        return ResponseEntity.ok(UserMapper.toDto(user));
    }
}
```

---

## Ciclo de Vida del Bean

Spring gestiona el ciclo completo desde la creación hasta la destrucción.

### Fases

```
1️⃣ Instantiation (Constructor)
   ↓
2️⃣ Property Population (Setters)
   ↓
3️⃣ BeanNameAware.setBeanName()
   ↓
4️⃣ BeanFactoryAware.setBeanFactory()
   ↓
5️⃣ @PostConstruct (Custom Initialization)
   ↓
6️⃣ USE BEAN (Tu código aquí)
   ↓
7️⃣ @PreDestroy (Cleanup)
   ↓
8️⃣ Destrucción
```

### Hooks de Inicialización

```java
@Component
public class DataSourceConfig {
    private final Logger log = LoggerFactory.getLogger(this.getClass());

    // ✅ GOOD: @PostConstruct para inicialización
    @PostConstruct
    public void init() {
        log.info("DataSource initialized");
        // Conectar a base de datos, cargar configuración, etc.
    }

    // ✅ GOOD: @PreDestroy para limpieza
    @PreDestroy
    public void cleanup() {
        log.info("DataSource closing connections");
        // Cerrar conexiones, liberar recursos
    }
}

// Alternativa: Implementar InitializingBean y DisposableBean
@Component
public class LegacyConfig implements InitializingBean, DisposableBean {
    @Override
    public void afterPropertiesSet() throws Exception {
        // Equivalente a @PostConstruct
    }

    @Override
    public void destroy() throws Exception {
        // Equivalente a @PreDestroy
    }
}
```

---

## Inyección de Dependencias

### Regla de Oro: Constructor Injection

```java
// ✅ GOOD: Inyección por Constructor (SIEMPRE usar esto)
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;
    private final EmailService emailService;

    // Constructor con DI
    public OrderService(OrderRepository orderRepository,
                       PaymentService paymentService,
                       EmailService emailService) {
        this.orderRepository = orderRepository;
        this.paymentService = paymentService;
        this.emailService = emailService;
    }

    public Order processOrder(OrderDto dto) {
        // Usar las dependencias
        Order order = new Order(dto);
        orderRepository.save(order);
        paymentService.charge(order);
        emailService.sendConfirmation(order);
        return order;
    }
}

// ❌ BAD: Field Injection (anti-pattern)
@Service
public class OrderService {
    @Autowired
    private OrderRepository orderRepository;  // Difícil de testear

    @Autowired
    private PaymentService paymentService;
}

// ❌ BAD: Setter Injection (exposición de detalles)
@Service
public class OrderService {
    private OrderRepository orderRepository;

    @Autowired
    public void setOrderRepository(OrderRepository repo) {
        this.orderRepository = repo;  // Puede ser null
    }
}
```

### Inyección Condicional

```java
// ✅ GOOD: @Qualifier para elegir entre múltiples implementaciones
@Service
public class PaymentService {
    private final PaymentGateway paymentGateway;

    public PaymentService(@Qualifier("stripePaymentGateway") PaymentGateway gateway) {
        this.paymentGateway = gateway;
    }
}

// ✅ GOOD: @Primary para designar la implementación por defecto
@Configuration
public class PaymentConfig {
    @Bean
    @Primary
    public PaymentGateway stripeGateway() {
        return new StripePaymentGateway();
    }

    @Bean
    public PaymentGateway paypalGateway() {
        return new PayPalPaymentGateway();
    }
}
```

---

## Scopes

### Tipos de Scopes

| Scope | Instancias | Uso | Ciclo de Vida |
|:---|:---|:---|:---|
| **Singleton** | Una sola | Stateless services, repositories | Aplicación completa |
| **Prototype** | Nueva cada vez | Objetos con estado | Llamada a `getBean()` |
| **Request** | Una por HTTP request | Data holders | Request HTTP |
| **Session** | Una por sesión HTTP | User context (web) | Sesión HTTP |
| **Application** | Una por ServletContext | Shared data (web) | Aplicación |

### Examples

```java
// ✅ GOOD: Singleton (Default, recomendado para servicios)
@Service
public class UserService {
    // Una sola instancia para toda la app
    public User findById(Long id) { ... }
}

// ✅ GOOD: Prototype (para objetos con estado)
@Component
@Scope("prototype")
public class MailComposer {
    private String to;
    private String subject;
    private String body;

    // Nueva instancia cada vez
    public void setTo(String to) { this.to = to; }
}

// ✅ GOOD: Request (para web context)
@Component
@Scope("request")
@RequestScope  // Equivalente más explícito
public class RequestContext {
    private HttpServletRequest request;

    public RequestContext(HttpServletRequest request) {
        this.request = request;
    }
}
```

---

## `@Bean` vs `@Component`

### `@Component` para Clases Propias

Usa cuando escribes la clase (es tuya):

```java
@Component
public class UserValidator {
    public boolean isEmailValid(String email) {
        return email.contains("@");
    }
}
```

### `@Bean` para Clases de Terceros

Usa cuando necesitas configurar librerías externas:

```java
@Configuration
public class ExternalServicesConfig {
    // ✅ GOOD: Configurar ObjectMapper (Jackson)
    @Bean
    public ObjectMapper objectMapper() {
        ObjectMapper mapper = new ObjectMapper();
        mapper.registerModule(new JavaTimeModule());
        mapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);
        return mapper;
    }

    // ✅ GOOD: Configurar RestTemplate
    @Bean
    public RestTemplate restTemplate(RestTemplateBuilder builder) {
        return builder
            .setConnectTimeout(Duration.ofSeconds(5))
            .setReadTimeout(Duration.ofSeconds(10))
            .build();
    }

    // ✅ GOOD: Configurar WebClient (Reactive)
    @Bean
    public WebClient webClient() {
        return WebClient.builder()
            .baseUrl("https://api.example.com")
            .build();
    }
}
```

---

## Configuration Avanzada

### Profiles (Ambientes)

```java
// ✅ GOOD: Beans específicos por ambiente
@Configuration
public class DataSourceConfig {
    @Bean
    @Profile("development")
    public DataSource devDataSource() {
        DriverManagerDataSource ds = new DriverManagerDataSource();
        ds.setUrl("jdbc:mysql://localhost:3306/devdb");
        ds.setUsername("dev");
        ds.setPassword("dev");
        return ds;
    }

    @Bean
    @Profile("production")
    public DataSource prodDataSource() {
        // Usar properties secretas
        return HikariDataSource.createHikariPool(...);
    }
}

// Activar profile: spring.profiles.active=production
```

### Conditional Beans

```java
@Configuration
public class FeatureFlags {
    // ✅ GOOD: Bean solo si la propiedad existe y es true
    @Bean
    @ConditionalOnProperty(
        name = "feature.payment.enabled",
        havingValue = "true"
    )
    public PaymentService paymentService() {
        return new StripePaymentService();
    }

    // ✅ GOOD: Bean solo si la clase está en classpath
    @Bean
    @ConditionalOnClass(RedisConnectionFactory.class)
    public RedisTemplate<String, Object> redisTemplate() {
        return new RedisTemplate<>();
    }
}
```

### Properties Externalizadas

```java
@Component
public class AppConfig {
    // ✅ GOOD: Inyectar desde application.properties
    @Value("${app.name:My App}")
    private String appName;

    @Value("${app.debug:false}")
    private boolean debug;

    @Value("${db.url}")
    private String dbUrl;
}

// application.properties
// app.name=SoftArchitect
// app.debug=true
// db.url=jdbc:mysql://localhost:3306/softarch
```

---

## Checklist: Spring Beans Bien Formados

```bash
# ✅ 1. Estereotipos
[ ] @Service para lógica de negocio
[ ] @Repository para acceso a datos
[ ] @RestController para endpoints
[ ] No mezclar capas (Controller con Repository)

# ✅ 2. Inyección
[ ] Constructor injection (NO field injection)
[ ] Dependencias finales (immutable)
[ ] @Qualifier si hay múltiples implementaciones

# ✅ 3. Ciclo de Vida
[ ] @PostConstruct para inicialización
[ ] @PreDestroy para cleanup
[ ] No hacer trabajo pesado en constructor

# ✅ 4. Scopes
[ ] Singleton para servicios stateless
[ ] Prototype para objetos con estado
[ ] @RequestScope para contexto HTTP

# ✅ 5. Configuration
[ ] @Configuration para Beans de terceros
[ ] @Profile para ambientes
[ ] @ConditionalOnProperty para feature flags
[ ] Properties externalizadas (@Value)

# ✅ 6. Testing
[ ] Usar MockMvc para tests de integración
[ ] @SpringBootTest para contexto completo
[ ] @DataJpaTest para tests de repository
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ SPRING IOC READY
**Responsable:** ArchitectZero AI Agent
