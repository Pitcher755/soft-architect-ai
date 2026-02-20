# HU-3.8 ARTIFACTS MANIFEST

> **Date:** 12/02/2026
> **Status:** ✅ Actualizado con implementation real

## 📖 Table of Contents
- [Objetivo](#objetivo)
- [Artefactos de Documentación](#artefactos-de-documentación)
- [Artefactos de Código Esperados](#artefactos-de-código-esperados)
- [Artefactos de Testing Esperados](#artefactos-de-testing-esperados)
- [Evidencias de Validación](#evidencias-de-validación)

---

## 🎯 Objetivo

Inventariar los artefactos necesarios para implementar HU-3.8 con lógica de phases real y progreso `Doc N/25` basado en entregables reales.

---

## 📚 Artefactos de Documentación

### Obligatorios (creados en esta phase)
- `README.md`
- `PROGRESS.md`
- `ARTIFACTS.md`
- `WORKFLOW_MASTER_DEFINITION.md`

### Evolutivos (durante ejecución)
- `ACCEPTANCE_CRITERIA_VERIFICATION.md`
- `FINAL_SUMMARY.md`

---

## 🧩 Artefactos de Código Implementados

### Dominio (client)
- `src/client/lib/features/project_shell/core/constants/project_structure_constants.dart`
- `src/client/lib/features/project_shell/domain/models/project_phase.dart`
- `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`

### Status / Providers
- `src/client/lib/features/project_shell/presentation/providers/project_providers.dart`

### Presentación
- `src/client/lib/features/project_shell/presentation/screens/project_shell_screen.dart`
- `src/client/lib/features/project_shell/presentation/widgets/projects_grid.dart`
- `src/client/lib/features/project_shell/presentation/widgets/project_card.dart`

---

## 🧪 Artefactos de Testing Implementados

### Unit tests
- `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
- `tests/client/unit/features/project_shell/presentation/notifiers/project_progress_notifier_test.dart`

### Widget tests relacionados
- `tests/client/widget/features/project_shell/presentation/project_card_test.dart`

---

## ✅ Evidencias de Validación

- Salida de `flutter test` para suites HU-3.8 (dominio + notifier).
- Salida de `flutter analyze` limpia en `src/client/lib/features/project_shell`.
- Salida de `flutter analyze` limpia en `tests/`.
- Evidencia de cálculo determinista `Doc N/25` y transición por phases en tests.
