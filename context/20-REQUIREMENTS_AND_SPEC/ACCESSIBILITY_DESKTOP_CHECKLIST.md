# ♿ Checklist de Accesibilidad (Desktop & A11y)

> **Estándar:** WCAG 2.1 Nivel AA.
> **Contexto:** Flutter Desktop (Linux/Windows).
> **Filosofía:** "Keyboard First". Una herramienta de desarrollo debe poder usarse sin ratón.

---

## 1. Navegación por Teclado (Focus Traversal)

El desarrollador (y el Agente) deben asegurar que todos los elementos interactivos sean alcanzables vía `Tab`.

* [ ] **Orden Lógico:** El foco debe moverse de izquierda a derecha y de arriba a abajo.
    * *Flutter Tip:* Usar `FocusTraversalGroup` para secciones complejas.
* [ ] **Indicador Visual:** Todo elemento con foco debe tener un borde o cambio de color visible.
    * *Regla:* No eliminar el `FocusNode` por defecto sin proveer una alternativa visual.
* [ ] **Atajos de Teclado:**
    * `Ctrl + Enter`: Enviar mensaje en el chat.
    * `Ctrl + N`: Nuevo Chat.
    * `Esc`: Cerrar modales o diálogos.

---

## 2. Lectores de Pantalla (Semantics)

La UI debe ser "leíble" por herramientas como NVDA (Windows) o Orca (Linux).

* [ ] **Etiquetado Semántico:** Todos los botones que son solo iconos (ej: "Enviar") deben tener `Tooltip` y envolverse en `Semantics(label: "Enviar mensaje")`.
* [ ] **Imágenes Decorativas:** Las ilustraciones o iconos sin función deben tener `Semantics(excludeSemantics: true)`.
* [ ] **Estados Dinámicos:** Si el chat está "Pensando...", el lector debe anunciar el cambio de estado.

---

## 3. Contraste y Legibilidad (Visual)

* [ ] **Ratio de Contraste:** Texto normal debe tener un ratio mínimo de 4.5:1 contra el fondo.
    * *Verificación:* Usar colores del `DESIGN_SYSTEM.md` (ya validados).
* [ ] **Escalado de Texto:** La UI no debe romperse si el usuario aumenta el tamaño de fuente del sistema operativo.
    * *Flutter Tip:* No usar alturas fijas en píxeles para contenedores de texto. Usar `Flexible` o `Expanded`.

---

## 4. Auditoría Automática (Dev Workflow)

Antes de cerrar una Pull Request de UI:

1.  Activar el inspector de accesibilidad de Flutter:
    ```dart
    // En main.dart (solo debug)
    MaterialApp(
      showSemanticsDebugger: true, // Muestra la capa semántica visualmente
      ...
    )
    ```
2.  Verificar que las áreas táctiles/clicables sean de al menos 44x44px.