# 🚀 FASE 0: INICIO (Pre-Sprint Setup)

> **Fecha:** 02/02/2026
> **Estado:** ⏳ AWAITING USER CONFIRMATION
> **Duración:** Week of 02/02 (3-5 days)
> **Owner:** Tech Lead + Product Manager

---

## 📋 RESUMEN FASE 0

Fase preparatoria ANTES de comenzar el código.

**Objetivos:**
1. ✅ Usuario confirma decisión (✅ Proceder / ❌ No / 🤔 Modificar)
2. ✅ Obtener aprobaciones de stakeholders
3. ✅ Asignar recursos (team members)
4. ✅ Alinear toolchain
5. ✅ Crear plan de comunicación

**Entregables:**
- ✅ Decisión confirmada (documentoo)
- ✅ Lista de stakeholders aprobados
- ✅ Team roster asignado
- ✅ Comunicado de launch
- ✅ PR Draft abierto

**Duración:** 3-5 días de trabajo

---

## ✅ CHECKLIST FASE 0 (Paso a Paso)

### 1️⃣ DECISIÓN FINAL (HOY - Usuario)

**Acción:** Comentar en esta conversación

```
Tu decisión:

✅ PROCEDER - Comenzar Project-First refactor (RECOMENDADO)
   Razones: [Listar 2-3 razones por qué]

❌ NO PROCEDER - Mantener Chat-First actual
   Razones: [Listar 2-3 razones por qué]

🤔 MODIFICAR - Tengo cambios propuestos
   Cambios: [Listar modificaciones deseadas]
```

**Si Usuario NO comenta:**
- ⏳ ArchitectZero espera confirmación
- ⏳ NO proceder sin confirmación explícita

**Resultadoado:** Documentoo de decisión archivado

---

### 2️⃣ APROBACIONES STAKEHOLDERS (Día 1-2)

**Requerido:** ANTES de que Tech Lead comience

**Stakeholders a contactar:**
- [ ] Product Owner (Pitcher755)
- [ ] CTO / Tech Lead
- [ ] Design Lead (UI/UX)
- [ ] QA Manager
- [ ] DevOps Lead

**Documentoo a compartir:**
→ HU-3_EXECUTIVE_SUMMARY.es.md (10 min read)

**Proceso:**
1. Enviar correo: "Solicitud de aprobación - Proyecto-First Refactor"
2. Adjuntar: Documentoo ejecutivo
3. Fecha límite: 02/02/2026 EOD
4. Resultadoado: Aprobaciones confirmadas en una lista

**Checklist de Aprobación:**
```
Stakeholder              Status
─────────────────────────────────
Product Owner            [ ] ✅ / [ ] ❌
Tech Lead / CTO          [ ] ✅ / [ ] ❌
Design Lead              [ ] ✅ / [ ] ❌
QA Manager               [ ] ✅ / [ ] ❌
DevOps Lead              [ ] ✅ / [ ] ❌

Quórum: 4/5 mínimo
```

**Si alguno dice ❌:** Discutir preocupaciones + ajustar plan

---

### 3️⃣ ASIGNACIÓN DE RECURSOS (Día 2)

**Tech Lead completa:**

#### A. Roster de Team

```
ROL                      NOMBRE          EMAIL         DEDICACIÓN
────────────────────────────────────────────────────────────────
Tech Lead                [TBD]           [TBD]         100% (8 sem)
Backend Lead             [TBD]           [TBD]         100% (8 sem)
Frontend Lead            [TBD]           [TBD]         100% (8 sem)
QA Engineer              [TBD]           [TBD]         50% (7 sem)
DevOps / Infra           [TBD]           [TBD]         25% (8 sem)
────────────────────────────────────────────────────────────────
TOTAL FTE: 3.75 (slightly above planned 3.5)
```

#### B. Capacitación Requerida

```
Tema                          Owner    Duration  Deadline
─────────────────────────────────────────────────────────
RAG Local (Ollama)            ArchitectZero  1h    02/02
Sequential Workflow           Tech Lead      1h    02/03
FileSystemService API         Backend Lead   1h    02/04
Flutter Project Navigation    Frontend Lead  1h    02/04
ChromaDB Integration          Backend Lead   2h    02/05
```

**Proceso:**
1. Tech Lead completa tabla
2. Envía correo a equipo: "Capacitación Pre-Sprint"
3. Agenda sesiones
4. Registra asistencia

---

### 4️⃣ ALINEACIÓN DE TOOLCHAIN (Día 2-3)

**DevOps Lead completa:**

#### A. Verificar Docker Stack

```bash
# En la máquina de CADA developer

cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Validar docker compose
docker-compose -f infrastructure/docker-compose.yml config

# Resultado esperado:
# services:
#   ollama:  ✅ Running
#   chroma:  ✅ Running
#   postgres: ✅ Running
```

**Checklist:**
- [ ] Docker Desktop corriendo
- [ ] docker-compose version >= 2.0
- [ ] docker --version >= 24.0
- [ ] Internet para descargar imágenes
- [ ] 16GB RAM mínimo
- [ ] 20GB disco para modelos Ollama

#### B. Verificar Python Environment

```bash
# En cada máquina developer (Backend)

cd src/server

# Crear venv
python3.12 -m venv venv
source venv/bin/activate

# Instalar deps
pip install -r requirements.txt

# Verificar imports
python -c "from services.rag import RAGService; print('✅ OK')"
```

**Checklist:**
- [ ] Python 3.12.3 instalado
- [ ] venv activo
- [ ] requirements.txt instalado
- [ ] Imports funcionan
- [ ] FastAPI responde

#### C. Verificar Flutter Environment

```bash

# En cada máquina developer (Frontend)

# Verificar Flutter version
flutter --version
# Expected: >= 3.16.0

# Verificar build tools
flutter doctor

# Resultado esperado:
# Flutter: ✅
# Dart: ✅
# Desktop: ✅
# Android/iOS: ✅
```

**Checklist:**
- [ ] Flutter >= 3.16.0
- [ ] Dart >= 3.2.0
- [ ] Desktop support habilitado
- [ ] `flutter doctor` todo verde
- [ ] Puede compilar proyecto

#### D. Verificar GitHub Access

```bash
# CADA developer en su máquina

# Test SSH key
ssh -T git@github.com

# Resultado esperado:
# "Hi [username]! You've successfully authenticated..."

# Test clone
cd /tmp
git clone git@github.com:[ORG]/soft-architect-ai.git
cd soft-architect-ai
git branch -a
```

**Checklist:**
- [ ] SSH key configured
- [ ] Can clone repository
- [ ] Can fetch all branches
- [ ] Can push to develop
- [ ] No permission errors

---

### 5️⃣ PLAN DE COMUNICACIÓN (Día 3)

**Product Manager + Tech Lead:**

#### A. Comunicado de Launch

Enviar email a toda la organización:

```
Subject: 🚀 [INICIANDO] Refactor Project-First - HU-3.x

Equipo,

Nos complace anunciar que comenzamos esta semana con el refactor
de arquitectura "Project-First" - una transformación mayor que
mejorará la experiencia del usuario al tiempo que moderniza
nuestro stack técnico.

📊 RÁPIDOS NÚMEROS:
• 5 nuevas User Stories (HU-3.1 a HU-3.5)
• 70 puntos de estimación
• 8 semanas de trabajo
• 3.5 FTE dedicado

🎯 OBJETIVO:
Cambiar de Chat-First (actual) a Project-First Sequential
Document Generation. Esto permite:
- Proyectos como entidades de primera clase (no ephemeral)
- Documentos validados y persistidos
- Workflow iterativo guiado por RAG 100% local

📅 FASES:
• Fase 0: Pre-Sprint (Esta semana)
• Fase 1: Foundation (Sem 1-2)
• Fase 2: Core Logic (Sem 3-5)
• Fase 3: Resilience (Sem 6)
• Fase 4: Testing & Release (Sem 7-8)

👥 TEAM:
Tech Lead: [Nombre]
Backend Lead: [Nombre]
Frontend Lead: [Nombre]
QA Engineer: [Nombre]
DevOps: [Nombre]

📚 DOCUMENTACIÓN:
Análisis completo disponible en:
→ doc/01-PROJECT_REPORT/README_HU-3_CENTRAL.es.md

💬 CONTACTO:
Preguntas? Escribe a #dev-arquitectura en Slack o
comenta en el PR Draft.

¡Adelante! 🚀

--
ArchitectZero (AI Lead) + Tech Lead
```

#### B. Canales de Comunicación

```
Canal                  Uso                    Frecuencia
──────────────────────────────────────────────────────
#dev-arquitectura      Discusiones técnicas   Daily sync
#announcements         Updates públicos       Weekly
#hu-3-refactor         Problemas HU-3         As needed
Stand-ups              Status update          Daily 15m
PR Reviews             Code review            Continuous
Slack DMs              1-on-1s                As needed
```

---

### 6️⃣ CREAR PR DRAFT (Día 3)

**Tech Lead abre PR:**

```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Asegurarse en rama feature/ui-project-shell
git branch
# * feature/ui-project-shell

# Verificar estado
git status
# working tree clean ✅

# Crear PR vía GitHub UI
# Title: "feat(hu-3): Project-First Sequential Document Generation - 8 Week Refactor"
# Branch: feature/ui-project-shell → develop
# Draft: YES (marcar como DRAFT)

# Descripción del PR:

Title:
feat(hu-3): Project-First Sequential Document Generation Refactor

Body:
## 📋 Resumen

Refactor arquitectónico major: Chat-First (actual) → Project-First Sequential.

- 5 nuevas HUs (3.1 a 3.5)
- 70 puntos de estimación
- 8 semanas de trabajo
- Documentación COMPLETA incluida

## 📄 Documentos Incluidos

- [x] HU-3_EXECUTIVE_SUMMARY.es.md
- [x] HU-3_REFACTOR_ANALYSIS.es.md
- [x] HU-3_SPECIFICATIONS.es.md
- [x] HU-3_IMPROVEMENT_PROPOSALS.es.md
- [x] HU-3_IMPLEMENTATION_PLAN.es.md
- [x] MASTER_IMPLEMENTATION_PLAN.es.md
- [x] README_HU-3_CENTRAL.es.md
- [x] INVENTORY_HU-3_DOCUMENTATION.es.md

## 🎯 Decisión Requerida

- [ ] ✅ Proceder (Tech Lead + PO aprueban)
- [ ] ❌ No proceder (razones TBD)
- [ ] 🤔 Modificar (cambios TBD)

## ⏳ Timeline (Si ✅)

Fase 0: Pre-Sprint (Esta semana)
Fase 1-4: 8 semanas (Comenzando 02/09)

## 🔗 Documentación

Lee: doc/01-PROJECT_REPORT/README_HU-3_CENTRAL.es.md

## 📞 Contacto

Preguntas? Comenta en el PR o escribe #dev-arquitectura

---

**DRAFT PR Checklist (antes de marcar ready):**
- [ ] Todas las aprobaciones recibidas
- [ ] Team roster completo
- [ ] Toolchain validado
- [ ] Comunicado enviado
- [ ] Feedback incorporado
- [ ] Estado → READY FOR REVIEW
```

---

### 7️⃣ INCORPORAR FEEDBACK (Día 3-4)

**Tech Lead + ArchitectZero:**

Si los stakeholders tienen feedback/preocupaciones:

1. **Documentoar feedback**
   ```
   Feedback Log:

   De: [Stakeholder]
   Fecha: [date]
   Preocupación: [Issue]
   Respuesta: [How we address]
   Decisión: [Accepted/Rejected]
   ```

2. **Crear issues en GitHub** (si son cambios)
   ```
   GitHub Issue Template:

   Title: [Change] - [Brief description]
   Label: hu-3-refactor / enhancement / risk-mitigation
   Priority: High / Medium / Low
   Milestone: Fase 0
   ```

3. **Actualizar documentoos** (si necesario)
   ```bash
   # Si feedback cambios specsed
   git add doc/01-PROJECT_REPORT/HU-3_*.es.md
   git commit -m "docs(hu-3): Incorporate Phase 0 feedback"
   ```

4. **Volver a comentar stakeholders**
   ```
   Email: "Phase 0 Feedback Incorporated"
   Content: Link a GitHub issues + cambios hechos
   Request: "Please re-confirm approval"
   ```

---

### 8️⃣ OBTENER APROBACIÓN FINAL (Día 4-5)

**Tech Lead + Product Owner:**

Cuando TODO esté listo (team + approvals + toolchain + feedback):

```
CHECKLIST FINAL FASE 0:

✅ Usuario confirmó decisión (✅ Proceder)
✅ 4/5 Stakeholders aprobaron
✅ Team roster asignado (5 personas)
✅ Capacitaciones programadas
✅ Docker stack validado (todos)
✅ Python environment listo (Backend)
✅ Flutter environment listo (Frontend)
✅ GitHub access verificado
✅ Comunicado enviado
✅ PR Draft creado
✅ Feedback incorporado
✅ Issues creados (si needed)

STATUS: ✅ FASE 0 COMPLETE

NEXT: Mark PR as READY FOR REVIEW
      Esperar últimas aprobaciones de Code Reviewers
      Merge a develop cuando TODO esté ready
```

---

## 📊 TIMELINE FASE 0

```
Lunes     02/02
├─ ✅ Usuario confirma decisión
├─ 📧 Enviar approval requests
└─ 🛠️ Verificar toolchain local

Martes    02/03
├─ 🤝 Reunión team kickoff
├─ 📚 Capacitación 1 (RAG Local)
└─ ✅ Aprobaciones llegando

Miércoles 02/04
├─ 📚 Capacitación 2-4 (Workflow, APIs, Flutter)
├─ 🔧 Setup completo de máquinas
└─ 📋 Roster final confirmado

Jueves    02/05
├─ 📚 Capacitación 5 (ChromaDB)
├─ 📞 Última ronda de feedback
└─ ✅ Aprobaciones finales

Viernes   02/06
├─ ✅ Verificación final Fase 0
├─ 📊 Status report enviado
└─ 🚀 LISTO PARA FASE 1

SIGUIENTE SEMANA: Fase 1 (Foundation)
```

---

## 🎯 DEFINICIÓN DE "DONE" - FASE 0

### Requisitos Funcionales
- [x] Documentoación HU-3 completada (8 docs)
- [x] Especificación técnica detallada
- [x] Plan maestro 8 semanas definido
- [x] Código de ejemplo escrito
- [x] Riesgos identificados + mitigaciones

### Requisitos de Gobierno
- [ ] Usuario confirmó decisión (✅ Proceder)
- [ ] 4/5 stakeholders aprobaron
- [ ] Team roster asignado
- [ ] Aprobaciones registradas (Confluence/GitHub)
- [ ] PR Draft abierto

### Requisitos Técnicos
- [ ] Docker stack funcionando (todos)
- [ ] Python 3.12 environment (Backend team)
- [ ] Flutter environment (Frontend team)
- [ ] GitHub SSH keys configuradas
- [ ] Documentoación sincronizada

### Requisitos de Comunicación
- [ ] Correo de anuncio enviado
- [ ] Canales Slack creados (#hu-3-refactor)
- [ ] Stand-ups programados
- [ ] Feedback log creado
- [ ] Issues de GitHub creados (si needed)

### Requisitos de Calidad
- [ ] Documentoación revisada (typos, links)
- [ ] Especificaciones validadas
- [ ] Code examples pruebaeados
- [ ] Diagrama ASCII renderizado
- [ ] Números (puntos, FTE, horas) verificados

**Cuando TODO esté ✅:**
→ Fase 0 = COMPLETE
→ Fase 1 puede comenzar

---

## 🚫 RIESGOS FASE 0

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|------------|--------|-----------|
| Feedback requiere cambios mayores | MEDIA | ALTO | Feedback loop en Día 2-3 |
| Un stakeholder no aprueba | BAJA | ALTO | Discussion + adjust plan |
| Toolchain issues (Docker, Python) | MEDIA | MEDIO | Tech Lead pre-validó |
| Team no disponible | BAJA | ALTO | Reservar calendarios anticipado |
| Cambios scope durante Fase 0 | MEDIA | ALTO | Documentoo congelado hasta Día 5 |

---

## 📚 REFERENCIAS

### Documentoos Fase 0
- HU-3_EXECUTIVE_SUMMARY.es.md (para stakeholders)
- MASTER_IMPLEMENTATION_PLAN.es.md (para team)
- HU-3_SPECIFICATIONS.es.md (para developers)

### Comandos Útiles

```bash
# Verify rama
git branch

# Check documentación
ls -lh doc/01-PROJECT_REPORT/HU-3_*.es.md

# Verify Python
python3 --version  # Should be 3.12.3

# Verify Flutter
flutter --version  # Should be >= 3.16.0

# Verify Docker
docker-compose --version
docker --version
```

---

## ✅ CONCLUSIÓN

**Fase 0** es enteramente preparatoria:

✅ Usuario decide
✅ Stakeholders aprueban
✅ Team se forma
✅ Toolchain se valida
✅ Comunicación se establece

**Resultadoado:** Equipo completamente alineado y listo para Fase 1

**Duración:** 3-5 días (02/02-02/06/2026)

**Próximo Paso:** Esperar confirmación del usuario, luego ejecutar esta checklist

---

**FASE 0 INICIACIÓN**
**Creado:** 02/02/2026
**Owner:** Tech Lead + PM
**Estado:** ⏳ AWAITING USER CONFIRMATION
