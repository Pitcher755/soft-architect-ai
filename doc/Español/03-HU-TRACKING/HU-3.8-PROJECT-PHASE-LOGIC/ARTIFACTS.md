# HU-3.8 ARTIFACTS MANIFEST

> **Fecha:** 12/02/2026
> **Estado:** ✅ Actualizado con implementación real

## 📖 Tabla de Contenidos
- [Objetivo](#objetivo)
- [Artefactos de Documentoación](#artefactos-de-documentoación)
- [Artefactos de Código Esperados](#artefactos-de-código-esperados)
- [Artefactos de Pruebaing Esperados](#artefactos-de-pruebaing-esperados)
- [Evidencias de Validación](#evidencias-de-validación)

---

## 🎯 Objetivo

Inventariar los artefactos necesarios para implementar HU-3.8 con lógica de fases real y progreso `Doc N/25` basado en entregables reales.

---

## 📚 Artefactos de Documentoación

### Obligatorios (creados en esta fase)
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
- `src/client/lib/features/proyecto_shell/core/constants/proyecto_structure_constants.dart`
- `src/client/lib/features/proyecto_shell/domain/models/proyecto_fase.dart`
- `src/client/lib/features/proyecto_shell/domain/services/proyecto_fase_service.dart`

### Estado / Providers
- `src/client/lib/features/proyecto_shell/presentation/providers/proyecto_providers.dart`

### Presentación
- `src/client/lib/features/proyecto_shell/presentation/screens/proyecto_shell_screen.dart`
- `src/client/lib/features/proyecto_shell/presentation/widgets/proyectos_grid.dart`
- `src/client/lib/features/proyecto_shell/presentation/widgets/proyecto_card.dart`

---

## 🧪 Artefactos de Pruebaing Implementados

### Unit pruebas
- `pruebas/client/unit/features/proyecto_shell/domain/services/proyecto_fase_service_prueba.dart`
- `pruebas/client/unit/features/proyecto_shell/presentation/notifiers/proyecto_progress_notifier_prueba.dart`

### Widget pruebas relacionados
- `pruebas/client/widget/features/proyecto_shell/presentation/proyecto_card_prueba.dart`

---

## ✅ Evidencias de Validación

- Salida de `flutter prueba` para suites HU-3.8 (dominio + notifier).
- Salida de `flutter analyze` limpia en `src/client/lib/features/proyecto_shell`.
- Salida de `flutter analyze` limpia en `pruebas/`.
- Evidencia de cálculo determinista `Doc N/25` y transición por fases en pruebas.
