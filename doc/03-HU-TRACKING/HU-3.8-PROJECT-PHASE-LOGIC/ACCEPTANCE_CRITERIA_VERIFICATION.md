# HU-3.8 ACCEPTANCE CRITERIA VERIFICATION

> **Fecha:** 12/02/2026
> **Estado:** ✅ Validado

## 📖 Tabla de Contenidos
- [Resumen](#resumen)
- [Matriz AC](#matriz-ac)
- [Evidencias](#evidencias)

---

## 🎯 Resumen

Verificación de criterios de aceptación de HU-3.8 para lógica real de fases y progreso `Doc N/25`.

## ✅ Matriz AC

| AC | Estado | Evidencia |
|---|---|---|
| AC-1 | ✅ | Mapeo ordenado de fases en `project_structure_constants.dart` |
| AC-2 | ✅ | Validación obligatoria por fase en `ProjectPhaseService.calculateProgressFromFiles` |
| AC-3 | ✅ | Cálculo determinista `docsCompleted / 25` en dominio + tests |
| AC-4 | ✅ | ROOT exige `AGENTS.md` y `README.md`; opcionales contabilizan progreso |
| AC-5 | ✅ | No avanza fase si faltan obligatorios; test de bloqueo incluido |
| AC-6 | ✅ | Re-ejecución idempotente por escaneo y cálculo puro sin side effects |
| AC-7 | ✅ | Validación de path con `PathValidator` y fallback controlado |
| AC-8 | ✅ | Tests unitarios de dominio + notifier en verde |

## 🧾 Evidencias

- `flutter test client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
- `flutter test client/unit/features/project_shell/presentation/notifiers/project_progress_notifier_test.dart`
- `flutter analyze ../src/client/lib/features/project_shell`
- `flutter analyze` (workspace `tests/`)
