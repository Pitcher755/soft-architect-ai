# 🧪 TESTING QUICK START - Sistema Híbrido Corregido

**Objetivo:** Validar que projects REALES se muestran junto con MOCK project

---

## ✅ Test 1: Visualización Inicial
```
PASOS:
1. Ejecutar app: flutter run -d linux
2. Navegar a ProjectWorkspaceScreen

VERIFICAR:
✅ Loading spinner aparece (2-3 segundos)
✅ Spinner desaparece y muestra proyectos
✅ Se ve "Guía SoftArchitect" en grid (es el proyecto mock)
✅ Si existen carpetas en /projects o ~/SoftArchitect, aparecen aquí
```

---

## ✅ Test 2: Create Nuevo Project
```
PASOS:
1. En grid de proyectos, click "Nuevo Proyecto"
2. Rellena formulario:
   - Nombre: "Test Project 1"
   - Ruta: (dejar por defecto)
   - Descripción: "Proyecto de prueba"
3. Click "Crear Proyecto"

VERIFICAR:
✅ Diálogo se cierra
✅ Se navega a project-shell (proyecto abierto)
✅ VOLVER al workspace (botón atrás o navigation)
✅ "Test Project 1" aparece en el grid
✅ Guía SoftArchitect sigue visible
```

---

## ✅ Test 3: Button "Ver todos los projects"
```
PASOS:
1. Crear 8+ proyectos (repite Test 2 varias veces)
   - Test Project 1
   - Test Project 2
   - Test Project 3
   - ...
   - Test Project 8+

2. Vuelve a ProjectWorkspaceScreen

VERIFICAR:
✅ Grid muestra 8 primeros proyectos (incluyendo Guía)
✅ Botón "Ver todos los proyectos (9)" aparece abajo del grid
   (9 = 8 test projects + 1 guía)
✅ Click botón → abre ProjectListView expandible
✅ ProjectListView muestra TODOS los proyectos ordenados alfabéticamente
✅ Cada proyecto tiene:
   - Nombre
   - Ruta
   - Icono con color
   - Indicador de fase
```

---

## ✅ Test 4: Lista Expandida
```
PASOS:
1. Con botón "Ver todos" visible, click para expandir
2. Observa ProjectListView

VERIFICAR:
✅ Se abre overlay con bordes azul (primary)
✅ Muestra lista de todos los proyectos
✅ Ordenados alfabéticamente (A → Z)
✅ Cada proyecto muestra:
   - Icono carpeta (real) o libro (guía)
   - Nombre completo
   - Ruta (path)
   - Color de fase
✅ Botón cerrar (X) en esquina superior derecha
✅ Click X → cierra y vuelve a grid
✅ Click nombre proyecto → navega a ese proyecto
```

---

## ✅ Test 5: Hybrid Detection (Real vs Mock)
```
PASOS:
1. Crear proyecto: "Proyecto Real"
2. Abrir en project-shell
3. Observar árbol de archivos (file tree)

PARA PROYECTO REAL:
✅ Muestra estructura real del filesystem
✅ Carpetas y archivos reales
✅ Path comienza con "/" (absoluto)

PARA GUÍA (mock):
1. Click "Guía SoftArchitect" en grid
2. Observar árbol de archivos

VERIFICAR:
✅ Muestra estructura de guía (mock)
✅ Path comienza con "mock://"
✅ Contiene documentación de SoftArchitect
✅ Estructura predefinida (no del filesystem)
```

---

## ✅ Test 6: Persistencia
```
PASOS:
1. Crear "Proyecto A"
2. Cerrar app completamente
3. Reabrir app
4. Ir a ProjectWorkspaceScreen

VERIFICAR:
✅ "Proyecto A" sigue visible en grid
✅ No se perdió cuando cerró la app
✅ Guía SoftArchitect siempre presente
```

---

## 🔍 Debug Info

Si algo no funciona, revisar:

### 1. Loading spinner no aparece
```
Solución: El FutureBuilder debe estar activo
- Verificar _projectsFuture se inicializa en initState()
- Verificar getMockProjectsData() es Future (async)
```

### 2. Solo muestra Guía, no projects reales
```
Solución: _loadRealProjects() no encuentra proyectos
- Crear carpeta ~/projects/ o /Espacio-de-trabajo/projects/
- Poner una carpeta adentro: ~/projects/MyProject/
- Reiniciar app
```

### 3. Button "Ver todos" no aparece
```
Solución: Menos de 8 proyectos
- Crear más proyectos (necesita > 8)
- O reducir número en código: if (allProjects.length > 3)
```

### 4. ProjectListView no aparece
```
Solución: Problema de setState()
- Verificar que showAllProjects cambia
- Revisar que ProjectListView recibe allProjects correctamente
```

---

## 📊 Matriz de Validación

| Test | Paso | Esperado | Result |
|------|------|----------|-----------|
| 1 | Loading | Spinner | ✅ 🔲 |
| 1 | Datos | Guía visible | ✅ 🔲 |
| 2 | Create | Nueva folder | ✅ 🔲 |
| 2 | Dashboard | Project aparece | ✅ 🔲 |
| 3 | 8+ projects | Button visible | ✅ 🔲 |
| 3 | Expandir | Lista abierta | ✅ 🔲 |
| 4 | Ordenamiento | A-Z correcto | ✅ 🔲 |
| 5 | Real project | Files reales | ✅ 🔲 |
| 5 | Mock project | Guía visible | ✅ 🔲 |
| 6 | Persistencia | Project persiste | ✅ 🔲 |

---

## 🎯 Criterio de Aceptación

✅ **SISTEMA LISTO** si:
- [ ] Loading spinner aparece en inicio
- [ ] Project Guía SoftArchitect visible
- [ ] Nuevos projects creados aparecen en grid
- [ ] Button "Ver todos" aparece cuando > 8
- [ ] ProjectListView abre/cierra correctamente
- [ ] Projects ordenados alfabéticamente en lista
- [ ] Puedo navegar a project real y ver files
- [ ] Puedo navegar a Guía y ver documentación
- [ ] Projects persisten después de cerrar app
