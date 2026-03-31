# 📊 PIT-106 — Cobertura Flutter con Umbral en CI

> **Fecha:** 31/03/2026
> **Estado:** ✅ **COMPLETADO**
> **Rama:** `feature/hu-5.1-flutter-coverage`
> **Linear:** [PIT-106](https://linear.app/pitcherdev/issue/PIT-106)

## 📋 Tabla de Contenidos

1. [Resumen](#resumen)
2. [Cambios](#cambios)
3. [Resultados de Cobertura](#resultados-de-cobertura)
4. [Archivos Modificados](#archivos-modificados)

---

## Resumen

| Métrica | Valor |
|---------|-------|
| **Ticket** | PIT-106 — [HU-5.1] Cobertura Flutter con umbral 80% en CI |
| **Cobertura domain/** | 93.9% ✅ |
| **Cobertura infrastructure/** | 85.0% ✅ |
| **Cobertura global** | 78.6% (informativo) |
| **Umbral mínimo** | ≥80% en domain/ e infrastructure/ |
| **Pipeline CI** | ci-master.yaml actualizado |

---

## Cambios

### 1. Nuevo Script: `scripts/testing/flutter_coverage_check.sh`

Verificador de cobertura Flutter independiente con enforcement de umbral:

- Ejecuta `flutter test --coverage` desde `src/client/`
- Filtra archivos generados: `*.g.dart`, `*.freezed.dart`, `gen/`, `l10n/`
- Extrae cobertura por directorio mediante `lcov --extract`
- Aplica **≥80%** en capas críticas de negocio: `domain/` e `infrastructure/`
- Reporta cobertura global como informativa (no se aplica umbral)
- Genera reporte HTML con `genhtml`
- Escribe tabla resumen en GitHub Actions step summary
- Código de salida 0 = pasa, 1 = falla

**Uso:**

```bash
./scripts/testing/flutter_coverage_check.sh --threshold=80 --html
```

### 2. Actualización del Pipeline CI: `ci-master.yaml`

Se añadieron dos nuevos pasos al job Frontend:

| Paso | Propósito |
|------|-----------|
| 📋 Install lcov | Asegura que `lcov` esté disponible en el runner |
| 📊 Flutter Coverage Threshold (≥80%) | Ejecuta `flutter_coverage_check.sh`, falla CI si no cumple el umbral |

El artefacto de cobertura ahora sube el directorio `coverage/` completo (lcov + HTML).

### 3. Actualización de Scripts

| Script | Cambio |
|--------|--------|
| `PRE_PUSH_VALIDATION_MASTER.sh` | La Fase 7 ahora delega la cobertura Flutter a `flutter_coverage_check.sh` |
| `generate_coverage_html.sh` | Se añadió filtrado de archivos generados antes de la generación HTML |

---

## Resultados de Cobertura

**Desglose por directorio (filtrado, excluye archivos generados):**

| Directorio | Cobertura | Umbral | Estado |
|------------|-----------|--------|--------|
| domain/ | 93.9% | 80% | ✅ |
| infrastructure/ | 85.0% | 80% | ✅ |
| core/ | 80.6% | — | ℹ️ |
| features/ | 80.9% | — | ℹ️ |
| services/ | 63.7% | — | ℹ️ |
| shared/ | 70.2% | — | ℹ️ |
| **Global** | **78.6%** | — | ℹ️ |

**Excluidos de la cobertura:**
- `*.g.dart` (generación de código)
- `*.freezed.dart` (Freezed unions)
- `gen/` (assets generados)
- `l10n/` (localización)

---

## Archivos Modificados

| Archivo | Acción | Descripción |
|---------|--------|-------------|
| `scripts/testing/flutter_coverage_check.sh` | **Creado** | Verificador de cobertura Flutter con umbral |
| `.github/workflows/ci-master.yaml` | Modificado | Añadido install lcov + step de umbral de cobertura |
| `scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh` | Modificado | Delegada cobertura Flutter al nuevo script |
| `scripts/testing/generate_coverage_html.sh` | Modificado | Añadido filtrado de archivos generados |
