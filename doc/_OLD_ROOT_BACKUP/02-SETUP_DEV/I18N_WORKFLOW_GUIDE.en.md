# i18n Workflow Guide for Future Translations

> **Fecha:** 10/02/2026
> **Estado:** ✅ COMPLETE
> **Responsable:** ArchitectZero (Localization)

---

## Overview

This guide provides step-by-step instructions for adding a new language to **SoftArchitect AI** beyond English (en) and Spanish (es).

---

## Step 1: Create Translation File

```bash
# Example: Adding French (fr)
touch src/client/lib/l10n/app_fr.arb
```

**File Structure:**

```json
{
  "@@locale": "fr",
  "@@author": "Your Name",

  "appTitle": "IA Architecte Logicielle",
  "settingsLanguage": "Langue",
  "languageEnglish": "Anglais",
  "languageSpanish": "Espagnol",
  "languageFrench": "Français"
}
```

---

## Step 2: Translate All Keys

**Reference:** Use `app_en.arb` and `app_es.arb` as templates.

```bash
# Count keys to ensure all are translated
wc -l src/client/lib/l10n/app_*.arb

# Expected: Same count across all files (±1 for locale metadata)
```

---

## Step 3: Update Locale Provider

**File:** `src/client/lib/core/localization/locale_provider.dart`

```dart
final supportedLocalesProvider = Provider<List<Locale>>((ref) {
  return [
    Locale('en'),
    Locale('es'),
    Locale('fr'),  // ← ADD THIS
  ];
});
```

---

## Step 4: Regenerate Localizations

```bash
cd src/client
flutter gen-l10n
# Generates: lib/gen_l10n/app_localizations_fr.dart
```

---

## Step 5: Test New Language

```bash
flutter run
# Settings → Language → Français
# Verify all UI text displays in French
```

---

## Validation Process

```bash
# 1. Check for missing keys
grep -c "\"" src/client/lib/l10n/app_en.arb
grep -c "\"" src/client/lib/l10n/app_fr.arb
# Both should be equal

# 2. Verify JSON syntax
python3 -m json.tool src/client/lib/l10n/app_fr.arb > /dev/null && echo "Valid JSON"

# 3. Run tests
flutter test
```

---

## Translation Workflow (Team)

### For Professional Translation:

1. **Export keys:** `flutter pub global activate intl_utils`
2. **Send to translator:** Export CSV from app.arb
3. **Receive translations:** Import CSV back
4. **Validate:** Run tests and QA

### Tools Used:

- **Lokalizely** (Cloud-based) or
- **POEditor** (Free tier available) or
- **Manual CSV workflow**

---

## Quality Checklist

- [ ] All keys translated (same count as English)
- [ ] JSON syntax valid
- [ ] No hardcoded strings in code (use `AppLocalizations.of(context)!.key`)
- [ ] Special characters properly escaped
- [ ] Tests passing
- [ ] UI tested on device/emulator
- [ ] Commit message: `feat(i18n): Add French language support`

---

**Last Updated:** 10/02/2025
**Status:** ✅ COMPLETE
