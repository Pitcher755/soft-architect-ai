# Guía de Flujo de Trabajo i18n para Futuras Traducciones

> **Fecha:** 10/02/2026
> **Estado:** ✅ COMPLETE
> **Responsable:** ArchitectZero (Localización)

---

## Resumen

Esta guía proporciona instrucciones paso a paso para añadir un nuevo idioma a **SoftArchitect AI** más allá de Inglés (en) y Español (es).

---

## Paso 1: Crear Archivo de Traducción

```bash
# Ejemplo: Añadir Francés (fr)
touch src/client/lib/l10n/app_fr.arb
```

**Estructura del Archivo:**

```json
{
  "@@locale": "fr",
  "@@author": "Tu Nombre",

  "appTitle": "IA Architecte Logicielle",
  "settingsLanguage": "Langue",
  "languageEnglish": "Anglais",
  "languageSpanish": "Espagnol",
  "languageFrench": "Français"
}
```

---

## Paso 2: Traducir Todas las Claves

**Referencia:** Usar `app_en.arb` y `app_es.arb` como plantillas.

```bash
# Contar claves para asegurar que todas están traducidas
wc -l src/client/lib/l10n/app_*.arb

# Esperado: Mismo conteo en todos los archivos (±1 para metadatos de locale)
```

---

## Paso 3: Actualizar Proveedor de Locale

**Archivo:** `src/client/lib/core/localization/locale_provider.dart`

```dart
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return [
    Locale('en'),
    Locale('es'),
    Locale('fr'),  // ← AÑADIR ESTO
  ];
});
```

---

## Paso 4: Regenerar Localizaciones

```bash
cd src/client
flutter gen-l10n
# Genera: lib/gen_l10n/app_localizations_fr.dart
```

---

## Paso 5: Probar Nuevo Idioma

```bash
flutter run
# Configuración → Idioma → Français
# Verificar que todo el texto UI se muestra en Francés
```

---

## Proceso de Validación

```bash
# 1. Verificar claves faltantes
grep -c "\"" src/client/lib/l10n/app_en.arb
grep -c "\"" src/client/lib/l10n/app_fr.arb
# Ambos deberían ser iguales

# 2. Verificar sintaxis JSON
python3 -m json.tool src/client/lib/l10n/app_fr.arb > /dev/null && echo "JSON válido"

# 3. Correr tests
flutter test
```

---

## Flujo de Traducción (Equipo)

### Para Traducción Profesional:

1. **Exportar claves:** `flutter pub global activate intl_utils`
2. **Enviar al traductor:** Exportar CSV desde app.arb
3. **Recibir traducciones:** Importar CSV de vuelta
4. **Validar:** Correr tests y QA

### Herramientas Usadas:

- **Lokalizely** (Cloud-based) o
- **POEditor** (Tier gratis disponible) o
- **Flujo manual CSV**

---

## Checklist de Calidad

- [ ] Todas las claves traducidas (mismo conteo que Inglés)
- [ ] Sintaxis JSON válida
- [ ] Sin cadenas hardcodeadas en código (usar `AppLocalizations.of(context)!.key`)
- [ ] Caracteres especiales escapados correctamente
- [ ] Tests pasando
- [ ] UI probada en dispositivo/emulador
- [ ] Mensaje commit: `feat(i18n): Add French language support`

---

**Última Actualización:** 10/02/2025
**Estado:** ✅ COMPLETE
