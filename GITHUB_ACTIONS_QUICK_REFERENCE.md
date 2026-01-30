# ⚡ GitHub Actions Quick Reference

> Guía ultra-rápida para copypastear cuando necesites

---

## 🚀 Cheat Sheet Rápido

### Ver workflows en ejecución
```bash
# Terminal
git push origin feature/backend-skeleton

# Luego en GitHub.com:
# 1. Actions tab
# 2. Click en "SoftArchitect AI CI" (o tu workflow)
# 3. Espera el status
```

### Si falla un test
```bash
# 1. Haz clic en el job rojo ❌ en GitHub
# 2. Lee el error
# 3. En tu máquina:
pytest tests/  # Re-corre el test
# 4. Arréglalo y:
git add .
git commit -m "Fix: test X"
git push
# El workflow se ejecuta automáticamente 🤖
```

### Ver logs completos
```
GitHub.com
→ Actions
→ Click en workflow
→ Click en job
→ Click en step
→ Ver output completo
```

---

## 📋 Workflows en el Proyecto

| Workflow | Trigger | Duración | Verifica |
|----------|---------|----------|----------|
| `backend-ci.yaml` | Cambios en `api/`, `core/`, etc. | 2-3 min | Python: lint, tests, security |
| `frontend-ci.yaml` | Cambios en `src/client/` | 3-5 min | Flutter: analysis, tests, build |
| `docker-build.yaml` | Cambios en `Dockerfile*` | 2-4 min | Docker: syntax, build, security |
| `ci-master.yaml` | Todo push/PR | 5-15 min | Orquesta los otros 3 |
| `lint.yml` | Cambios en `src/` | 3-5 min | Flutter + Python lint |

---

## 🔑 Conceptos Clave

**Event (Disparador)**
```yaml
on:
  push:
    branches: [main, develop]
    paths: ['api/**']  # Solo si tocas estas carpetas
```

**Job (Tarea)**
```yaml
jobs:
  unit-tests:
    runs-on: ubuntu-latest  # Máquina virtual
    steps: [...]
```

**Step (Paso individual)**
```yaml
steps:
  - name: Run Tests
    run: pytest tests/ -v
```

**Status Badge en README (opcional)**
```markdown
[![Tests](https://github.com/Pitcher755/soft-architect-ai/actions/workflows/backend-ci.yaml/badge.svg)](https://github.com/Pitcher755/soft-architect-ai/actions)
```

---

## 🎓 Patrón TDD + GHA

### Local Development Loop
```
1. Escribir test que falla ❌
2. Escribir código que lo arregla ✅
3. Test pasa localmente
4. git push
5. GitHub Actions corre el mismo test
6. Ambos pasan → Merge seguro 🚀
```

### Beneficio
No hay sorpresas en producción. GitHub te prueba que funciona **antes** de que lo mergees.

---

## 🛠️ Configurar Secrets (Variables Seguras)

Para API keys, passwords, etc.:

1. GitHub.com → Settings → Secrets and variables → Actions
2. "New repository secret"
3. Name: `DEPLOY_KEY`, Value: `tu-key-aqui`
4. En tu YAML:
```yaml
- name: Deploy
  env:
    DEPLOY_KEY: ${{ secrets.DEPLOY_KEY }}
  run: ./deploy.sh
```

---

## 📊 Interpretar Badge de Status

```
🟢 Green  = All passing    → Merge OK
🟡 Yellow = Running        → Wait
🔴 Red    = Failed         → Fix before merge
⚪ None   = Not triggered  → Check event trigger
```

---

## 🔗 Enlaces Útiles

- [GitHub Docs](https://docs.github.com/en/actions)
- [Workflow Syntax](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)
- [Actions Marketplace](https://github.com/marketplace?type=actions)

---

## 📱 Notificaciones

### Recibir alertes en tu teléfono
- Descarga app GitHub
- Settings → Notifications
- Recibirás push cuando workflows fallen

### Slack Integration (opcional)
```yaml
- name: Notify Slack
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Deployment ${{ job.status }}'
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

---

## ⚠️ Errores Comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `No workflows running` | Actions no dispara | Verifica `paths:` en trigger |
| `Test passes local, fails CI` | Env diferente | Usa `.env` con valores de test |
| `Module not found` | requirements.txt desactualizado | `pip freeze > requirements.txt` |
| `Timeout` | Proceso lento | Aumenta `timeout-minutes:` |
| `Permission denied` | Scripts sin execute bit | `chmod +x script.sh` |

---

## 🎯 Próxima Sesión

- **Scheduled runs:** Tests cada noche
- **Auto-deploy:** Main branch → staging automáticamente
- **Badge en README:** Mostrar que tests pasan
- **Branch protection:** No puedes mergear si tests fallan

---

**Recuerda:** GitHub Actions = Tu robot QA que nunca duerme 🤖
