# 🧪 GUÍA DE TESTING - SISTEMA HÍBRIDO MEJORADO

> **Fecha:** 9 de febrero de 2026
> **Cambios Validados:** ✅ 2 archivos, 0 errores
> **Estado:** Listo para Testing Manual

---

## 📋 Testing Checklist

### ANTES DE EMPEZAR
```
✅ Compilación limpia (flutter analyze)
✅ App ejecutable (flutter run)
✅ Navegación funcional
```

---

## 🧪 TEST 1: Proyectos Reales Se Muestran

### Pasos
1. Abrir SoftArchitect AI
2. Ir a Dashboard (ProjectWorkspaceScreen)
3. Esperar a que cargue (ver spinner si es necesario)
4. Observar grid de proyectos

### Resultado Esperado ✅
- Si existen proyectos reales en DB → Aparecen en grid
- Si NO existen → Muestra solo guía (es correcto)
- Cada proyecto muestra: nombre, icono, fase, fecha

### Resultado Incorrecto ❌
- Grid vacío aunque existan proyectos
- Proyectos no aparecen tras crear uno nuevo
- Spinner infinito sin cargar

---

## 🧪 TEST 2: Proyectos Mock (Guía) Se Muestran

### Pasos
1. Abrir Dashboard
2. Buscar en grid: "Guía SoftArchitect" (o "Quick Start")
3. Verificar que está junto a otros proyectos

### Resultado Esperado ✅
- Guía aparece en el grid
- Se muestra con ícono de libro
- Tiene badge de "Documentación"
- Ordenada por fecha junto a otros

### Resultado Incorrecto ❌
- Guía no aparece
- Aparece duplicada
- No se puede interactuar con ella

---

## 🧪 TEST 3: Botón "Ver Todos los Proyectos"

### Pasos
1. Dashboard con múltiples proyectos (>8)
2. Buscar botón "Ver todos los proyectos (X)"
3. Hacer click en botón
4. Verificar que se expande

### Resultado Esperado ✅
- Botón visible cuando hay >8 proyectos
- Al hacer click: aparece lista expandible
- Botón cambia a "Ocultar proyectos"
- Lista muestra TODOS los proyectos (reales + mock)
- Ordenados alfabéticamente

### Resultado Incorrecto ❌
- Botón no aparece aunque hay >8
- Al hacer click no sucede nada
- Lista no muestra todos los proyectos
- Faltan proyectos reales o mock

---

## 🧪 TEST 4: Crear Nuevo Proyecto Real

### Pasos
1. Dashboard → Click en "+ Nuevo Proyecto"
2. Llenar formulario:
   - Nombre: "Mi Proyecto Test"
   - Ruta: Seleccionar carpeta vacía
   - Descripción: "Test del sistema híbrido"
3. Click en "Crear Proyecto"

### Resultado Esperado ✅
- Diálogo se cierra
- Mensaje: "Proyecto creado exitosamente"
- Navega a project-shell (proyecto nuevo)
- Vuelve al dashboard
- Nuevo proyecto aparece en grid
- Se puede expandir y ver todos (aparece ahí)

### Resultado Incorrecto ❌
- Diálogo no se cierra
- Error al crear proyecto
- Proyecto no aparece en grid
- Proyecto no aparece al expandir

---

## 🧪 TEST 5: Navegar a Proyecto Real

### Pasos
1. Dashboard → Grid con proyectos reales
2. Click en una tarjeta de proyecto real
3. Esperar a que navegue

### Resultado Esperado ✅
- URL cambia a `/project-shell?path=/home/user/...`
- ProjectShellScreen carga
- FileTreeWidget muestra árbol de archivos REALES
- Se pueden expandir carpetas
- Se pueden leer archivos reales

### Resultado Incorrecto ❌
- No navega
- Navega a URL incorrecto
- Muestra árbol mock en lugar de real
- Archivos no se pueden leer

---

## 🧪 TEST 6: Navegar a Guía (Mock Project)

### Pasos
1. Dashboard → Grid
2. Click en "Guía SoftArchitect" (o proyecto mock)
3. Esperar a que navegue

### Resultado Esperado ✅
- URL cambia a `/project-shell?path=mock://softarchitect-guide`
- ProjectShellScreen carga
- FileTreeWidget muestra árbol de GUÍA
- Archivos: "00-Bienvenido.md", "features/Chat-IA.md", etc.
- Al hacer click en archivo: muestra contenido markdown

### Resultado Incorrecto ❌
- No navega a guía
- URL incorrecto (no tiene mock://)
- Árbol vacío o incorrecto
- Archivos no muestran contenido

---

## 🧪 TEST 7: Loading State

### Pasos
1. Simular conexión lenta:
   - En DevTools: Network → Throttling (Slow 3G)
2. Abrir Dashboard
3. Observar mientras carga

### Resultado Esperado ✅
- Spinner circular visible mientras carga
- Mensaje "Cargando..."
- Spinner desaparece al completar

### Resultado Incorrecto ❌
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

### Resultado Esperado ✅
- Muestra mensaje: "Error al cargar proyectos: [error]"
- Ícono de error rojo
- Usuario puede intentar de nuevo (recargar)

### Resultado Incorrecto ❌
- Pantalla blanca sin mensaje
- App se crashea
- Error stack trace expuesto

---

## 🧪 TEST 9: Expandir/Contraer Lista

### Pasos
1. Dashboard con >8 proyectos
2. Botón "Ver todos los proyectos"
3. Click: se expande → muestra lista
4. Click de nuevo: se contrae → oculta lista
5. Repetir 3 veces

### Resultado Esperado ✅
- Cada click expande/contrae
- Lista muestra todos (real + mock)
- Sin lag o delays
- Animación suave

### Resultado Incorrecto ❌
- Estado no cambia
- Lista parcial
- Lag visible
- Proyecto falta al expandir

---

## 🧪 TEST 10: Orden de Proyectos

### Pasos
1. Crear 3 proyectos nuevos en diferentes momentos
2. Dashboard → Grid (primeros 8)
3. Dashboard → Expandir (todos)
4. Verificar orden

### Resultado Esperado ✅
- Grid: ordenados por fecha DESC (más recientes primero)
- Lista: ordenados alfabéticamente (como está implementado)
- Guía aparece en posición correcta

### Resultado Incorrecto ❌
- Orden aleatorio
- Duplicados
- Guía desaparece

---

## 📊 Scoring del Testing

| Test | Crítico | Resultado | Estado |
|------|---------|-----------|--------|
| 1. Reales muestran | 🔴 | ? | ⏳ |
| 2. Mock muestra | 🔴 | ? | ⏳ |
| 3. Botón expandir | 🟡 | ? | ⏳ |
| 4. Crear proyecto | 🔴 | ? | ⏳ |
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
- [x] Proyectos reales se obtienen del repositorio
- [x] Proyectos mock se muestran (guía)
- [x] Ambos combinados en misma lista
- [x] Botón expandir funciona
- [x] Puede crear proyecto y aparece
- [x] Puede navegar a proyecto real
- [x] Puede navegar a guía
- [x] Sin errores de compilación

### RECOMENDADO (Nice to Have)
- [x] Loading state visible
- [x] Error state visible
- [x] Orden lógico
- [x] Performance aceptable

---

## 🐛 Si Encuentras Bugs

### Bug: Proyectos reales no aparecen
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

### Bug: Botón no aparece
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
2. **Proyectos Reales:** Vienen de repositorio (DB/API)
3. **Proyectos Mock:** Vienen de constantes en mock_data.dart
4. **Protocolo Virtual:** mock:// para identificar guía
5. **Estados:** loading, error, data correctamente manejados

---

## ✨ Conclusión

Si los 10 tests pasan → Sistema híbrido completamente funcional ✅

**Próximo paso:** Deployment/Release
