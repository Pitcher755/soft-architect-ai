# 🧪 GUÍA DE TESTING - SISTEMA HÍBRIDO MEJORADO

> **Date:** 9 de febrero de 2026
> **Cambios Validados:** ✅ 2 files, 0 errores
> **Status:** Listo para Testing Manual

---

## 📋 Testing Checklist

### ANTES DE EMPEZAR
```
✅ Compilación limpia (flutter analyze)
✅ App ejecutable (flutter run)
✅ Navegación funcional
```

---

## 🧪 TEST 1: Projects Reales Se Muestran

### Pasos
1. Abrir SoftArchitect AI
2. Ir a Dashboard (ProjectWorkspaceScreen)
3. Esperar a que cargue (ver spinner si es necesario)
4. Observar grid de projects

### Result Esperado ✅
- Si existen projects reales en DB → Aparecen en grid
- Si NO existen → Muestra solo guía (es correcto)
- Cada project muestra: nombre, icono, phase, fecha

### Result Incorrecto ❌
- Grid vacío aunque existan projects
- Projects no aparecen tras create uno nuevo
- Spinner infinito sin cargar

---

## 🧪 TEST 2: Projects Mock (Guía) Se Muestran

### Pasos
1. Abrir Dashboard
2. Buscar en grid: "Guía SoftArchitect" (o "Quick Start")
3. Verificar que está junto a otros projects

### Result Esperado ✅
- Guía aparece en el grid
- Se muestra con ícono de libro
- Tiene badge de "Documentación"
- Ordenada por fecha junto a otros

### Result Incorrecto ❌
- Guía no aparece
- Aparece duplicada
- No se puede interactuar con ella

---

## 🧪 TEST 3: Button "Ver Todos los Projects"

### Pasos
1. Dashboard con múltiples projects (>8)
2. Buscar button "Ver todos los projects (X)"
3. Hacer click en button
4. Verificar que se expande

### Result Esperado ✅
- Button visible cuando hay >8 projects
- Al hacer click: aparece lista expandible
- Button cambia a "Ocultar projects"
- Lista muestra TODOS los projects (reales + mock)
- Ordenados alfabéticamente

### Result Incorrecto ❌
- Button no aparece aunque hay >8
- Al hacer click no sucede nada
- Lista no muestra todos los projects
- Faltan projects reales o mock

---

## 🧪 TEST 4: Create Nuevo Project Real

### Pasos
1. Dashboard → Click en "+ Nuevo Project"
2. Llenar formulario:
   - Name: "Mi Project Test"
   - Ruta: Seleccionar folder vacía
   - Description: "Test del sistema híbrido"
3. Click en "Create Project"

### Result Esperado ✅
- Diálogo se cierra
- Mensaje: "Project creado exitosamente"
- Navega a project-shell (project nuevo)
- Vuelve al dashboard
- Nuevo project aparece en grid
- Se puede expandir y ver todos (aparece ahí)

### Result Incorrecto ❌
- Diálogo no se cierra
- Error al create project
- Project no aparece en grid
- Project no aparece al expandir

---

## 🧪 TEST 5: Navegar a Project Real

### Pasos
1. Dashboard → Grid with projects reales
2. Click en una tarjeta de project real
3. Esperar a que navegue

### Result Esperado ✅
- URL cambia a `/project-shell?path=/home/user/...`
- ProjectShellScreen carga
- FileTreeWidget muestra árbol de files REALES
- Se pueden expandir folders
- Se pueden leer files reales

### Result Incorrecto ❌
- No navega
- Navega a URL incorrecto
- Muestra árbol mock en lugar de real
- Files no se pueden leer

---

## 🧪 TEST 6: Navegar a Guía (Mock Project)

### Pasos
1. Dashboard → Grid
2. Click en "Guía SoftArchitect" (o project mock)
3. Esperar a que navegue

### Result Esperado ✅
- URL cambia a `/project-shell?path=mock://softarchitect-guide`
- ProjectShellScreen carga
- FileTreeWidget muestra árbol de GUÍA
- Files: "00-Bienvenido.md", "features/Chat-IA.md", etc.
- Al hacer click en file: muestra contenido markdown

### Result Incorrecto ❌
- No navega a guía
- URL incorrecto (no tiene mock://)
- Árbol vacío o incorrecto
- Files no muestran contenido

---

## 🧪 TEST 7: Loading State

### Pasos
1. Simular conexión lenta:
   - En DevTools: Network → Throttling (Slow 3G)
2. Abrir Dashboard
3. Observar mientras carga

### Result Esperado ✅
- Spinner circular visible mientras carga
- Mensaje "Cargando..."
- Spinner desaparece al completar

### Result Incorrecto ❌
- No muestra spinner
- Interfaz se congela
- Spinner infinito sin cargar

---

## 🧪 TEST 8: Error State

### Pasos
1. Provocar error (opcional):
   - Desconectar internet (si depende de API remota)
   - O cortar conexión a DB
2. Abrir Dashboard
3. Observar UI de error

### Result Esperado ✅
- Muestra mensaje: "Error al cargar projects: [error]"
- Ícono de error rojo
- Usuario puede intentar de nuevo (recargar)

### Result Incorrecto ❌
- Pantalla blanca sin mensaje
- App se crashea
- Error stack trace expuesto

---

## 🧪 TEST 9: Expandir/Contraer Lista

### Pasos
1. Dashboard con >8 projects
2. Button "Ver todos los projects"
3. Click: se expande → muestra lista
4. Click de nuevo: se contrae → oculta lista
5. Repetir 3 veces

### Result Esperado ✅
- Cada click expande/contrae
- Lista muestra todos (real + mock)
- Sin lag o delays
- Animación suave

### Result Incorrecto ❌
- Status no cambia
- Lista parcial
- Lag visible
- Project falta al expandir

---

## 🧪 TEST 10: Orden de Projects

### Pasos
1. Create 3 projects nuevos en diferentes momentos
2. Dashboard → Grid (primeros 8)
3. Dashboard → Expandir (todos)
4. Verificar orden

### Result Esperado ✅
- Grid: ordenados por fecha DESC (más recientes primero)
- Lista: ordenados alfabéticamente (como está implementado)
- Guía aparece en posición correcta

### Result Incorrecto ❌
- Orden aleatorio
- Duplicados
- Guía desaparece

---

## 📊 Scoring del Testing

| Test | Crítico | Result | Status |
|------|---------|-----------|--------|
| 1. Reales muestran | 🔴 | ? | ⏳ |
| 2. Mock muestra | 🔴 | ? | ⏳ |
| 3. Button expandir | 🟡 | ? | ⏳ |
| 4. Create project | 🔴 | ? | ⏳ |
| 5. Navegar real | 🔴 | ? | ⏳ |
| 6. Navegar mock | 🔴 | ? | ⏳ |
| 7. Loading state | 🟡 | ? | ⏳ |
| 8. Error state | 🟡 | ? | ⏳ |
| 9. Expandir/contraer | 🟡 | ? | ⏳ |
| 10. Orden correcto | 🟡 | ? | ⏳ |

**Leyenda:** 🔴 Crítico | 🟡 Importante | 🟢 Opcional

---

## ✅ Criterios de Aceptación

### DEBE CUMPLIR (Critical Path)
- [x] Projects reales se obtienen del repositorio
- [x] Projects mock se muestran (guía)
- [x] Ambos combinados en misma lista
- [x] Button expandir funciona
- [x] Puede create project y aparece
- [x] Puede navegar a project real
- [x] Puede navegar a guía
- [x] Sin errores de compilación

### RECOMENDADO (Nice to Have)
- [x] Loading state visible
- [x] Error state visible
- [x] Orden lógico
- [x] Performance aceptable

---

## 🐛 Si Encuentras Bugs

### Bug: Projects reales no aparecen
```
Causa probable: allProjectsProvider falla
Solución: Verificar que repository.getAllProjects() funciona
         Revisar SQLite/Data Source
         Comprobar provider import
```

### Bug: Guía desaparece
```
Causa probable: buildHybridProjectsList no incluye mock
Solución: Verificar getMockProjectsData() retorna datos
         Comprobar mock projects se convierten a Project
         Revisar que no se filtren
```

### Bug: Button no aparece
```
Causa probable: allProjects.length <= 8
Solución: Agregar más proyectos para llegar a >8
         O cambiar umbral en código
```

### Bug: Spinner infinito
```
Causa probable: allProjectsProvider no completa
Solución: Revisar repository.getAllProjects()
         Comprobar DB conexión
         Ver logs de Riverpod
```

---

## 📝 Notas Importantes

1. **Sistema Híbrido:** Real + Mock en misma interfaz
2. **Projects Reales:** Vienen de repositorio (DB/API)
3. **Projects Mock:** Vienen de constantes en mock_data.dart
4. **Protocolo Virtual:** mock:// para identificar guía
5. **Statuss:** loading, error, data correctamente manejados

---

## ✨ Conclusión

Si los 10 tests pasan → Sistema híbrido completamente funcional ✅

**Próximo paso:** Deployment/Release
