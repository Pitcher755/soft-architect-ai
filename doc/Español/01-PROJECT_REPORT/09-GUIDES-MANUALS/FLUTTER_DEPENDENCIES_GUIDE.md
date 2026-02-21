## 📦 Dependencias Flutter - SoftArchitect AI Desktop Client

> **Fecha:** 3 de febrero de 2026
> **Estado:** ✅ Instaladas y configuradas
> **Plataforma:** Desktop (Linux, Windows, macOS) + Web (demo)

---

## 📋 Tabla de Dependencias

| Paquete | Versión | Propósito | Plataforma |
|---------|---------|----------|-----------|
| **sqflite** | ^2.4.2 | ORM SQLite (abstracción) | Todos |
| **sqflite_common_ffi** | ^2.4.0+2 | Backend FFI para desktop | 🖥️ Desktop (CRÍTICO) |
| **sqlite3** | ^3.1.4 | Motor SQLite nativo | 🖥️ Desktop (dependencia de sqflite_common_ffi) |
| **path** | ^1.9.1 | Manejo de rutas (multiplataforma) | Todos |
| **archivo_picker** | ^10.3.10 | Diálogo de selección de carpetas | Todos |
| **flutter_riverpod** | ^3.1.0 | State management reactivo | Todos |
| **flutter_markdown** | ^0.7.7+1 | Renderizado Markdown | Todos |
| **highlight** | ^0.7.0 | Syntax highlighting para código | Todos |
| **markdown** | ^7.3.0 | Parser Markdown | Todos |
| **dio** | ^5.9.1 | Cliente HTTP (comunicación Backend) | Todos |
| **go_router** | ^17.0.1 | Navegación/routing | Todos |
| **flutter_dotenv** | ^6.0.0 | Variables de entorno (.env) | Todos |

---

## 🔧 Configuración por Plataforma

### 🖥️ Desktop (Linux, Windows, macOS)

**Stack DB:**
```
sqflite (abstracción)
    ↓
sqflite_common_ffi (FFI backend)
    ↓
sqlite3 (motor nativo)
    ↓
Archivo: ~/.local/share/softarchitect_ai/user_data.db
```

**Inicialización en main.dart:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Crítico: Inicializar sqflite para desktop
  await initializeSqfliteForDesktop();

  runApp(const SoftArchitectApp());
}
```

**Archivo de inicialización:**
- `lib/core/database_initializer.dart` (configuración automática de sqflite_common_ffi)

### 📱 Mobile (iOS/Android) - Futuro

**Stack DB:**
```
sqflite (usa driver nativo iOS/Android)
    ↓
Archivo: /data/data/com.example.softarchitect_ai/databases/user_data.db
```

### 🌐 Web (Demo)

**Futuro:** Implementar `sqflite_web` cuando Flutter Web sea estable para SQLite.

---

## 🚀 Verificación de Instalación

```bash
# Desde src/client/
flutter pub get

# Verificar dependencias instaladas
flutter pub list

# Ejecutar en desktop
flutter run -d linux      # Linux
flutter run -d windows    # Windows
flutter run -d macos      # macOS
```

---

## 📝 Notas Arquitectónicas

### ✅ Database-First Design

1. **SQLite Local:** `user_data.db` contiene SOLO metadatos de proyectos
2. **Ownership:** 100% Flutter (Backend NO toca la DB)
3. **Persistence:** Archivos Markdown + sqflite local
4. **Backend:** Stateless RAG (ChromaDB en Docker)

### 🔐 Seguridad de Datos

- ✅ No se envía `user_data.db` al Backend
- ✅ Backend NO conoce las rutas de proyectos
- ✅ Cifrado local de sensibles (futuro)
- ✅ Validación de rutas antes de dar al Backend

---

## 🐛 Troubleshooting

### Error: "sqflite_common_ffi not found"

**Causa:** sqflite_common_ffi no está instalado
**Solución:**
```bash
cd src/client
flutter pub add sqflite_common_ffi
flutter pub get
```

### Error: "sqlite3 native bindings failed"

**Causa:** Falta compilador C en sistema
**Solución (Linux):**
```bash
sudo apt-get install build-essential
```

**Solución (macOS):**
```bash
xcode-select --install
```

### Database archivo not creard

**Causa:** Carpeta de datos no existe
**Solución:** DatabaseHelper crea automáticamente en `getDatabasesPath()`

---

## 📚 Referencias

- [sqflite documentoation](https://pub.dev/packages/sqflite)
- [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
- [flutter_riverpod](https://riverpod.dev/)
- [archivo_picker](https://pub.dev/packages/archivo_picker)
