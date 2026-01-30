# 🛡️ OWASP Top 10 Mitigation Matrix

> **Fecha:** 30/01/2026
> **Estado:** ✅ MANDATORY (Ley Absoluta)
> **Alcance:** TODO código generado por SoftArchitect AI
> **Referencia:** OWASP Top 10 (2021) + Contexto SoftArchitect
> **Enforcement:** Linter automático + Code Review

Esta es **la matriz de defensa** que traduce amenazas teóricas en soluciones técnicas obligatorias en nuestro stack.

---

## 📖 Tabla de Contenidos

1. [Matriz de Mitigación](#matriz-de-mitigación)
2. [A01: Broken Access Control](#a01-broken-access-control)
3. [A02: Cryptographic Failures](#a02-cryptographic-failures)
4. [A03: Injection](#a03-injection)
5. [A04: Insecure Design](#a04-insecure-design)
6. [A05: Security Misconfiguration](#a05-security-misconfiguration)
7. [A06: Vulnerable Components](#a06-vulnerable-components)
8. [A07: Identification & Auth Failures](#a07-identification--auth-failures)
9. [A08: Software & Data Integrity Failures](#a08-software--data-integrity-failures)
10. [A09: Logging & Monitoring Failures](#a09-logging--monitoring-failures)
11. [A10: Server-Side Request Forgery (SSRF)](#a10-server-side-request-forgery-ssrf)
12. [Linter Rules & Enforcement](#linter-rules--enforcement)
13. [Pre-Production Security Checklist](#pre-production-security-checklist)

---

## Matriz de Mitigación

| OWASP Top 10 | Backend (Python FastAPI) | Frontend (Flutter) | DevOps (Docker) |
|:---|:---|:---|:---|
| **A01: Broken Access Control** | `Depends(get_current_user)` en endpoints protegidos | GoRouter guards + authProvider watch | RBAC en orquestación |
| **A02: Cryptographic Failures** | Passlib + bcrypt/argon2 + pydantic-settings | JWT en secure_storage (Keychain/Keystore) | HTTPS forzado, TLS 1.2+ |
| **A03: Injection** | SQLAlchemy ORM obligatorio, NO raw SQL | Parámetros tipados, NO string concat | Validación de entrada en límites |
| **A04: Insecure Design** | Pydantic V2 input validation + rate limiting | Business logic en Domain, no en UI | Principios SOLID |
| **A05: Security Misconfiguration** | .env con pydantic-settings, no hardcoded | Flags de release (`--obfuscate`), no debugPrint | Non-root user, CORS restrictivo |
| **A06: Vulnerable Components** | Poetry with locked versions + Trivy scanning | Pub with pubspec.lock + auditoría regular | Image scanning en CI/CD |
| **A07: Auth Failures** | JWT (15min exp) + Refresh (rotativo) | Session management + auto-logout en 401 | MFA en infraestructura |
| **A08: Integrity Failures** | CI/CD con firma de imágenes Docker | App signing via CI/CD (NO keystore en repo) | Checksum verification |
| **A09: Logging Failures** | Structlog JSON + redacción de PII | Crashlytics sin datos sensibles, no logs de tokens | Centralized logging, rotación |
| **A10: SSRF** | Validación de URLs de input, aislamiento de red | N/A | Network policies estrictas |

---

## A01: Broken Access Control

**Definición:** Usuarios acceden a recursos que no deberían.

### 🛡️ Solución Backend (FastAPI)

**Regla Obligatoria:** `Depends(get_current_user)` en CADA endpoint protegido.

```python
# ✅ GOOD: Protección en endpoint
from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")

async def get_current_user(token: str = Depends(oauth2_scheme)) -> User:
    """Validar JWT y extraer usuario."""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401)
    except JWTError:
        raise HTTPException(status_code=401)

    user = await repo.get_user(user_id)
    if not user:
        raise HTTPException(status_code=401)
    return user

@app.get("/documents/{doc_id}")
async def get_document(doc_id: int, current_user: User = Depends(get_current_user)):
    """Endpoint protegido: solo usuarios autenticados."""
    doc = await repo.get_document(doc_id)

    # EXTRA: Verificar ownership
    if doc.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return doc
```

**Anti-Pattern ❌:**
```python
# ❌ BAD: Endpoint público (sin autenticación)
@app.get("/documents/{doc_id}")
async def get_document(doc_id: int):
    return await repo.get_document(doc_id)  # Cualquiera puede ver cualquier doc
```

### 🛡️ Solución Frontend (Flutter)

```dart
// ✅ GOOD: GoRouter con guard
final router = GoRouter(
  routes: [
    GoRoute(
      path: '/documents',
      redirect: (context, state) {
        final authState = ref.watch(authProvider);
        return authState.when(
          data: (user) => user == null ? '/login' : null,
          error: (_, __) => '/login',
          loading: () => '/loading',
        );
      },
      builder: (context, state) => DocumentsScreen(),
    ),
  ],
);

// ✅ GOOD: Ocultar botones si no autorizado
class DocumentCard extends ConsumerWidget {
  final Document doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider).value;
    final canDelete = currentUser?.id == doc.owner_id;

    return ListTile(
      title: Text(doc.title),
      trailing: canDelete
          ? IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteDocument(doc.id),
            )
          : null,
    );
  }
}
```

**Anti-Pattern ❌:**
```dart
// ❌ BAD: Mostrar botón pero fallar en backend (falsa sensación de seguridad)
IconButton(
  icon: Icon(Icons.delete),
  onPressed: () => api.deleteDocument(doc.id),
  // Sin verificar si el usuario es dueño
)
```

---

## A02: Cryptographic Failures

**Definición:** Exposición de datos sensibles por criptografía débil o ausente.

### 🛡️ Solución Backend

**Regla:** Contraseñas con `bcrypt` o `argon2`. Secrets SOLO en `.env`.

```python
# ✅ GOOD: Password hashing seguro
from passlib.context import CryptContext

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def hash_password(password: str) -> str:
    """Hashear contraseña con bcrypt."""
    return pwd_context.hash(password)

def verify_password(plain_password: str, hashed: str) -> bool:
    """Verificar contraseña."""
    return pwd_context.verify(plain_password, hashed)

# Uso en login
@app.post("/login")
async def login(credentials: LoginSchema):
    user = await repo.get_user_by_email(credentials.email)
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(status_code=401)

    # Generar JWT
    token = create_access_token(user.id, expires_in=timedelta(minutes=15))
    return {"access_token": token, "token_type": "bearer"}

def create_access_token(user_id: int, expires_in: timedelta) -> str:
    """Crear JWT con expiración corta."""
    payload = {
        "sub": user_id,
        "exp": datetime.utcnow() + expires_in,
        "iat": datetime.utcnow(),
    }
    return jwt.encode(payload, SECRET_KEY, algorithm=ALGORITHM)
```

**Anti-Patterns ❌:**
```python
# ❌ BAD: Contraseña en texto plano
user.password = password  # Nunca!

# ❌ BAD: Secretos hardcodeados
SECRET_KEY = "my-super-secret-key-123"  # En código!

# ❌ BAD: JWT sin expiración
payload = {"sub": user_id}  # Se puede reutilizar para siempre
```

### 🛡️ Solución Frontend

```dart
// ✅ GOOD: Guardar token en secure storage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  final _storage = FlutterSecureStorage();

  Future<void> saveToken(String token) async {
    await _storage.write(
      key: 'access_token',
      value: token,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: 'access_token');
  }
}

// Uso en Riverpod
@riverpod
Future<String?> accessToken(AccessTokenRef ref) async {
  final storage = SecureTokenStorage();
  return await storage.getToken();
}
```

**Anti-Patterns ❌:**
```dart
// ❌ BAD: Token en SharedPreferences (texto plano en disco)
SharedPreferences prefs = await SharedPreferences.getInstance();
prefs.setString('token', token);  // Vulnerable!

// ❌ BAD: Token en memoria sin expiración
static String _token = '';  // Global variable
```

---

## A03: Injection

**Definición:** Atacante inyecta código malicioso (SQL, NoSQL, Command).

### 🛡️ Solución Backend

**Regla Obligatoria:** SQLAlchemy ORM. Prohibido raw SQL concatenado.

```python
# ✅ GOOD: SQLAlchemy ORM (safe by design)
async def get_user_by_email(email: str) -> User | None:
    """Usar ORM: parámetros separados de lógica."""
    query = select(User).where(User.email == email)
    result = await session.execute(query)
    return result.scalar_one_or_none()

# ✅ GOOD: Parámetros nombrados en raw SQL (si es absolutamente necesario)
async def search_documents(search_term: str):
    # Parámetros separados (? es placeholder, no concatenación)
    query = "SELECT * FROM documents WHERE title LIKE :search"
    result = await session.execute(
        text(query),
        {"search": f"%{search_term}%"}  # Parámetro, no interpolación
    )
    return result.fetchall()
```

**Anti-Patterns ❌:**
```python
# ❌ CRITICAL: SQL Injection
search_term = "'; DROP TABLE users; --"
query = f"SELECT * FROM documents WHERE title = '{search_term}'"  # VULNERABLE!
await session.execute(text(query))

# ❌ CRITICAL: Command Injection
user_input = "file.txt; rm -rf /"
os.system(f"cat {user_input}")  # VULNERABLE!
```

### 🛡️ Solución Frontend

```dart
// ✅ GOOD: Parámetros tipados en Dio
final dio = Dio();

Future<List<Document>> searchDocuments(String query) async {
  final response = await dio.get(
    '/api/documents/search',
    queryParameters: {
      'q': query,  // Parámetro, no URL string concat
    },
  );
  return (response.data as List)
      .map((item) => Document.fromJson(item))
      .toList();
}

// ✅ GOOD: JSON seguro con json_serializable
@freezed
class Document with _$Document {
  const factory Document({
    required int id,
    required String title,
  }) = _Document;

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
}
```

**Anti-Patterns ❌:**
```dart
// ❌ BAD: URL concatenación manual
final response = await dio.get('/api/search?q=' + userInput);  // NO!

// ❌ BAD: JSON sin validación
final doc = Document.fromJson(json);  // ¿Y si tiene campos maliciosos?
```

---

## A04: Insecure Design

**Definición:** Falta de controles de seguridad desde el diseño (no implementación).

### 🛡️ Solución Backend

```python
# ✅ GOOD: Rate limiting en endpoints públicos
from slowapi import Limiter
from slowapi.util import get_remote_address

limiter = Limiter(key_func=get_remote_address)

@app.post("/login")
@limiter.limit("5/minute")  # Máx 5 intentos por minuto
async def login(request: Request, credentials: LoginSchema):
    """Prevenir fuerza bruta."""
    # ... validar credenciales
    pass

# ✅ GOOD: Validación Pydantic V2 obligatoria
from pydantic import BaseModel, Field, field_validator

class UserCreate(BaseModel):
    email: str = Field(..., regex=r"^[\w\.-]+@[\w\.-]+\.\w+$")
    password: str = Field(..., min_length=12)

    @field_validator('password')
    def validate_password(cls, v):
        # Contraseña debe tener mayúsculas, números, símbolos
        if not any(c.isupper() for c in v):
            raise ValueError("Debe contener mayúscula")
        return v
```

### 🛡️ Solución Frontend

```dart
// ✅ GOOD: Validar antes de enviar
class LoginForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Email required';
              }
              if (!value.contains('@')) {
                return 'Invalid email';
              }
              return null;
            },
          ),
          TextFormField(
            obscureText: true,
            validator: (value) {
              if (value == null || value.length < 12) {
                return 'Password min 12 chars';
              }
              return null;
            },
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // Enviar solo si pasa validación
                _submitLogin();
              }
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }
}
```

---

## A05: Security Misconfiguration

**Definición:** Configuración insegura por defecto (CORS abierto, banners de servidor, etc.).

### 🛡️ Solución Backend

```python
# ✅ GOOD: CORS restrictivo
from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://softarchitect.io"],  # Específico, NO "*"
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE"],
    allow_headers=["Authorization", "Content-Type"],
)

# ✅ GOOD: Remover banners de servidor
@app.middleware("http")
async def remove_server_header(request, call_next):
    response = await call_next(request)
    response.headers.pop("server", None)  # Ocultar version de Uvicorn
    return response

# ✅ GOOD: Forzar HTTPS en producción
@app.middleware("http")
async def force_https(request, call_next):
    if os.getenv("ENVIRONMENT") == "production":
        if request.url.scheme != "https":
            return RedirectResponse(url=request.url.replace(scheme="https"))
    return await call_next(request)
```

### 🛡️ Solución Frontend

```dart
// ✅ GOOD: Release build sin debug info
// flutter build apk --release --obfuscate --split-debug-info=./symbols
// (NO debugPrint en release)

import 'package:flutter/foundation.dart';

void log(String message) {
  if (kDebugMode) {
    debugPrint(message);  // Solo en development
  }
}

// ✅ GOOD: Certificado pinning en HTTPS
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';

final dio = Dio();
dio.httpClientAdapter = DefaultHttpClientAdapter()
  ..onHttpClientCreate = (client) {
    client.badCertificateCallback = (cert, host, port) {
      // Implementar certificate pinning
      return _verifyCertificate(cert);
    };
    return client;
  };
```

---

## A06: Vulnerable Components

**Definición:** Dependencias con vulnerabilidades conocidas.

### 🛡️ Solución Backend

```bash
# ✅ Versionado estricto en poetry.lock
poetry lock --no-update
poetry export -f requirements.txt | grep "==" > requirements.txt

# ✅ Escaneo automático
trivy image softarchitect-backend:latest
# o
pip install bandit && bandit -r src/

# ✅ En CI/CD
name: Security Scan
on: [push]
jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: pip install trivy && trivy fs .
```

### 🛡️ Solución Frontend

```yaml
# ✅ pubspec.lock con versiones exactas
pubspec.lock:
  flutter: ^3.19.0
  riverpod: 2.4.0  # Exacto, no "^2.4.0"

# ✅ Auditoría regular
$ flutter pub outdated
$ flutter pub get  # Con pubspec.lock

# ✅ Pre-commit check
pre-commit:
  - id: pub-check
    name: Flutter Pub Check
    entry: flutter pub get && flutter pub outdated
    language: system
```

---

## A07: Identification & Auth Failures

**Definición:** Autenticación débil, session hijacking, MFA ausente.

### 🛡️ Reglas Obligatorias

| Control | Especificación | Stack |
|:---|:---|:---|
| **Token Expiration** | JWT: 15 minutos máximo | Backend |
| **Refresh Token** | Rotativo, 7 días máximo | Backend |
| **Logout** | Invalidar token en blacklist | Backend |
| **Auto-Logout** | 401 response → Flutter logout automático | Frontend |
| **MFA** | Requerido en producción | Backend + DevOps |

```python
# ✅ GOOD: JWT con expiración + refresh
@app.post("/login")
async def login(credentials: LoginSchema):
    user = await authenticate(credentials.email, credentials.password)

    access_token = create_access_token(user.id, expires_in=timedelta(minutes=15))
    refresh_token = create_refresh_token(user.id, expires_in=timedelta(days=7))

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer",
    }

@app.post("/refresh")
async def refresh(refresh_token: str):
    """Generar nuevo access_token si refresh es válido."""
    user_id = verify_refresh_token(refresh_token)
    new_access_token = create_access_token(user_id, expires_in=timedelta(minutes=15))
    return {"access_token": new_access_token}

@app.post("/logout")
async def logout(current_user: User = Depends(get_current_user)):
    """Agregar token a blacklist."""
    await token_blacklist.add(current_user.token_jti)
    return {"message": "Logged out"}
```

---

## A08: Software & Data Integrity Failures

**Definición:** Fallos en la integridad del software (descargas sin verificación, firma ausente).

### 🛡️ Solución

```bash
# ✅ GOOD: Firmar imágenes Docker en CI/CD
docker build -t softarchitect-backend:latest .
docker sign softarchitect-backend:latest --key my-signing-key

# ✅ GOOD: Verificar checksums en descargas
curl -O https://example.com/package.tar.gz
sha256sum package.tar.gz  # Comparar con valor publicado

# ✅ GOOD: App Signing con gestión segura
# keystore NUNCA en repositorio
# Generado en CI/CD y firmado automáticamente
keytool -genkey -v -keystore release.keystore ...
```

---

## A09: Logging & Monitoring Failures

**Definición:** Logs insuficientes o que exponen datos sensibles.

### 🛡️ Solución Backend

```python
# ✅ GOOD: Structlog JSON con redacción
import structlog

structlog.configure(
    processors=[
        structlog.processors.JSONRenderer(),
    ],
)
logger = structlog.get_logger()

def log_with_redaction(event: str, user_email: str = None, **kwargs):
    """Loguear sin exponer datos sensibles."""
    safe_data = {
        "user_id": kwargs.get("user_id"),  # OK
        # "email": user_email,  # NO, personal data
        "action": kwargs.get("action"),
        "timestamp": datetime.now().isoformat(),
    }
    logger.info(event, **safe_data)

# Uso
@app.post("/login")
async def login(credentials: LoginSchema):
    try:
        user = await authenticate(credentials.email, credentials.password)
        log_with_redaction("user_login", user_id=user.id, action="login")
    except AuthError:
        log_with_redaction("login_failed", action="failed_login")
        raise HTTPException(status_code=401)
```

**Anti-Patterns ❌:**
```python
# ❌ BAD: Loguear contraseña
logger.info(f"User login: {credentials.email}, {credentials.password}")

# ❌ BAD: Loguear JWT completo
logger.info(f"Token: {token}")

# ❌ BAD: Logs sin estructura
print(f"Error: {error_message}")  # Sin timestamp, sin nivel
```

---

## A10: Server-Side Request Forgery (SSRF)

**Definición:** Backend hace peticiones a URLs controladas por usuario (para acceder a intranet).

### 🛡️ Solución Backend

```python
# ✅ GOOD: Validar y whitelist URLs
from urllib.parse import urlparse
import ipaddress

ALLOWED_DOMAINS = ["example.com", "api.example.com"]
BLOCKED_IPS = [
    "127.0.0.1",  # localhost
    "0.0.0.0",
    "169.254.169.254",  # AWS metadata
]

def is_safe_url(url: str) -> bool:
    """Validar que URL es externa segura."""
    parsed = urlparse(url)

    # Validar dominio
    if parsed.netloc not in ALLOWED_DOMAINS:
        return False

    # Validar IP (no privada)
    try:
        ip = ipaddress.ip_address(parsed.hostname)
        if ip.is_private or ip.is_loopback:
            return False
    except:
        pass

    return True

@app.post("/fetch-url")
async def fetch_external_url(url: str):
    """Traer contenido de URL externa."""
    if not is_safe_url(url):
        raise HTTPException(status_code=400, detail="URL not allowed")

    async with httpx.AsyncClient(timeout=5) as client:
        response = await client.get(url)
        return response.json()
```

---

## Linter Rules & Enforcement

El Agente rechazará código que viole:

```python
# ❌ RECHAZADO: eval(), exec() con input
result = eval(user_input)  # CRÍTICO

# ❌ RECHAZADO: Claves hardcodeadas
API_KEY = "sk-1234567890"  # En código fuente

# ❌ RECHAZADO: SQL raw concatenado
query = f"SELECT * FROM users WHERE id = {user_id}"

# ❌ RECHAZADO: print() en src/ (usar logger)
print("Debug info")

# ❌ RECHAZADO: Endpoints sin autenticación (excepto /login, /register)
@app.get("/admin/users")
async def get_all_users():  # Falta Depends(get_current_user)
    pass

# ❌ RECHAZADO: Contraseña sin hash
user.password = plain_password

# ❌ RECHAZADO: Token sin expiración
jwt.encode({"user_id": 123}, SECRET_KEY)  # Falta "exp"

# ❌ RECHAZADO: SharedPreferences para tokens (Flutter)
SharedPreferences.getInstance().setString('token', jwt_token)
```

---

## Pre-Production Security Checklist

Antes de deployer a producción:

```bash
# ✅ 1. Escaneo de vulnerabilidades
trivy image softarchitect-backend:latest

# ✅ 2. Análisis de código estático
bandit -r src/

# ✅ 3. Verificar no hay secretos
git-secrets --scan

# ✅ 4. HTTPS forzado
curl -I https://api.softarchitect.io | grep "Strict-Transport-Security"

# ✅ 5. CORS restrictivo
curl -H "Origin: https://evil.com" https://api.softarchitect.io

# ✅ 6. Autenticación en endpoints sensibles
curl https://api.softarchitect.io/admin/users  # Debe ser 401

# ✅ 7. Rate limiting funciona
for i in {1..10}; do curl https://api.softarchitect.io/login; done  # Último falla

# ✅ 8. JWT expira
TOKEN=$(curl -X POST https://api.softarchitect.io/login -d '...' | jq '.access_token')
sleep 16m
curl -H "Authorization: Bearer $TOKEN" https://api.softarchitect.io/me  # 401

# ✅ 9. Logs NO exponen secretos
grep -i "password\|token\|key" /var/log/softarchitect/* || echo "✅ Safe"

# ✅ 10. Backup y disaster recovery testeado
# (Restaurar base de datos desde backup, verificar integridad)
```

---

## Conclusión

Esta **Matriz de Seguridad es la Ley Absoluta** de SoftArchitect. Cada línea de código debe cumplirla.

**Dogfooding Validation:** SoftArchitect usa esta matriz para auto-validar su propio código.
