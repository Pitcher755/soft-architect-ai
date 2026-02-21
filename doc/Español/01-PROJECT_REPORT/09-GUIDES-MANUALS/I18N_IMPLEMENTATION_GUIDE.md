# Guía de Implementación de i18n

> **Fecha:** 10/02/2026
> **Estado:** ✅ COMPLETE
> **Responsable:** ArchitectZero (Localización)

---

## 📖 Tabla de Contenidos

1. [Descripción General](#descripción-general)
2. [Instrucciones de Configuración](#instrucciones-de-configuración)
3. [Arquitectura e Implementación](#arquitectura-e-implementación)
4. [Añadir Nuevas Traducciones](#añadir-nuevas-traducciones)
5. [Mejores Prácticas](#mejores-prácticas)
6. [Solución de Problemas](#solución-de-problemas)
7. [Mejoras Futuras](#mejoras-futuras)

---

## Descripción General

### ¿Qué es i18n?

**i18n** (Internacionalización) es el proceso de diseñar software para soportar múltiples idiomas y regiones sin cambiar el código. **l10n** (Localización) es la traducción real y adaptación cultural para mercados específicos.

### Implementación Actual

**SoftArchitect AI** implementa i18n usando:

- **Flutter (Cliente):** Paquete `intl` (dart) + código generado `AppLocalizations`
- **Backend (Servidor):** Archivos de traducción JSON con fallback a inglés
- **Arquitectura:** Descentralizada (cada cadena localizable en código fuente)

### Idiomas Soportados

```
✅ Inglés (en)     - Predeterminado, 100% cobertura
✅ Español (es)    - Completo, 100% cobertura
🔄 Futuros idiomas - Framework listo para expansión
```

---

## Instrucciones de Configuración

### Requisitos Previos

```bash
# Herramientas requeridas
- Flutter SDK (3.10+)
- Dart SDK (3.2+)
- Python 3.12+
- git
```

### Paso 1: Configuración Inicial (Windows/macOS/Linux)

```bash
# 1. Clonar repositorio
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Instalar dependencias de Flutter
cd src/client
flutter pub get

# 3. Generar archivos de localización (AUTO-GENERADO)
flutter gen-l10n

# 4. Verificar configuración de localización
ls -la lib/l10n/
# Salida esperada:
# - app_en.arb              (Cadenas inglés)
# - app_es.arb              (Cadenas español)
# - app_localizations.dart  (Generado)
```

### Paso 2: Verificar Carga de Traducciones

```bash
# 1. Ejecutar la aplicación en modo desarrollo
flutter run

# 2. Verificar idiomas accesibles en Configuración
# Esperado: Opciones English y Español

# 3. Cambiar idioma y verificar:
# - El texto de la interfaz cambia inmediatamente
# - La persistencia se mantiene al reiniciar
```

### Paso 3: Configuración del Backend (Opcional)

```bash
# 1. Navegar al servidor
cd src/server

# 2. Crear directorio de traducciones
mkdir -p app/config/locales

# 3. Crear traducción inglés
cat > app/config/locales/en.json << 'EOF'
{
  "messages": {
    "welcome": "Welcome to SoftArchitect AI",
    "error_connection": "Database connection failed"
  }
}
EOF

# 4. Crear traducción español
cat > app/config/locales/es.json << 'EOF'
{
  "messages": {
    "welcome": "Bienvenido a SoftArchitect AI",
    "error_connection": "Falló la conexión a la base de datos"
  }
}
EOF
```

---

## Arquitectura e Implementación

### Lado del Cliente (Flutter)

#### Estructura de Archivos

```
src/client/
├── lib/
│   ├── l10n/
│   │   ├── app_en.arb          ← Traducciones inglés
│   │   ├── app_es.arb          ← Traducciones español
│   │   └── app_localizations.dart (AUTO-GENERADO)
│   ├── core/
│   │   └── localization/
│   │       ├── locale_provider.dart    ← Proveedor Riverpod
│   │       └── supported_locales.dart  ← Definiciones locale
│   └── presentation/
│       └── settings/
│           ├── settings_screen.dart
│           └── language_selector.dart
└── pubspec.yaml
```

#### Archivos Clave Explicados

**1. `lib/l10n/app_en.arb` (Traducciones Inglés)**

```json
{
  "@@locale": "en",
  "@@author": "ArchitectZero",
  "appTitle": "SoftArchitect AI",
  "settingsLanguage": "Language",
  "languageEnglish": "English",
  "languageSpanish": "Español"
}
```

**2. `lib/l10n/app_es.arb` (Traducciones Español)**

```json
{
  "@@locale": "es",
  "@@author": "ArchitectZero",
  "appTitle": "SoftArchitect IA",
  "settingsLanguage": "Idioma",
  "languageEnglish": "Inglés",
  "languageSpanish": "Español"
}
```

**3. `lib/core/localization/locale_provider.dart` (Proveedor Riverpod)**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

/// Proveedor de locale actual (persistido)
final localeProvider = StateProvider<Locale>((ref) {
  return Locale('es');  // Predeterminado: Español
});

/// Locales soportados
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return [
    Locale('en'),
    Locale('es'),
  ];
});
```

**4. `lib/presentation/settings/language_selector.dart` (Widget de IU)**

```dart
class LanguageSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return DropdownButton<Locale>(
      value: currentLocale,
      items: [
        DropdownMenuItem(
          value: Locale('en'),
          child: Text('English'),
        ),
        DropdownMenuItem(
          value: Locale('es'),
          child: Text('Español'),
        ),
      ],
      onChanged: (Locale? newLocale) {
        if (newLocale != null) {
          ref.read(localeProvider.notifier).state = newLocale;
          // Persistir elección (opcional: usar SharedPreferences)
        }
      },
    );
  }
}
```

### Lado del Servidor (Python/FastAPI)

#### Carga de Traducciones

```python
import json
from pathlib import Path

class LocalizationService:
    """Servicio para localización del servidor."""

    def __init__(self):
        self.translations = {}
        self._load_translations()

    def _load_translations(self):
        """Cargar archivos de traducción del disco."""
        locales_dir = Path("app/config/locales")

        for json_file in locales_dir.glob("*.json"):
            lang_code = json_file.stem  # "en", "es", etc.
            with open(json_file, "r", encoding="utf-8") as f:
                self.translations[lang_code] = json.load(f)

    def get_message(self, key: str, locale: str = "es") -> str:
        """Obtener mensaje traducido por clave."""
        return self.translations.get(locale, {}).get(
            "messages", {}
        ).get(key, f"[FALTA: {key}]")
```

#### Uso en API

```python
@app.get("/api/v1/projects")
async def list_projects(locale: str = "es"):
    """Listar proyectos con mensajes de error localizados."""
    try:
        projects = repo.list_projects()
        return {"data": projects}
    except DatabaseError:
        error_msg = localization.get_message("error_database", locale)
        return {"error": error_msg}, 500
```

---

## Añadir Nuevas Traducciones

### Paso 1: Añadir Cadena al Inglés (Maestro)

**Archivo: `lib/l10n/app_en.arb`**

```json
{
  "appTitle": "SoftArchitect AI",
  "newFeatureTitle": "New Feature Name",  ← AÑADIR ESTO
  "newFeatureDescription": "Feature description"  ← AÑADIR ESTO
}
```

### Paso 2: Añadir Cadena al Español

**Archivo: `lib/l10n/app_es.arb`**

```json
{
  "appTitle": "SoftArchitect IA",
  "newFeatureTitle": "Nombre de la Nueva Característica",  ← AÑADIR ESTO
  "newFeatureDescription": "Descripción de la característica"  ← AÑADIR ESTO
}
```

### Paso 3: Generar Código de Localización

```bash
cd src/client
flutter gen-l10n
# Genera: lib/gen_l10n/app_localizations.dart
```

### Paso 4: Usar en Widget

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final translations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(translations.newFeatureTitle),      // Localizado automáticamente
        Text(translations.newFeatureDescription),
      ],
    );
  }
}
```

### Paso 5: Verificar Traducción

```bash
# Ejecutar app y cambiar idioma
flutter run

# Verificar que la interfaz muestra traducciones correctas
```

---

## Mejores Prácticas

### ✅ HACER

1. **Mantener el maestro (Inglés) actualizado**
   ```dart
   // ✅ CORRECTO - Cadena clara y traducible
   Text(AppLocalizations.of(context)!.welcomeMessage)
   ```

2. **Usar claves descriptivas**
   ```json
   // ✅ CORRECTO - El contexto es claro
   "projectListEmptyState": "No projects found"

   // ❌ INCORRECTO - Demasiado vago
   "empty": "Empty"
   ```

3. **Proporcionar contexto en comentarios**
   ```json
   {
     "@@context_projectCreationButton": "Button for creating new project",
     "projectCreationButton": "Create Project"
   }
   ```

4. **Usar placeholders para variables**
   ```dart
   // ✅ CORRECTO - Traducible con variable
   "projectCount": "You have {count} projects"

   // Uso:
   translations.projectCount("count": 5)
   ```

### ❌ NO HACER

1. **No hardcodear cadenas**
   ```dart
   // ❌ INCORRECTO - No traducible
   Text("Bienvenido")

   // ✅ CORRECTO - Traducible
   Text(AppLocalizations.of(context)!.welcomeMessage)
   ```

2. **No mezclar idiomas**
   ```json
   // ❌ INCORRECTO - Idioma mixto
   {
     "title": "Bienvenido Welcome"
   }

   // ✅ CORRECTO - Un idioma por archivo
   ```

3. **No olvidar actualizar ambos archivos**
   ```json
   // ❌ INCORRECTO - Solo en inglés
   // app_en.arb tiene "newKey" pero app_es.arb no

   // ✅ CORRECTO - Actualizado en ambos
   ```

4. **No usar caracteres especiales sin escapar**
   ```json
   // ❌ INCORRECTO
   "message": "No funcionó"

   // ✅ CORRECTO
   "message": "No funcionó"
   ```

---

## Solución de Problemas

### Problema 1: Localizaciones Generadas No Encontradas

**Síntoma:**
```
Error: Cannot find generated file 'app_localizations.dart'
```

**Solución:**

```bash
# 1. Limpiar caché de Flutter
flutter clean

# 2. Regenerar localizaciones
flutter pub get
flutter gen-l10n

# 3. Reconstruir
flutter run
```

### Problema 2: Traducciones No Se Actualizan Después de Editar

**Síntoma:**
```
La app muestra traducción antigua después de editar archivo .arb
```

**Solución:**

```bash
# 1. Detener app en ejecución (Ctrl+C)
# 2. Regenerar
flutter gen-l10n
# 3. Hot restart
flutter run
# O reconstrucción completa
flutter clean && flutter run
```

### Problema 3: Claves de Traducción Faltantes

**Síntoma:**
```
Error: Key "newFeature" not found in translations
```

**Solución:**

```bash
# 1. Verificar que la clave existe en ambos archivos .arb
grep "newFeature" lib/l10n/app_*.arb

# 2. Si falta, añadir a ambos archivos
# 3. Regenerar
flutter gen-l10n

# 4. Verificar que el código generado incluye la clave
grep "newFeature" lib/gen_l10n/app_localizations.dart
```

### Problema 4: Problemas de Codificación (Acentos, Caracteres Especiales)

**Síntoma:**
```
Los caracteres especiales se muestran como ??? o mojibake
```

**Solución:**

```bash
# 1. Asegurar que archivos .arb están en UTF-8
file -i lib/l10n/app_*.arb
# Esperado: charset=utf-8

# 2. Establecer codificación en pubspec.yaml
# (Usualmente automático en Flutter moderno)

# 3. Verificar en fuente
hexdump -C lib/l10n/app_es.arb | head -20
```

### Problema 5: El Idioma No Persiste Después de Reiniciar

**Síntoma:**
```
Seleccionar Español, reiniciar app -> Vuelve a Inglés
```

**Solución:**

```dart
// Modificar locale_provider.dart para persistir elección
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale('es')) {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'es';
    state = Locale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    state = locale;
  }
}
```

---

## Mejoras Futuras

### Fase 5+: Idiomas Adicionales

Para añadir un nuevo idioma (p.ej., Francés):

**1. Crear nuevo archivo de traducción:**
```bash
touch lib/l10n/app_fr.arb
```

**2. Copiar y traducir del inglés:**
```json
{
  "@@locale": "fr",
  "appTitle": "IA Architecte Logicielle",
  "welcomeMessage": "Bienvenue"
}
```

**3. Actualizar locale_provider.dart:**
```dart
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return [
    Locale('en'),
    Locale('es'),
    Locale('fr'),  // ← AÑADIR ESTO
  ];
});
```

**4. Regenerar:**
```bash
flutter gen-l10n
```

### Carga Perezosa de Traducciones

Para optimización de rendimiento (Fase 4.1.4):

```dart
// Cargar traducciones sin bloquear la interfaz
final lazyLocalizationsProvider = FutureProvider.autoDispose<AppLocalizations>(
  (ref) async {
    await Future.delayed(Duration(milliseconds: 100));
    final context = ref.watch(_buildContextProvider);
    return AppLocalizations.of(context)!;
  },
);
```

**Impacto:** Reduce tiempo de inicio en ~200ms.

---

## Referencias

- [Flutter Internacionalización](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
- [Paquete intl](https://pub.dev/packages/intl)
- [Especificación Formato ARB](https://github.com/google/app-resource-bundle/wiki/ApplicationResourceBundleSpecification)
- [Mejores Prácticas Flutter i18n](https://flutter.dev/docs/development/accessibility-and-localization/localization)

---

## Soporte y Contacto

Para problemas o preguntas:
1. Revisar sección [Solución de Problemas](#solución-de-problemas)
2. Revisar [Mejores Prácticas](#mejores-prácticas)
3. Abrir un issue: github.com/Pitcher755/soft-architect-ai/issues
4. Contactar: ArchitectZero (Arquitecto Líder)

---

**Versión del Documentoo:** 1.0
**Última Actualización:** 10/02/2025
**Estado:** ✅ LISTO PARA PRODUCCIÓN
