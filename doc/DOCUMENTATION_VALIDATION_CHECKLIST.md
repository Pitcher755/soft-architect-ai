# 📋 Guía de Validación: Estructura de Documentación

> **Propósito:** Verificación rápida de que la documentación cumple con AGENTS.md §8  
> **Fecha:** 29 de enero de 2026  
> **Aplicable a:** Toda nueva documentación

---

## ✅ Checklist Rápido

Antes de agregar documentación nueva, verifica:

### 1. **¿Dónde va el archivo?**

```bash
# ¿Es un concepto/paper estratégico?
→ doc/00-VISION/

# ¿Es un reporte/análisis/resultado de pruebas?
→ doc/01-PROJECT_REPORT/

# ¿Es una guía técnica/setup/troubleshooting?
→ doc/02-SETUP_DEV/

# ¿Es seguimiento de historia de usuario?
→ doc/03-HU-TRACKING/HU-{ID}-{NAME}/

# ¿Es documentación interna/confidencial?
→ doc/private/

# ¿Es README o AGENTS (identidad)?
→ Raíz solo (no en doc/)
```

### 2. **¿Cómo lo nombro?**

- ✅ UPPERCASE_SNAKE_CASE
- ✅ Sufijo bilingual si aplica: `.es.md` y `.en.md`
- ✅ Nunca: `guia.md`, `Tutorial_1.md`, `my_doc.md`
- ✅ Ejemplos correctos:
  - `DOCKER_COMPOSE_GUIDE.es.md`
  - `FUNCTIONAL_TEST_REPORT.md`
  - `QUICK_START_GUIDE.en.md`

### 3. **¿Qué estructura debe tener?**

```markdown
# 📚 Título del Documento

> **Fecha:** DD/MM/YYYY  
> **Estado:** ✅/⚠️/❌  
> **Versión:** X.Y.Z (opcional)

---

## 📖 Tabla de Contenidos

1. [Sección A](#sección-a)
2. [Sección B](#sección-b)
...

---

## Sección A

Contenido...

---

## Sección B

Contenido...

---

## Referencias

- Link a [otro documento](./OTRO_DOCUMENTO.md)
- Link a [AGENTS.md](../../AGENTS.md)
```

### 4. **¿Bilingual o no?**

- ✅ **Bilingual (ES + EN):**
  - Conceptos (00-VISION)
  - Guías de desarrollo (02-SETUP_DEV)
  - Setup/instalación (02-SETUP_DEV)
  
- ⚠️ **Solo un idioma:**
  - Reportes técnicos (01-PROJECT_REPORT)
  - Logs de sesión (01-PROJECT_REPORT)
  - Documentación interna (private/)

### 5. **¿Está en la categoría correcta?**

```bash
# Validación rápida:
$ find doc -type f -name "*.md" | sort | head -20

# Verifica que:
# ✅ 00-VISION/ tiene conceptos
# ✅ 01-PROJECT_REPORT/ tiene reportes
# ✅ 02-SETUP_DEV/ tiene guías
# ✅ 03-HU-TRACKING/ tiene HU-tracking
# ✅ private/ existe para internos
```

---

## 🔍 Verificación de Compliance

Después de crear nuevo archivo, ejecuta:

```bash
cd /path/to/soft-architect-ai

# 1. Verificar que no hay .md sueltos en raíz (excepto permitidos)
$ ls -1 *.md | grep -v "README\|AGENTS"
# Resultado esperado: (vacío)

# 2. Contar archivos en doc/
$ find doc -name "*.md" | wc -l
# Resultado esperado: >34

# 3. Validar estructura
$ tree doc/ -L 2
# Resultado esperado: estructura clara por categoría

# 4. Validar que nuevo archivo existe
$ ls doc/CATEGORIA/NUEVO_ARCHIVO.md
# Resultado esperado: (existe)

# 5. Verificar que links internos son relativos
$ grep "](/" doc/NUEVA_CATEGORIA/NUEVO_ARCHIVO.md
# Resultado esperado: (ninguno - solo rutas relativas)
```

---

## 📚 Ejemplos de Archivo Bien Clasificado

### ✅ CORRECTO: Reporte en 01-PROJECT_REPORT/

```
doc/01-PROJECT_REPORT/DOCKER_COMPOSE_AUDIT.md

Contenido: Análisis/auditoría de docker-compose.yml
Categoría: Reporte de análisis técnico
Bilingual: No (solo inglés/español)
Ubicación: ✅ CORRECTA
```

### ✅ CORRECTO: Guía en 02-SETUP_DEV/

```
doc/02-SETUP_DEV/QUICK_START_GUIDE.es.md
doc/02-SETUP_DEV/QUICK_START_GUIDE.en.md

Contenido: Guía de inicio rápido para developers
Categoría: Guía técnica
Bilingual: Sí (ES + EN)
Ubicación: ✅ CORRECTA
```

### ✅ CORRECTO: Concepto en 00-VISION/

```
doc/00-VISION/CONCEPT_WHITE_PAPER.es.md
doc/00-VISION/CONCEPT_WHITE_PAPER.en.md

Contenido: Paper estratégico de visión
Categoría: Concepto/Vision
Bilingual: Sí (ES + EN)
Ubicación: ✅ CORRECTA
```

### ✅ CORRECTO: HU-tracking en 03-HU-TRACKING/

```
doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/README.md
doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/PROGRESS.md
doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/ARTIFACTS.md

Contenido: Seguimiento de Historia de Usuario
Categoría: HU-tracking
Estructura: Dedicada por HU
Ubicación: ✅ CORRECTA
```

### ❌ INCORRECTO: Archivo en raíz

```
soft-architect-ai/NUEVA_GUIA.md

Problema: ❌ Archivo .md suelto en raíz
Solución: Mover a doc/02-SETUP_DEV/NUEVA_GUIA.md
```

### ❌ INCORRECTO: Nomenclatura

```
doc/01-PROJECT_REPORT/docker_audit.md  ❌

Problema: ❌ Minúsculas, sin separación clara
Solución: Renombrar a DOCKER_COMPOSE_AUDIT.md
```

### ❌ INCORRECTO: Mezcla de idiomas

```
doc/01-PROJECT_REPORT/REPORT.md

Contenido mezcla:
"Esta es una auditoría técnica. This audit examines..."

Problema: ❌ Idiomas mezclados
Solución: Crear dos archivos:
  - REPORT.es.md (español)
  - REPORT.en.md (inglés)
```

---

## 🚀 Workflow: Crear Nuevo Documento

### PASO 1: Decidir Categoría
```
¿Tipo de documento?
├─ Concepto estratégico → 00-VISION/
├─ Reporte/análisis → 01-PROJECT_REPORT/
├─ Guía técnica → 02-SETUP_DEV/
├─ Seguimiento HU → 03-HU-TRACKING/
└─ Documentación interna → private/
```

### PASO 2: Nombrar Archivo
```
Formato: UPPERCASE_SNAKE_CASE[.{es,en}].md

Ejemplos:
✅ DEPLOYMENT_GUIDE.es.md
✅ API_REFERENCE.md
✅ TESTING_STRATEGY.en.md
```

### PASO 3: Crear Estructura Base
```markdown
# 📚 [Título]

> **Fecha:** [DD/MM/YYYY]  
> **Estado:** ✅/⚠️/❌

---

## 📖 Tabla de Contenidos

...
```

### PASO 4: Validar Compliance
```bash
# Checklist:
[ ] Archivo ubicado en doc/CATEGORIA/
[ ] Nombrado en UPPERCASE_SNAKE_CASE
[ ] Tiene metadata (Fecha, Estado)
[ ] Tiene tabla de contenidos
[ ] Links son relativos (no /)
[ ] Bilingual si aplica
```

### PASO 5: Git Commit
```bash
git add doc/CATEGORIA/NUEVO_ARCHIVO.md
git commit -m "📚 Agregar NUEVO_ARCHIVO en CATEGORIA"
```

---

## 🔗 Referencias Rápidas

| Referencia | Link |
|---|---|
| **AGENTS.md §8** | [../../AGENTS.md#-8-estándar-de-documentación-doc-as-code](../../AGENTS.md#-8-estándar-de-documentación-doc-as-code) |
| **Índice Principal** | [../INDEX.md](../INDEX.md) |
| **HU Tracking** | [../03-HU-TRACKING/README.md](../03-HU-TRACKING/README.md) |
| **Reorganización** | [../03-HU-TRACKING/DOCUMENTATION_REORGANIZATION_LOG.md](../03-HU-TRACKING/DOCUMENTATION_REORGANIZATION_LOG.md) |

---

## 📞 Soporte

### Si tienes dudas sobre categoría:
→ Consulta [AGENTS.md §8.4](../../AGENTS.md#4-organización-por-categoría)

### Si tienes dudas sobre nombrado:
→ Consulta [AGENTS.md §8.2](../../AGENTS.md#2-nombrado)

### Si tienes dudas sobre estructura:
→ Consulta ejemplos en [doc/](.)

### Si encontraste un archivo mal clasificado:
→ Úsalo como anti-patrón y reubícalo correctamente

---

**Última actualización:** 29 de enero de 2026  
**Creado por:** ArchitectZero
