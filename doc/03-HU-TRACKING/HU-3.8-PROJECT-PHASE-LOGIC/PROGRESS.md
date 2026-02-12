# HU-3.8 PROGRESS

> **Fecha:** 12/02/2026
> **Estado:** 🚧 Iniciado
> **Branch:** `feature/project_phase_logic`

## 📖 Tabla de Contenidos
- [Estado Global](#estado-global)
- [Checklist por Fase](#checklist-por-fase)
- [Métricas de Calidad](#métricas-de-calidad)
- [Riesgos y Mitigación](#riesgos-y-mitigación)

---

## 📊 Estado Global

- **Fase actual:** Fase 0 (Documentación y preparación)
- **Completado estimado HU:** 8%
- **Bloqueadores:** Ninguno activo
- **Última actualización:** 12/02/2026

---

## ✅ Checklist por Fase

### Fase 0 — Preparación documental
- [x] Crear carpeta `HU-3.8-PROJECT-PHASE-LOGIC`
- [x] Crear `README.md`
- [x] Crear `PROGRESS.md`
- [x] Crear `ARTIFACTS.md`
- [x] Crear `WORKFLOW_MASTER_DEFINITION.md`
- [ ] Revisar y aprobar workflow maestro

### Fase 1 — RED (Modelado y tests que fallan)
- [ ] Definir modelo `ProjectPhase`
- [ ] Definir inventario de plantillas obligatorias por fase
- [ ] Crear tests unitarios de orden de fases (fallando)
- [ ] Crear tests unitarios de obligatoriedad por fase (fallando)
- [ ] Crear tests de cálculo `Doc N/25` (fallando)

### Fase 2 — GREEN (Implementación mínima)
- [ ] Implementar servicio de cálculo de fase actual
- [ ] Implementar validación de artefactos requeridos
- [ ] Implementar cálculo de progreso con fuente en filesystem
- [ ] Lograr pasar tests RED mínimos

### Fase 3 — REFACTOR (Diseño limpio)
- [ ] Eliminar duplicaciones y consolidar mapeos de fase
- [ ] Alinear capas Clean Architecture (Domain/Data/Presentation)
- [ ] Mejorar mensajes de error y tipado
- [ ] Actualizar documentación técnica derivada

### Fase 4 — Integración UI/Estado
- [ ] Integrar cálculo real en dashboard de proyecto
- [ ] Mostrar fase activa + siguiente fase bloqueada/desbloqueada
- [ ] Integrar estado persistido en SQLite/almacenamiento local
- [ ] Añadir casos de integración de transición de fase

### Fase 5 — Quality Gates y Seguridad
- [ ] `dart analyze` sin errores
- [ ] `flutter test` cliente relevante en verde
- [ ] Cobertura módulo HU según objetivo interno
- [ ] Validación de rutas y no traversal
- [ ] Errores de fase mapeados a mensajes amigables

### Fase 6 — Cierre y Evidencia
- [ ] Evidencia de criterios de aceptación AC-1..AC-8
- [ ] Actualización de reportes HU
- [ ] Preparar descripción de PR HU-3.8
- [ ] Checklist final de DoD completado

---

## 📈 Métricas de Calidad

- **Objetivo cobertura lógica HU:** ≥90% (módulos fase/progreso)
- **Objetivo análisis estático:** 0 errores en análisis/lint
- **Objetivo estabilidad:** transición idempotente validada con tests

---

## ⚠️ Riesgos y Mitigación

1. **Riesgo:** Ambigüedad en reglas de conteo de `Doc N/25`.
   - **Mitigación:** Congelar contrato de conteo en tests de dominio antes de integrar UI.

2. **Riesgo:** Divergencia entre templates y validación implementada.
   - **Mitigación:** Fuente única de artefactos desde `packages/knowledge_base/01-TEMPLATES`.

3. **Riesgo:** Regresión en Project Shell existente.
   - **Mitigación:** Tests de integración específicos + rollout incremental.
