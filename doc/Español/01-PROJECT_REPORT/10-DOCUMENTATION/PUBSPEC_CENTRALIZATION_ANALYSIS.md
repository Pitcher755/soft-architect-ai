# 📦 Análisis de Centralización de pubspec.yaml

**Fecha:** 2026-02-11
**Objetivo:** Decidir estrategia de centralización de dependencias Flutter

---

## 🔍 Situación Actual

### Estructura de pubspec.yaml Archivos:

1. **/ Raíz (pubspec.yaml)**
   - **Propósito:** Monorepo orchestration (deprecated)
   - **Dependencies:** flutter, flutter_highlighter, flutter_markdown_plus, flutter_riverpod, web_socket_channel
   - **Problema:** Redundante con pruebas/pubspec.yaml

2. **pruebas/ (pubspec.yaml)**
   - **Propósito:** Prueba suite con dependency a client
   - **Dependencies:** flutter, sqflite, riverpod, shared_preferences, softarchitect_ai (path: ../src/client), mockito, flutter_markdown_plus, web_socket_channel
   - **Dependency override:** softarchitect_ai: path: ../src/client
   - **Uso:** Ejecutar pruebas con `cd pruebas && flutter prueba client/`

3. **src/client/ (pubspec.yaml)**
   - **Propósito:** Flutter app principal
   - **Dependencies:** 35+ packages (crypto, dio, riverpod, go_router, logger, sqflite, etc.)
   - **Es la aplicación real**

---

## 📊 Análisis de Dependencias Compartidas

| Paquete | Raíz | Pruebas | Client | Versión Sincronizada? |
|---------|------|-------|--------|------------------------|
| flutter | SDK | SDK | SDK | ✅ |
| flutter_riverpod | ^3.2.1 | ^3.2.1 | ^3.2.1 | ✅ |
| flutter_markdown_plus | ^1.0.7 | ^1.0.7 | ^1.0.7 | ✅ |
| web_socket_channel | ^3.0.3 | ^3.0.3 | ^3.0.3 | ✅ |
| mockito | - | ^5.6.3 | ^5.6.3 (dev) | ✅ |
| flutter_highlighter | ^0.1.1 | - | ^0.1.1 | ❌ Falta en pruebas |

---

## ⚠️ Problemas Identificados

1. **Redundancia:** pubspec.yaml de raíz contiene dependencias duplicadas de pruebas/client
2. **Desincronización:** flutter_highlighter solo en raíz y client, falta en pruebas
3. **Mantenimiento:** 3 archivos pubspec.yaml para actualizar manualmente
4. **Confusión:** No está claro qué pubspec.yaml usar al ejecutar pruebas

---

## ✅ RECOMENDACIÓN: MANTENER ESTRUCTURA ACTUAL CON MEJORAS

### Justificación:
- **pruebas/pubspec.yaml** necesita path dependency a client para importar código
- **src/client/pubspec.yaml** es la app principal (NO SE PUEDE ELIMINAR)
- **Raíz/pubspec.yaml** es útil para CI/CD y comandos desde raíz

### Estrategia:
1. ✅ **MANTENER los 3 pubspec.yaml** (cada uno tiene propósito específico)
2. ✅ **SINCRONIZAR versiones** de dependencias compartidas
3. ✅ **ELIMINAR dependencias redundantes** de raíz (solo mantener las mínimas)
4. ✅ **DOCUMENTAR** el rol de cada pubspec.yaml

---

## 🔧 Plan de Acción

### 1. Limpiar pubspec.yaml de RAÍZ
**Mantener SOLO:**
- `flutter: sdk: flutter` (mínimo necesario)
- `flutter_prueba: sdk: flutter` (dev dependency para pruebas desde raíz)

**ELIMINAR:**
- flutter_highlighter
- flutter_markdown_plus
- flutter_riverpod
- web_socket_channel

**Motivo:** Estas dependencias ya están en `pruebas/pubspec.yaml` que tiene path dependency a client

### 2. Verificar Sincronización de Versiones

**Verificar en pub.dev versiones más recientes:**
- ✅ flutter_riverpod: ^3.2.1 (laprueba stable)
- ✅ flutter_markdown_plus: ^1.0.7 (laprueba)
- ✅ web_socket_channel: ^3.0.3 (laprueba)
- ⚠️ mockito: ^5.6.3 (verificar si hay más reciente)
- ⚠️ sqflite: ^2.4.2 (verificar actualización)

### 3. Actualizar pruebas/pubspec.yaml
- Agregar flutter_highlighter: ^0.1.1 si se usa en pruebas
- Verificar que todas las dependencias de client estén disponibles

### 4. Documentoar Roles

**Raíz (pubspec.yaml):**
```yaml
# Purpose: Monorepo root for CI/CD orchestration
# Usage: flutter test tests/client/ (from root)
# Dependencies: Minimal (only flutter SDK)
```

**Pruebas (pruebas/pubspec.yaml):**
```yaml
# Purpose: Test suite with path dependency to client app
# Usage: cd tests && flutter test client/
# Dependencies: Test-specific + softarchitect_ai (path: ../src/client)
```

**Client (src/client/pubspec.yaml):**
```yaml
# Purpose: Main Flutter application
# Usage: cd src/client && flutter run
# Dependencies: All production + dev dependencies
```

---

## ✅ Decisión Final

**MANTENER 3 pubspec.yaml con roles claros:**
1. Raíz: Mínimo (solo SDK)
2. Pruebas: Prueba dependencies + path to client
3. Client: App completa

**Beneficios:**
- ✅ Separación clara de responsabilidades
- ✅ Pruebas pueden importar código de client sin duplicar dependencias
- ✅ CI/CD puede ejecutar pruebas desde raíz
- ✅ Evita dependency hell en monorepo

---

## 📝 Comandos Post-Refactor

```bash
# Desde raíz (CI/CD)
flutter test tests/client/

# Desde tests/ (desarrollo local)
cd tests && flutter test client/

# Desde client/ (correr app)
cd src/client && flutter run -d linux
```

---

## 🚀 Próximos Pasos

1. ✅ Limpiar pubspec.yaml de raíz (solo SDK)
2. ✅ Verificar versiones en pruebas/pubspec.yaml y src/client/pubspec.yaml
3. ✅ Actualizar dependencias desincronizadas
4. ✅ Ejecutar `flutter pub get` en cada directorio
5. ✅ Validar que pruebas sigan funcionando
6. ✅ Commitear cambios
