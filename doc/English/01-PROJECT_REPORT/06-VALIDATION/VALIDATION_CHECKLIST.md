# ✅ CHECKLIST DE VALIDACIÓN POST-CORRECCIÓN

**Propósito:** Validar que la corrección funciona antes de producción
**Fecha:** 9 de febrero de 2026

---

## 🔍 PASO 1: Verification de Compilación

```
COMANDO: cd src/client && flutter clean && flutter pub get
├─ [ ] Sin errores de pub get
├─ [ ] Sin warnings críticos
└─ [ ] Archivos generados correctamente

COMANDO: flutter analyze
├─ [ ] 0 análisis errores
├─ [ ] 0 problemas críticos
└─ [ ] Warnings menores OK

COMANDO: flutter build linux --debug
├─ [ ] Build exitoso
├─ [ ] Binary generado
└─ [ ] Sin errores de linker
```

**✅ Status:** _______

---

## 🚀 PASO 2: Ejecución Básica

```
COMANDO: flutter run -d linux
├─ [ ] App inicia sin crash
├─ [ ] Navega a ProjectWorkspaceScreen
├─ [ ] Spinner loading aparece (1-3 segundos)
├─ [ ] Spinner desaparece
├─ [ ] Grid con proyectos se renderiza
└─ [ ] Sin excepciones en console

DEBUG CONSOLE - Buscar mensajes:
├─ [ ] "✅ Loaded X real projects" (si existen)
├─ [ ] "✅ Loaded 1 real projects" (proyecto mock)
└─ [ ] Sin "❌ Error loading" mensajes críticos
```

**✅ Status:** _______

---

## 🎨 PASO 3: Visualización de UI

```
VERIFICAR EN PANTALLA:

Grid Layout:
├─ [ ] Título "🎯 SoftArchitect AI Workspace"
├─ [ ] Subtítulo "Interactive workspace..."
├─ [ ] Sección "Mis Proyectos"
├─ [ ] Botón "[+ Nuevo Proyecto]" visible
├─ [ ] Grid muestra tarjetas de proyectos
└─ [ ] Cada tarjeta tiene:
    ├─ [ ] Icono (📕 Guía o 📁 Real)
    ├─ [ ] Nombre proyecto
    ├─ [ ] Barra de fase con color
    └─ [ ] Información de fecha

Proyecto Mock (Guía):
├─ [ ] Nombre: "Guía SoftArchitect"
├─ [ ] Icono: 📕 (menu_book_rounded)
├─ [ ] Fase: "Documentación" (azul)
├─ [ ] Path: "mock://softarchitect-guide"
└─ [ ] Clickeable (navega a proyecto-shell)

Botón "Ver todos":
├─ [ ] Si 1-8 proyectos: OCULTO ✓
├─ [ ] Si > 8 proyectos: VISIBLE
│   ├─ [ ] Texto: "Ver todos los proyectos (N)"
│   ├─ [ ] Icono expandir (↓)
│   └─ [ ] Al hacer click:
│       ├─ [ ] Ícono cambia a contraer (↑)
│       ├─ [ ] Texto cambia a "Ocultar proyectos"
│       └─ [ ] ProjectListView aparece abajo
└─ [ ] Si click nuevamente:
    ├─ [ ] ProjectListView se cierra
    ├─ [ ] Icono vuelve a expandir (↓)
    └─ [ ] Texto vuelve a "Ver todos..."
```

**✅ Status:** _______

---

## 📋 PASO 4: Test de Projects Reales

### 4A: Create Folder de Test

```
TERMINAL:
$ mkdir -p ~/projects/Test-Project-1
$ mkdir -p ~/projects/Test-Project-2

RESULTADO EN APP:
├─ [ ] Vuelvo a ProjectWorkspaceScreen
├─ [ ] Spinner carga (2-3 seg)
├─ [ ] Aparecen ambos proyectos en grid
├─ [ ] "Test-Project-1" visible
├─ [ ] "Test-Project-2" visible
└─ [ ] "Guía SoftArchitect" también visible

VERIFICAR:
├─ [ ] Proyectos tienen icono 📁 (folder_open)
├─ [ ] Fase: "Contexto" (amarillo/naranja)
├─ [ ] Path correcto: /home/user/projects/Test-Project-X
└─ [ ] Proyecto mock sigue visible
```

**✅ Status:** _______

### 4B: Create Más Projects (>8)

```
TERMINAL:
$ cd ~/projects
$ for i in {3..10}; do mkdir -p Test-Project-$i; done

RESULTADO:
├─ [ ] Total: 10 proyectos + 1 guía = 11
├─ [ ] Grid muestra 8 primeros
│   ├─ [ ] Test-Project-1 a Test-Project-8
│   └─ [ ] Guía SoftArchitect
├─ [ ] Botón "Ver todos los proyectos (11)" APARECE
└─ [ ] Remaining (Test-Project-9, Test-Project-10) ocultos

CLICK BOTÓN:
├─ [ ] ProjectListView se abre
├─ [ ] Lista muestra TODOS 11 proyectos
├─ [ ] Ordenados alfabéticamente (A-Z)
│   ├─ [ ] Guía SoftArchitect primero (alfabéticamente)
│   └─ [ ] Test-Project-1 a Test-Project-10 en orden
├─ [ ] Cada proyecto tiene:
│   ├─ [ ] Icono y nombre
│   ├─ [ ] Path mostrado
│   ├─ [ ] Color de fase
│   └─ [ ] Es clickeable
└─ [ ] Botón cerrar (X) funciona
    ├─ [ ] Click X → cierra lista
    ├─ [ ] Vuelve a grid
    └─ [ ] Botón texto vuelve a "Ver todos"
```

**✅ Status:** _______

---

## 💾 PASO 5: Test de CreateProjectDialog

```
PASOS EN APP:
1. Click [+ Nuevo Proyecto]
   ├─ [ ] Diálogo abre
   ├─ [ ] Titulo: "Nuevo Proyecto"
   └─ [ ] Campos visibles: Nombre, Ruta, Descripción

2. Rellena formulario:
   - Nombre: "Mi App Importante"
   - Ruta: (dejar por defecto)
   - Descripción: "Test de crear proyecto"
   ├─ [ ] Campos aceptan input
   └─ [ ] Validación pasa

3. Click "Crear Proyecto"
   ├─ [ ] Diálogo se cierra
   ├─ [ ] Navega a project-shell
   └─ [ ] Se crea carpeta en filesystem

4. Vuelvo a dashboard (botón atrás):
   ├─ [ ] "Mi App Importante" APARECE en grid ✅
   ├─ [ ] Spinner cargó nuevamente
   ├─ [ ] No es el primero (nuevo proyecto)
   ├─ [ ] Tiene icono 📁 (es real, no mock)
   ├─ [ ] Tiene fase "Contexto" (amarillo)
   ├─ [ ] Path: /ruta/donde/lo/creé/Mi App Importante
   ├─ [ ] Proyecto mock sigue visible
   └─ [ ] Total de proyectos aumentó

VERIFICACIÓN FILESYSTEM:
$ ls -la ~/projects/  # o donde lo creaste
├─ [ ] Carpeta "Mi App Importante" existe
├─ [ ] Tiene contenido (estructura proyecto)
└─ [ ] Permisos correctos (rwx)
```

**✅ Status:** _______

---

## 🔀 PASO 6: Test de Hybrid System

### 6A: Navegar a Project Real

```
EN GRID:
1. Click proyecto "Test-Project-1" (real)
   ├─ [ ] Navega a project-shell
   ├─ [ ] Carga árbol de archivos
   ├─ [ ] Muestra estructura real del filesystem
   ├─ [ ] Path en URL: /home/user/projects/Test-Project-1
   └─ [ ] Contenido: archivos reales (si existen)

2. Click en un archivo real:
   ├─ [ ] Se puede leer contenido
   ├─ [ ] Viewer muestra texto
   └─ [ ] Sin errores
```

**✅ Status:** _______

### 6B: Navegar a Guía (Mock)

```
EN GRID:
1. Click proyecto "Guía SoftArchitect" (mock)
   ├─ [ ] Navega a project-shell
   ├─ [ ] Carga árbol de archivos mock
   ├─ [ ] Muestra estructura predefinida (Guía)
   ├─ [ ] Path en URL: mock://softarchitect-guide
   └─ [ ] Contenido: documentación de SoftArchitect

2. Click en archivo mock:
   ├─ [ ] Se abre contenido de la guía
   ├─ [ ] Muestra markdown/documentación
   ├─ [ ] Sin errores de "archivo no encontrado"
   └─ [ ] Funciona como proyecto normal
```

**✅ Status:** _______

---

## ⚡ PASO 7: Test de Performance

```
MEDICIONES:

Loading Time:
├─ [ ] Spinner aparece < 500ms
├─ [ ] Spinner desaparece en 2-3 segundos
├─ [ ] Datos cargan sin congelarse
└─ [ ] Transición smooth

Grid Rendering:
├─ [ ] 8 tarjetas se renderiza < 1s
├─ [ ] Scroll smooth sin jank
├─ [ ] Hover effects funcionan
└─ [ ] Sin lag visual

Expandir Lista:
├─ [ ] ProjectListView abre < 300ms
├─ [ ] Scroll en lista smooth
├─ [ ] 11+ proyectos sin slowdown
└─ [ ] Cerrar lista < 300ms
```

**✅ Status:** _______

---

## 🛡️ PASO 8: Test de Error Handling

### 8A: Simular Folder sin Permisos

```
TERMINAL:
$ mkdir -p ~/projects/No-Permission
$ chmod 000 ~/projects/No-Permission

EN APP:
1. Reiniciar app
2. Observar loading
   ├─ [ ] Spinner sigue cargando
   ├─ [ ] App no crash
   ├─ [ ] Otros proyectos siguen visibles
   ├─ [ ] Debug: "⚠️ Error loading projects..." aparece
   └─ [ ] App resiliente a errores
```

**✅ Status:** _______

### 8B: Folder vacía

```
TERMINAL:
$ mkdir -p ~/projects/Empty-Folder

EN APP:
1. Reiniciar
   ├─ [ ] Spinner carga normalmente
   ├─ [ ] No hay errores
   ├─ [ ] Empty-Folder NO aparece (es vacía, no cuenta)
   └─ [ ] Otros proyectos sí aparecen
```

**✅ Status:** _______

---

## 🔄 PASO 9: Test de Persistencia

```
PASOS:
1. Crear proyecto: "Persistencia Test"
2. Cerrar app COMPLETAMENTE
   ├─ [ ] Cierro terminal o proceso
   ├─ [ ] App no en background
   └─ [ ] Recursos liberados

3. Reabrir app:
   $ flutter run -d linux

4. Verificar:
   ├─ [ ] Spinner carga nuevamente
   ├─ [ ] "Persistencia Test" SIGUE visible en grid
   ├─ [ ] No se perdió el proyecto
   ├─ [ ] Guía SoftArchitect también visible
   ├─ [ ] Contador de proyectos correcto
   └─ [ ] Estado se preservó
```

**✅ Status:** _______

---

## 📊 PASO 10: Validación Final

### Checklist Integral

```
COMPILACIÓN:
├─ [ ] 0 errores Dart
├─ [ ] 0 warnings críticos
└─ [ ] Build exitoso

FUNCIONALIDAD:
├─ [ ] Loading spinner visible
├─ [ ] Proyectos reales cargan
├─ [ ] Proyecto mock siempre presente
├─ [ ] CreateProjectDialog funciona
├─ [ ] Botón "Ver todos" (>8)
├─ [ ] ProjectListView expandible
├─ [ ] Navegación a proyectos
├─ [ ] Hybrid system (real vs mock)
└─ [ ] Persistencia

UX:
├─ [ ] UI limpia y responsive
├─ [ ] Estados visuales claros
├─ [ ] Errores visibles (no crash)
├─ [ ] Transiciones smooth
└─ [ ] Feedback del usuario

ROBUSTEZ:
├─ [ ] Maneja carpetas sin permisos
├─ [ ] Maneja carpetas vacías
├─ [ ] Maneja N proyectos
├─ [ ] No hay memory leaks
└─ [ ] Performance aceptable

DOCUMENTACIÓN:
├─ [ ] README generado
├─ [ ] Testing guide disponible
├─ [ ] Search paths documentadas
└─ [ ] Before/after comparison
```

---

## ✅ RESULTADO FINAL

```
Total Items:  _____ / _____
Porcentaje:   _____%

STATUS:
├─ [ ] ✅ TODOS LOS TESTS PASAN → LISTO PRODUCCIÓN
├─ [ ] ⚠️  ALGUNOS TESTS FALLAN → REVISAR
└─ [ ] ❌ VARIOS TESTS FALLAN → NO LISTO
```

---

## 📝 Notas

```
Bugs encontrados durante testing:
_________________________________________________________________
_________________________________________________________________

Mejoras sugeridas:
_________________________________________________________________
_________________________________________________________________

Status Final:  [ ] LISTO PRODUCCIÓN  [ ] NECESITA FIXES
```

---

## 🎯 Firma de Validación

```
Validado por:  _________________
Fecha:         _________________
Hora:          _________________

Observaciones:
_________________________________________________________________
_________________________________________________________________
```
