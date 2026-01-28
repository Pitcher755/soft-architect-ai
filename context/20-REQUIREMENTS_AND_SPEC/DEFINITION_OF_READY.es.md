# 🚦 Definition of Ready (DoR) - Criterios de Entrada

> **Objetivo:** Evitar el "Garbage In, Garbage Out". No se empieza a programar hasta que no se sabe exactamente qué hay que hacer.
> **Uso:** El Agente debe consultar este archivo antes de aceptar un prompt de generación de código complejo.

---

## 1. Para Historias de Usuario (User Stories)

Una Historia de Usuario se considera **READY** para entrar en un Sprint solo si cumple el acrónimo INVEST y además tiene:

1.  **Título Claro:** Formato "Como [rol], quiero [acción], para [beneficio]".
2.  **Criterios de Aceptación (Gherkin/Lista):**
    * *Ejemplo:* "Dado que el usuario escribe texto, cuando pulsa Enter, el mensaje aparece en la lista."
    * Mínimo 3 criterios de verificación positivos y 1 negativo (caso de error).
3.  **Dependencias Resueltas:** No depende de una API que aún no existe o no está documentada en `API_INTERFACE_CONTRACT.md`.
4.  **Estimación:** Tiene una talla de camiseta (XS, S, M, L) o puntos de historia asignados.

---

## 2. Para Tareas de UI / Frontend

Además de lo anterior, requiere:

* [ ] **Referencia Visual:** Un wireframe, un prompt de *Stitch* validado, o una referencia a un componente existente en `DESIGN_SYSTEM.md`.
* [ ] **Assets:** Los iconos o imágenes necesarios están en `assets/` o en Figma.
* [ ] **Textos (Copy):** Los textos finales (o las claves de i18n) están definidos.

---

## 3. Para Tareas de Backend / API

Requiere:

* [ ] **Contrato de Datos:** El JSON de Request y Response está definido en `API_INTERFACE_CONTRACT.md`.
* [ ] **Manejo de Errores:** Se sabe qué códigos de error (`ERROR_HANDLING_STANDARD.md`) puede lanzar.
* [ ] **Estrategia de Datos:** Se sabe qué tablas de DB o colecciones vectoriales se van a leer/escribir.

---

## 4. Para Tareas de Documentación

Requiere:

* [ ] **Audiencia Definida:** Se sabe si es para humanos (`doc/`) o IA (`packages/knowledge_base/`).
* [ ] **Estándares de Formato:** Sigue `DOCUMENTATION_STANDARDS.md`.
* [ ] **Trigger de Actualización:** Vinculado a un cambio de código o decisión arquitectónica.

---

## 5. Criterios Generales

* [ ] **Sin Ambigüedades:** Todos los términos están definidos o enlazados a documentación existente.
* [ ] **Testable:** Puede ser verificado a través de tests automatizados o checks manuales.
* [ ] **Priorizado:** Tiene un nivel de prioridad (P1, P2, P3) y cabe en la capacidad del Sprint.
* [ ] **Alineado Arquitectónicamente:** No viola los principios de `ARCHITECTURE.md`.

---

> "🛑 **Bloqueo por DoR:** La tarea no cumple la *Definition of Ready*. Por favor, especifica los campos del formulario y el endpoint de autenticación antes de que genere el código."