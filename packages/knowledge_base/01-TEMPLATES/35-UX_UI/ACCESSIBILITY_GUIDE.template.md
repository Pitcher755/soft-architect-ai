# ♿ Accessibility Guidelines (a11y)

Estándar de accesibilidad para **{{PROJECT_NAME}}**.
**Nivel Objetivo:** WCAG 2.1 Nivel {{WCAG_LEVEL}} (AA / AAA).

## 1. Contraste y Color
* **Texto Normal:** Ratio mínimo 4.5:1.
* **Texto Grande:** Ratio mínimo 3:1.
* **Semántica:** No usar color como único indicador de error (usar iconos + texto).

## 2. Lectores de Pantalla (Screen Readers)
* **Imágenes:** Todas deben tener `alt text` o ser marcadas como decorativas.
* **Etiquetas:** Todos los Inputs deben tener `label` o `aria-label`.
* **Foco:** El orden de tabulación debe ser lógico (Izquierda -> Derecha, Arriba -> Abajo).

## 3. Interacción (Teclado/Gestos)
* **Focus Visible:** El elemento activo siempre debe tener un borde visual claro.
* **Touch Target:** Mínimo {{TOUCH_TARGET_SIZE}}px (Ej: 44px) para dedos en móviles.
* **Navegación por Teclado:** Todos los botones y links deben ser accesibles sin ratón.

## 4. Pruebas de Accesibilidad
* **Herramientas:** Lighthouse / Axe / WAVE.
* **Frecuencia:** Al menos una vez por sprint.
* **Criterio de Aceptación:** 0 errores críticos antes de release.

## 5. Documentación Especial
* **Atajos de Teclado:** Listar todos los atajos disponibles.
* **Modo de Alto Contraste:** Disponible para usuarios con baja visión.
