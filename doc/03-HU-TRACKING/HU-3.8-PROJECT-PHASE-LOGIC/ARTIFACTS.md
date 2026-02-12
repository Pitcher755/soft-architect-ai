# HU-3.8 ARTIFACTS MANIFEST

> **Fecha:** 12/02/2026
> **Estado:** 🚧 Inicial

## 📖 Tabla de Contenidos
- [Objetivo](#objetivo)
- [Artefactos de Documentación](#artefactos-de-documentación)
- [Artefactos de Código Esperados](#artefactos-de-código-esperados)
- [Artefactos de Testing Esperados](#artefactos-de-testing-esperados)
- [Evidencias de Validación](#evidencias-de-validación)

---

## 🎯 Objetivo

Inventariar los artefactos necesarios para implementar HU-3.8 con lógica de fases real y progreso `Doc N/25` basado en entregables reales.

---

## 📚 Artefactos de Documentación

### Obligatorios (creados en esta fase)
- `README.md`
- `PROGRESS.md`
- `ARTIFACTS.md`
- `WORKFLOW_MASTER_DEFINITION.md`

### Evolutivos (durante ejecución)
- `ACCEPTANCE_CRITERIA_VERIFICATION.md`
- `IMPLEMENTATION_NOTES.md`
- `FINAL_SUMMARY.md`

---

## 🧩 Artefactos de Código Esperados

### Dominio (client)
- `src/client/lib/features/project_shell/domain/models/project_phase.dart`
- `src/client/lib/features/project_shell/domain/services/project_phase_progress_service.dart`
- `src/client/lib/features/project_shell/domain/value_objects/phase_requirements.dart`

### Data
- `src/client/lib/features/project_shell/data/datasources/template_inventory_datasource.dart`
- `src/client/lib/features/project_shell/data/repositories/project_phase_repository_impl.dart`

### Presentación
- `src/client/lib/features/project_shell/presentation/notifiers/project_phase_notifier.dart`
- `src/client/lib/features/project_shell/presentation/widgets/project_phase_progress_widget.dart`

---

## 🧪 Artefactos de Testing Esperados

### Unit tests
- `tests/client/unit/features/project_shell/domain/models/project_phase_test.dart`
- `tests/client/unit/features/project_shell/domain/services/project_phase_progress_service_test.dart`
- `tests/client/unit/features/project_shell/data/repositories/project_phase_repository_impl_test.dart`

### Widget/Integration tests
- `tests/client/widget/features/project_shell/presentation/widgets/project_phase_progress_widget_test.dart`
- `tests/client/integration/features/project_shell/presentation/project_phase_flow_test.dart`

---

## ✅ Evidencias de Validación

- Reporte de cobertura para módulos de fase/progreso.
- Salida de `flutter test` para suites relevantes.
- Evidencia de transición ROOT → 99-META sobre proyecto de ejemplo.
- Capturas o logs de progreso `Doc N/25` actualizando por fase.
