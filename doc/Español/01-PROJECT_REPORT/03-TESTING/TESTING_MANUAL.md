# 🧪 Manual de Prueba - Proyecto Shell Screen

> **Objetivo:** Validar todas las características implementadas
> **Duración Estimada:** 10-15 minutos
> **Compilación Requerida:** ✅ `flutter ejecutar`

---

## ✅ Checklist de Pruebas Funcionales

### Prueba 1: Interfaz General ✅

**Pasos:**
1. Ejecuta `flutter ejecutar` en src/client/
2. Navega a Proyecto Shell Screen
3. Verifica visualmente:

```
RESULTADO ESPERADO:
┌──────────────────────────────────────────────────┐
│ [SB] [FILES] [CHAT + PROGRESS] [PREVIEW] [FABs] │
└──────────────────────────────────────────────────┘

✓ Sidebar visible (64px izquierda)
✓ Files panel visible (260px)
✓ Chat panel expandido (flexible)
✓ Preview panel visible (420px derecha)
✓ 2 FABs en esquina inferior derecha
```

---

### Prueba 2: Árbol de Directorios 📁

**Pasos:**
1. Observa el panel "Archivos" (columna 1)
2. Verifica estructura:

```
RESULTADO ESPERADO:
┌─ EXPLORER ↻
├─ ► PROJECT-ALPHA
├─ ► context/
├─ ► 10-CONTEXT/
├─ ► 20-REQUIREMENTS/
└─ ► 30-ARCHITECTURE/
```

**Sub-pruebas:**

a) **Expandir carpeta:**
   - Haz clic en `►` de PROJECT-ALPHA
   - **Esperado:** Cambia a `▼` y muestra subcarpetas
   - **Confirmado:** ✅ / ❌

b) **Contraer carpeta:**
   - Haz clic en `▼` de PROJECT-ALPHA
   - **Esperado:** Cambia a `►` y oculta subcarpetas
   - **Confirmado:** ✅ / ❌

c) **Expandir 10-CONTEXT:**
   - Haz clic en `►` de 10-CONTEXT/
   - **Esperado:** Muestra:
     ```
     • 01-vision.md
     • 02-constraints.md
     • 03-arch-overview.md
     ```
   - **Confirmado:** ✅ / ❌

d) **Seleccionar archivo:**
   - Haz clic en `01-vision.md`
   - **Esperado:**
     - Archivo se resalta en AZUL
     - Preview actualiza contenido
     - Árbol NO se cierra
   - **Confirmado:** ✅ / ❌

---

### Prueba 3: Preview Markdown 📄

**Pasos:**
1. Selecciona un archivo .md del árbol
2. Verifica panel Preview (derecha):

```
RESULTADO ESPERADO:
┌─ [👁] Architecture Overview.md [📋] [📥]
├────────────────────────────────
│ # 3. Architecture Overview
│
│ This document outlines...
│
│ ## System Context
│ ┌─────────────────┐
│ │ API Gateway │
│ ...
```

**Sub-pruebas:**

a) **Contenido visible:**
   - **Esperado:** Markdown content se muestra correctamente
   - **Confirmado:** ✅ / ❌

b) **Scroll funciona:**
   - Scroll dentro del preview panel
   - **Esperado:** Contenido se desplaza
   - **Confirmado:** ✅ / ❌

c) **Botones toolbar:**
   - Botón Copy (📋)
   - **Esperado:** Copia contenido al clipboard
   - **Confirmado:** ✅ / ❌ (verificar con paste en otro lado)

---

### Prueba 4: Chat Panel 💬

**Pasos:**
1. Observa panel central (CHAT)

```
RESULTADO ESPERADO:
┌─ Generando Documento 8 de 25  [⏸ Pause]
├─ ████████░░░░░░░░░░░░░░░░░░░░ 32%
├────────────────────────────────
│ [SYSTEM] SoftArchitect AI Project...  14:32
│ [USER] Generate the high-level...     14:31
│ [ASSISTANT] I have analyzed...        14:30
├────────────────────────────────
│ [Input field] [Send button]
```

**Sub-pruebas:**

a) **Progress bar:**
   - Visible con animación
   - Valor: 8/25 = 32%
   - **Confirmado:** ✅ / ❌

b) **Mensajes:**
   - 3 mensajes mockeados visibles
   - Alineación correcta (user derecha, assistant izquierda)
   - **Confirmado:** ✅ / ❌

c) **Input field:**
   - Campo de texto vacío y clickeable
   - **Confirmado:** ✅ / ❌

d) **Send botón:**
   - Botón visible con icono ✈
   - Clickeable (aunque no hace nada en demo)
   - **Confirmado:** ✅ / ❌

---

### Prueba 5: Columnas Resizables 🔄

**Prueba 5a: Redimensionar Archivos Panel**

Pasos:
1. Posiciona mouse en el borde DERECHO del Archivos panel
2. Observa cambio de cursor
3. Arrastra a la izquierda/derecha

```
RESULTADO ESPERADO:
├─ Cursor cambia a ↔ (resizeColumn)
├─ Borde se ilumina en AZUL al pasar
├─ Draggear a la izquierda → Panel más estrecho
├─ Draggear a la derecha → Panel más ancho
├─ Límites: 200px (mín) - 500px (máx)
└─ Cambio es SUAVE (sin saltos)
```

**Confirmado:** ✅ / ❌

**Prueba 5b: Redimensionar Preview Panel**

Pasos:
1. Posiciona mouse en el borde IZQUIERDO del Preview panel
2. Arrastra

```
RESULTADO ESPERADO:
├─ Mismo comportamiento que Test 5a
├─ Límites: 300px (mín) - 600px (máx)
└─ Chat panel se comprime/expande
```

**Confirmado:** ✅ / ❌

---

### Prueba 6: Columnas Ocultables 👁

**Prueba 6a: Toggle Archivos Panel**

Pasos:
1. Ubica los 2 FABs en esquina inferior derecha
2. Haz clic en FAB superior (📁 carpeta icon)

```
RESULTADO ESPERADO:
├─ Files panel desaparece
├─ Chat panel se expande
├─ FAB cambia a mostrar folder vacío (?)
└─ Chat gana espacio horizontal
```

**Sub-prueba:**
- Haz clic nuevamente en el FAB
- **Esperado:** Archivos panel reaparece en su posición
- **Confirmado:** ✅ / ❌

**Prueba 6b: Toggle Preview Panel**

Pasos:
1. Haz clic en FAB inferior (👁 visibility icon)

```
RESULTADO ESPERADO:
├─ Preview panel desaparece
├─ Chat panel se expande
├─ FAB cambia icono
└─ Chat gana espacio horizontal
```

**Sub-prueba:**
- Haz clic nuevamente
- **Esperado:** Preview panel reaparece
- **Confirmado:** ✅ / ❌

---

### Prueba 7: Interacción Completa 🎭

**Escenario:** Revisar documentoos y cambiar layout

Pasos:
1. ✅ Archivos panel visible (prueba 2 passed)
2. ✅ Expande 10-CONTEXT (prueba 2d passed)
3. ✅ Selecciona 01-vision.md (preview actualiza)
4. ✅ Redimensiona Archivos panel (prueba 5a)
5. ✅ Redimensiona Preview panel (prueba 5b)
6. ✅ Oculta Preview (ganas espacio para chat)
7. ✅ Oculta Archivos (solo Chat)
8. ✅ Muestra ambos nuevamente
9. ✅ Selecciona otro archivo (02-constraints.md)
10. ✅ Preview se actualiza sin cerrar Archivos

```
RESULTADO ESPERADO:
✓ Todo funciona sin errores
✓ Transiciones suaves
✓ Estado persiste (widths, visibility)
```

**Confirmado:** ✅ / ❌

---

## 🔍 Checklist de Calidad Visual

Verifica estos elementos visuales:

- ✅ GitHub Dark theme aplicado (colores oscuros)
- ✅ Iconos consistentes
- ✅ Fuente monospace en explorer (JetBrains Mono)
- ✅ Fuente monospace en preview
- ✅ Contraste legible (texto claro sobre fondo oscuro)
- ✅ Sin elementos deformados o solapados
- ✅ Padding/spacing consistente
- ✅ Bordes visible separando paneles
- ✅ Hover effects funcionan (cursor, color)
- ✅ Animaciones suaves (no jerky)

---

## 🐛 Pruebas de Error (Edge Cases)

### Prueba E1: Árbol profundo
- ✅ Expande múltiples niveles
- ✅ Scroll funciona correctamente
- ✅ Indentación coherente

### Prueba E2: Columnas extremas
- Redimensiona Archivos a 200px (mínimo)
- Redimensiona Preview a 300px (mínimo)
- **Esperado:** Todo cabe en pantalla, no hay overflow

### Prueba E3: Selecciones múltiples
- Selecciona archivo A
- Selecciona archivo B
- **Esperado:** Solo B está resaltado, A se deselecciona

### Prueba E4: Toggle rápido
- Haz clic rápidamente en FAB 5+ veces
- **Esperado:** Panel togglea sin errores (sin lag)

---

## 📊 Resultadoados

### Resumen de Pruebas

| Prueba | Resultadoado | Notas |
|------|-----------|-------|
| T1: Interfaz General | ✅ / ❌ | |
| T2: Árbol Directorios | ✅ / ❌ | |
| T3: Preview Markdown | ✅ / ❌ | |
| T4: Chat Panel | ✅ / ❌ | |
| T5: Columnas Resizable | ✅ / ❌ | |
| T6: Columnas Ocultables | ✅ / ❌ | |
| T7: Interacción Completa | ✅ / ❌ | |
| E1: Edge Case Profundo | ✅ / ❌ | |
| E2: Edge Case Extremo | ✅ / ❌ | |
| E3: Edge Case Múltiple | ✅ / ❌ | |
| E4: Edge Case Rápido | ✅ / ❌ | |

**Total:** __ / 11 pruebas ✅

---

## 📝 Reporte de Issues

Si encuentras algún problema, documéntalo aquí:

```
Issue #1:
└─ Descripción: [Describe qué no funciona]
└─ Pasos para reproducir: [Qué hiciste]
└─ Esperado: [Qué debería pasar]
└─ Actual: [Qué pasó en su lugar]
└─ Evidencia: [Screenshot/video si aplica]

Issue #2:
└─ [Repite formato]
```

---

## ✨ Conclusión

Si todos los pruebas son **✅**, entonces:

```
🎉 PROJECT SHELL SCREEN ESTÁ LISTO PARA PRODUCCIÓN
```

---

**Pruebaer:** ________________
**Fecha:** ________________
**Resultadoado Final:** ✅ PASS / ❌ FAIL
