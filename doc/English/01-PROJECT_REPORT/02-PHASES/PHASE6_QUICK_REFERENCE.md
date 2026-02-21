# ⚡ FASE 6 Quick Reference

> **Este document es un resumen ejecutivo de FASE 6**
> **Para detalles completos, ver: [PHASE6_E2E_VALIDATION.md](PHASE6_E2E_VALIDATION.md)**

---

## 🚀 Inicio Rápido (5 min)

### 1. Preparar Ambiente

```bash
# Terminal 1: Backend
cd src/server && uvicorn app.main:app --reload

# Terminal 2: ChromaDB
docker-compose up -d chroma

# Terminal 3: Flutter
cd src/client && flutter run -d linux
```

### 2. Execute Script de Validación

```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
bash scripts/validate_hu_3_3.sh
```

### 3. Manual Testing (8 Flujos)

Seguir checklist en [PHASE6_E2E_VALIDATION.md](PHASE6_E2E_VALIDATION.md#manual-e2e-validation-checklist)

---

## ✅ 8 Flujos de Validación

| # | Flujo | Files a Verificar | Tiempo |
|---|-------|----------------------|--------|
| 1 | Create Project | Folders + `10-CONTEXT/` | 5 min |
| 2 | Chat Input | Button state, input field | 5 min |
| 3 | Streaming | TTFT <200ms, animaciones | 10 min |
| 4 | ProposalCard | Markdown, syntax highlighting, copy button | 10 min |
| 5 | Persistencia | File exists on disk, contenido match | 10 min |
| 6 | Regeneración | Contenido diferente, historial OK | 10 min |
| 7 | Rechazo | NO persiste file, progreso OK | 10 min |
| 8 | Errores | Error handling elegante, retry logic | 10 min |

**Total: ~70 minutos manual testing**

---

## 🎯 Criterios de Aceptación (Resumido)

### ✅ Positivos (MUST HAVE)
- [ ] Doc 1 genera correctamente
- [ ] Propuesta NO persiste sin "Validar"
- [ ] Button enviar deshabilitado si input vacío
- [ ] Copy button en bloques de código
- [ ] FileSystemService guarda file
- [ ] Streaming <200ms TTFT
- [ ] Progreso actualiza (Doc N/25)
- [ ] Flujo 100% secuencial

### ❌ Negativos (MUST NOT HAVE)
- [ ] Documents NO se guardan sin "Validar"
- [ ] NO hay stack traces en UI
- [ ] App NO se cuelga con errores de red

---

## 📊 Coverage Target

```bash
# Backend >85%
cd src/server && pytest --cov=app --cov-report=html

# Frontend >80%
cd tests && flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
```

---

## 🔧 Troubleshooting Rápido

| Problema | Solución Rápida |
|----------|-----------------|
| Streaming lento | `python scripts/warm_cache.py` |
| Tests fallan | `flutter clean && flutter pub get` |
| Markdown no renderiza | Reinstalar: `flutter pub add flutter_markdown` |
| App cuelgada | Limitar: `const MAX_PROPOSAL_SIZE = 50000` |

**Troubleshooting completo:** [PHASE6_E2E_VALIDATION.md#troubleshooting](PHASE6_E2E_VALIDATION.md#troubleshooting)

---

## 📈 Métricas Críticas

```bash
# Medir TTFT
python scripts/measure_ttft.py --samples 10
# Esperado: 150ms ± 25ms, p95 < 200ms

# Verificar memoria
flutter run --profile
# Esperado: <100MB por documento

# CPU durante streaming
top -p $(pgrep -f "flutter|uvicorn")
# Esperado: <30% CPU
```

---

## 📋 Files Key

| File | Propósito |
|---------|-----------|
| `scripts/validate_hu_3_3.sh` | Script de validación automático |
| `doc/.../PHASE6_E2E_VALIDATION.md` | Documentación completa |
| `src/server/app/api/v1/chat.py` | SSE endpoint |
| `src/client/lib/features/chat/...` | UI + Chat notifier |
| `tests/test/integration/chat_flow_test.dart` | Integration tests |

---

## 🎊 Definition of Done Resumido

### Código ✅
- Backend tests >85%, Frontend >80%
- Integration tests E2E pasan
- No hay stack traces en errores

### Visual ✅
- Dark Mode estricto
- Animaciones suaves <16ms
- Responsive layout

### Funcional ✅
- Streaming <200ms TTFT
- Validación persiste correctamente
- Manejo de errores elegante

### CI/CD ✅
- GitHub Actions pasa
- No hay warnings de linting
- Coverage reports generados

---

## 🚀 Próximas Etapas

Después de PHASE 6:
1. **Release:** Merge a develop
2. **Tag:** v0.2.0 (HU-3.3 Complete)
3. **Deployment:** Preparar para producción

---

**Última actualización:** 6 febrero 2026
**Documentación Completa:** [PHASE6_E2E_VALIDATION.md](PHASE6_E2E_VALIDATION.md)
**Script:** `bash scripts/validate_hu_3_3.sh`
