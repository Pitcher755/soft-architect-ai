# 📋 Estrategia de Reorganización de Documentación

> **Fecha:** 19/02/2026
> **Estado:** ✅ EN EJECUCIÓN
> **Objetivo:** Crear estructura bilingüe (Español/English) con documentación accesible y clasificada

---

## 🎯 Visión Final

```
doc/
├── Español/                    # 🇪🇸 Documentación en Español
│   ├── 00-VISION/
│   ├── 01-PROJECT_REPORT/
│   ├── 02-SETUP_DEV/
│   ├── 03-HU-TRACKING/
│   ├── 04-USER_GUIDE/          # ✨ NEW
│   └── private/
│
├── English/                    # 🇬🇧 Documentación en Inglés
│   ├── 00-VISION/
│   ├── 01-PROJECT_REPORT/
│   ├── 02-SETUP_DEV/
│   ├── 03-HU-TRACKING/
│   ├── 04-USER_GUIDE/          # ✨ NEW
│   └── private/
│
├── INDEX.md                    # 🎨 Portal Bilingüe (NEW)
├── README.md                   # 📖 Bienvenida (NEW)
└── [Archivos heredados - a migrar]
```

---

## 📊 Clasificación de Documentos Existentes

### Documentos Detectados: 411 archivos

#### **Categorías por Tipo:**

| Tipo | Cantidad | Ejemplos |
|------|----------|----------|
| **Reportes de Fase/Sprint** | ~80 | PHASE_4_COMPLETION, SPRINT3_COMPLETION, RAG_CORE_CONFIG_SPRINT |
| **Reportes de Testing** | ~60 | TEST_COVERAGE_*, TESTING_*, E2E_TESTS |
| **Reportes de Implementación** | ~50 | IMPLEMENTATION_*, FIXES_*, CI_CD_* |
| **Documentación de HU** | ~120 | HU-*/README.md, HU-*/PROGRESS.md, HU-*/ARTIFACTS.md |
| **Documentación Técnica** | ~50 | SETUP_*, DOCKER_*, REQUIREMENTS | **Reportes de Análisis** | ~30 | ANAYLSIS_*, COVERAGE_*, COMPARISON |
| **Documentación de Visión** | ~20 | CONCEPT_WHITE_PAPER, MANIFESTO, PROJECT_MANIFESTO |

#### **Clasificación por Idioma:**

| Idioma | Archivos | Extensión |
|--------|----------|-----------|
| **Español** | ~150 | `.es.md` o nombres españoles |
| **Inglés** | ~180 | `.en.md` o nombres en inglés |
| **Neutro** | ~81 | Sin sufijo (técnicos, reportes sin traducción) |

---

## 🗂️ Plan de Migración

### FASE 1: Documentación de Visión (00-VISION)

**Archivos a migrar:**
- ✅ CONCEPT_WHITE_PAPER.es.md → Español/00-VISION/
- ✅ CONCEPT_WHITE_PAPER.en.md → English/00-VISION/
- ✅ WHAT_WE_ARE_BUILDING.es.md → Español/00-VISION/
- ✅ WHAT_WE_ARE_BUILDING.en.md → English/00-VISION/ (CREAR)

### FASE 2: Documentación de Configuración (02-SETUP_DEV)

**Archivos a migrar:**
- Todos los SETUP_*, DOCKER_*, QUICK_START_*, TOOLS_*

---

## 🔄 Estrategia de Dublicación

Para documentos que existan en un idioma pero no en otro:

1. **Si existe .es.md pero NO .en.md:**
   - Usar traducción automática + revisión manual
   - Marcar como `[TRANSLATED]` en header

2. **Si existe .en.md pero NO .es.md:**
   - Crear versión bilingüe (ambas lenguas en el INDEX de referencia)
   - Link al documento original en ambas secciones

3. **Si es documento técnico (no tiene idioma):**
   - Clasificar como "Técnica compartida"
   - Link desde ambas secciones

---

## ✨ Documentación Nueva Requerida

### 04-USER_GUIDE (Nueva)

#### Estructura:
```
04-USER_GUIDE/
├── 01-QUICK_START.md       # Primeros 15 minutos
├── 02-INSTALLATION.md      # Instalación (Windows/Mac/Linux)
├── 03-FIRST_PROJECT.md     # Crear primer proyecto
├── 04-MASTER_WORKFLOW.md   # Las 4 fases del Master Workflow
├── 05-CHAT_INTERFACE.md    # Cómo usar el chat
├── 06-STREAMING.md         # Streaming en tiempo real
├── 07-PERSISTENCE.md       # Guardado de trabajos
├── 08-TROUBLESHOOTING.md   # Resolución de problemas
├── 09-FAQ.md               # Preguntas frecuentes
└── 10-VIDEO_TUTORIALS.md   # Referencias a videos (si aplica)
```

---

## 📄 Documentos Maestros a Crear

### 1. INDEX.md (Raíz de doc/)
- Portal de navegación bilingüe
- 2 secciones: Español | English
- Links a todas las secciones

### 2. README.md (Raíz de doc/)
- Bienvenida
- Instrucciones rápidas de navegación
- Selector de idioma

### 3. Español/00-VISION/README.md
- Índice de documentos de visión
- Links a todos los documentos de estrategia

### 4. English/00-VISION/README.md
- Ídem pero en inglés

---

## 📋 Checklist de Ejecución

- [ ] Crear directorios espejo (✅ HECHO)
- [ ] Crear directorios de HU (✅ HECHO)
- [ ] Copiar documentos de 00-VISION
- [ ] Copiar documentos de 01-PROJECT_REPORT
- [ ] Copiar documentos de 02-SETUP_DEV
- [ ] Migrar documentación de HU
- [ ] Crear documentación de USER_GUIDE
- [ ] Crear INDEX.md principal
- [ ] Crear README.md principal
- [ ] Validar que los textos en español están correctos
- [ ] Validar que los textos en inglés están correctos
- [ ] Crear navegación cruzada (links entre idiomas)

---

## 🚀 Beneficios Esperados

✅ **Accesibilidad:** Usuarios encuentran info en su idioma
✅ **Organización:** Documentación clasificada por tipo y HU
✅ **Escalabilidad:** Fácil añadir nuevos documentos
✅ **Mantenibilidad:** Estructura clara y predecible
✅ **Profesionalismo:** Aspecto de producto maduro

---

**Próximo paso:** Comenzar migración de documentos (FASE 1)
