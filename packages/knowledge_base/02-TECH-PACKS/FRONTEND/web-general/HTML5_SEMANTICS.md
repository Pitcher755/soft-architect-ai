# 🌐 HTML5 Semantics & Accessibility Standards

> **Fecha:** 30/01/2026
> **Estado:** ✅ MANDATORY
> **Alcance:** Todo desarrollo Web (React, Vue, Angular, Vanilla, Flutter Web)
> **Objetivo:** Accesibilidad (a11y), SEO, mantenibilidad y performance
> **Referencia:** WCAG 2.1 Level AA, HTML5 Living Standard

Prohibición absoluta del "Div Soup". Cada elemento tiene un significado semántico. Úsalo.

---

## 📖 Tabla de Contenidos

1. [La Regla de Oro: "No Div Soup"](#la-regla-de-oro-no-div-soup)
2. [Jerarquía Semántica](#jerarquía-semántica)
3. [Elementos HTML5 Esenciales](#elementos-html5-esenciales)
4. [Formularios Accesibles](#formularios-accesibles)
5. [ARIA: Accessible Rich Internet Applications](#aria-accessible-rich-internet-applications)
6. [Imágenes y Medios](#imágenes-y-medios)
7. [Landmarks y Navegación](#landmarks-y-navegación)
8. [Accesibilidad del Teclado](#accesibilidad-del-teclado)
9. [Anti-Patterns & Errores Comunes](#anti-patterns--errores-comunes)
10. [Checklist de Accesibilidad](#checklist-de-accesibilidad)

---

## La Regla de Oro: "No Div Soup"

**Principio Fundamental:** Si un elemento tiene significado semántico, **NO uses `<div>`**.

### Matriz de Prohibición

| Componente | ❌ MALO (Div Soup) | ✅ BUENO (Semántico) | Razón |
|:---|:---|:---|:---|
| **Botón** | `<div onclick="...">Click</div>` | `<button type="button">Click</button>` | Foco de teclado, screen readers, estilos nativos |
| **Enlace** | `<div class="link" onclick="...">` | `<a href="/page">Link</a>` | Navegación nativa, SEO, indexación |
| **Navegación** | `<div class="nav">...</div>` | `<nav>...</nav>` | Landmark region para lectores de pantalla |
| **Artículo** | `<div class="post">...</div>` | `<article>...</article>` | Contenido independiente, distribuible |
| **Sección** | `<div class="section">...</div>` | `<section>...</section>` | Agrupación temática con encabezado |
| **Sidebar** | `<div class="sidebar">...</div>` | `<aside>...</aside>` | Contenido tangencial, distinto del main |
| **Encabezado** | `<div class="header">...</div>` | `<header>...</header>` | Contenido introductorio del sitio/sección |
| **Pie** | `<div class="footer">...</div>` | `<footer>...</footer>` | Información de cierre (copyright, links) |
| **Título** | `<div class="title">Título</div>` | `<h1>`, `<h2>`, `<h3>` | Jerarquía de contenido, outline |

---

## Jerarquía Semántica

### Estructura Correcta de Documento

```html
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Título de la Página</title>
</head>
<body>
  <!-- ============================================================ -->
  <!-- HEADER: Encabezado del sitio -->
  <!-- ============================================================ -->
  <header>
    <div class="logo">SoftArchitect</div>
    <nav>
      <a href="/">Inicio</a>
      <a href="/docs">Documentación</a>
      <a href="/api">API</a>
    </nav>
  </header>

  <!-- ============================================================ -->
  <!-- MAIN: Contenido principal (UNO por página) -->
  <!-- ============================================================ -->
  <main>
    <h1>Título Principal (Único por página)</h1>

    <!-- ARTICLE: Contenido independiente -->
    <article>
      <h2>Primer Artículo</h2>
      <p>Contenido...</p>
    </article>

    <article>
      <h2>Segundo Artículo</h2>
      <p>Contenido...</p>
    </article>
  </main>

  <!-- ============================================================ -->
  <!-- ASIDE: Contenido tangencial (Sidebar) -->
  <!-- ============================================================ -->
  <aside>
    <h2>Contenido Relacionado</h2>
    <ul>
      <li><a href="#">Link 1</a></li>
      <li><a href="#">Link 2</a></li>
    </ul>
  </aside>

  <!-- ============================================================ -->
  <!-- FOOTER: Información de cierre -->
  <!-- ============================================================ -->
  <footer>
    <p>&copy; 2026 SoftArchitect. Todos los derechos reservados.</p>
  </footer>
</body>
</html>
```

### Principios de Jerarquía

1. **Un `<main>` por página:** Contenedor del contenido principal
2. **Jerarquía de `<h1>-<h6>` lineal:** No saltear niveles (`<h1>` → `<h3>`)
3. **Landmarks en orden:** `<header>` → `<main>` → `<aside>` → `<footer>`
4. **`<section>` para temas:** Agrupa contenido temático con `<h2>`/`<h3>`

#### ❌ MALO: Jerarquía Rota

```html
<body>
  <!-- Error: <h3> sin <h2> -->
  <h1>Página</h1>
  <h3>Subtítulo</h3>  <!-- Salta nivel! -->

  <!-- Error: Múltiples <main> -->
  <main>...</main>
  <main>...</main>  <!-- Prohibido! -->
</body>
```

#### ✅ BUENO: Jerarquía Correcta

```html
<body>
  <h1>Página Principal</h1>

  <section>
    <h2>Sección 1</h2>
    <p>Contenido...</p>

    <article>
      <h3>Artículo dentro de Sección 1</h3>
      <p>Contenido...</p>
    </article>
  </section>
</body>
```

---

## Elementos HTML5 Esenciales

### Contenedores Semánticos

| Elemento | Uso | Ejemplo |
|:---|:---|:---|
| **`<header>`** | Encabezado del sitio o sección | Logo, navegación principal |
| **`<nav>`** | Navegación (solo para links "principales") | Menú principal, breadcrumbs |
| **`<main>`** | Contenido principal (UNO por página) | Artículos, formularios |
| **`<article>`** | Contenido independiente, distribuible | Blog post, comentario, tarjeta de producto |
| **`<section>`** | Agrupación temática (con encabezado) | Capítulo, grupo de artículos |
| **`<aside>`** | Contenido tangencial | Sidebar, relacionados, publicidad |
| **`<footer>`** | Información de cierre | Copyright, links legales |

### Elementos Interactivos

#### Botones

```html
<!-- ✅ GOOD: Botones semánticos -->
<button type="button">Botón genérico</button>
<button type="submit">Enviar formulario</button>
<button type="reset">Limpiar formulario</button>

<!-- ❌ BAD: Divs con onclick -->
<div onclick="handleClick()">No soy un botón</div>

<!-- ✅ GOOD: Botones con aria-label para solo-icono -->
<button type="button" aria-label="Abrir menú">
  <svg>...</svg>
</button>
```

#### Enlaces

```html
<!-- ✅ GOOD: Enlaces semánticos -->
<a href="/page">Ir a página</a>
<a href="#section">Ir a sección (anchor)</a>
<a href="mailto:user@example.com">Email</a>
<a href="tel:+34123456789">Llamar</a>

<!-- ❌ BAD: Divs simulando enlaces -->
<div onclick="navigate('/page')">No soy un enlace</div>

<!-- ⚠️ CUIDADO: Enlaces "falsos" en SPA -->
<!-- En React/Vue, usa <Link> o <router-link>, NO <a> con href='#' -->
<a href="#">Esto recarga la página</a>
<Link to="/page">✅ Esto NO recarga</Link>
```

---

## Formularios Accesibles

### Regla Clave: `<label>` Asociado a `<input>`

**TODO `<input>` DEBE tener un `<label>`** (asociado programáticamente).

#### ✅ GOOD: 3 Formas de Asociar Label

```html
<!-- 1️⃣ Explícito: Label con for + Input con id -->
<label for="email">Email:</label>
<input type="email" id="email" name="email" required>

<!-- 2️⃣ Implícito: Label envuelve Input -->
<label>
  Email:
  <input type="email" name="email" required>
</label>

<!-- 3️⃣ aria-labelledby (para layouts complejos) -->
<div id="email-label">Email:</div>
<input type="email" aria-labelledby="email-label">
```

#### ❌ BAD: Sin Asociación

```html
<!-- ❌ MALO: Placeholder sin label (no accesible) -->
<input type="email" placeholder="Email">

<!-- ❌ MALO: Label sin asociación -->
<label>Email:</label>
<input type="email">  <!-- ¿A quién corresponde? -->

<!-- ❌ MALO: Sólo visualmente relacionado -->
<div>Email:</div>
<input type="email">  <!-- Screen reader no los conecta -->
```

### Estructura de Formulario

```html
<form>
  <fieldset>
    <legend>Datos Personales</legend>

    <div class="form-group">
      <label for="name">Nombre:</label>
      <input
        type="text"
        id="name"
        name="name"
        required
        aria-required="true"
      >
    </div>

    <div class="form-group">
      <label for="email">Email:</label>
      <input
        type="email"
        id="email"
        name="email"
        required
        aria-describedby="email-hint"
      >
      <small id="email-hint">Usaremos esto para contactarte</small>
    </div>
  </fieldset>

  <fieldset>
    <legend>Preferencias</legend>

    <div class="form-group">
      <input type="checkbox" id="subscribe" name="subscribe">
      <label for="subscribe">Suscribirse a newsletter</label>
    </div>
  </fieldset>

  <button type="submit">Enviar</button>
  <button type="reset">Limpiar</button>
</form>
```

### Validación Accesible

```html
<form novalidate>  <!-- Desactivar validación por defecto del navegador -->
  <div class="form-group">
    <label for="email">Email:</label>
    <input
      type="email"
      id="email"
      name="email"
      aria-invalid="false"
      aria-describedby="email-error"
    >
    <!-- Mensaje de error (oculto inicialmente) -->
    <div id="email-error" role="alert" style="display:none;">
      Email inválido. Ejemplo: user@example.com
    </div>
  </div>
</form>
```

---

## ARIA: Accessible Rich Internet Applications

**Principio Clave:** "No ARIA is better than bad ARIA".

### Reglas

1. **Preferir HTML5 nativo** antes de ARIA
2. **ARIA solo para componentes complejos:** Tabs, Modales, Dropdowns custom
3. **No redefinir semántica:** No poner `role="button"` a un `<button>`
4. **Verificar con screen reader:** NVDA (Windows), JAWS, VoiceOver (macOS)

### Atributos ARIA Comunes

| Atributo | Uso | Ejemplo |
|:---|:---|:---|
| **`aria-label`** | Label para elementos sin texto visible | Botón de solo icono |
| **`aria-labelledby`** | Conecta elemento a label por ID | Diálogos, modales |
| **`aria-describedby`** | Descripción adicional (hint, error) | Input con ayuda |
| **`aria-required`** | Marca campo como requerido | Formularios |
| **`aria-invalid`** | Indica error de validación | Campos con error |
| **`role="alert"`** | Anuncia contenido dinámicamente | Mensajes de error |
| **`aria-hidden="true"`** | Oculta de screen readers | Iconos decorativos |

### Ejemplos Prácticos

#### Botón de Solo Icono

```html
<!-- ✅ GOOD: aria-label describe el botón -->
<button type="button" aria-label="Cerrar menú">
  <svg>
    <use href="#icon-close"></use>
  </svg>
</button>

<!-- ❌ BAD: Botón sin label -->
<button type="button">
  <svg>...</svg>
</button>  <!-- Screen reader dice "botón" (inútil) -->
```

#### Modal/Diálogo

```html
<div role="dialog" aria-labelledby="modal-title" aria-modal="true">
  <h2 id="modal-title">Confirmar acción</h2>
  <p>¿Estás seguro?</p>
  <button type="button">Sí</button>
  <button type="button">No</button>
</div>
```

#### Contenido Dinámico (Live Region)

```html
<!-- role="alert" anuncia cambios automáticamente -->
<div role="alert" id="notification">
  <!-- Los cambios aquí se anuncian al screen reader -->
</div>

<script>
  const notification = document.getElementById('notification');
  notification.textContent = 'Guardado exitosamente';
  // Screen reader automáticamente anuncia esto
</script>
```

---

## Imágenes y Medios

### Atributo `alt` Obligatorio

**Regla:** TODO `<img>` DEBE tener `alt`, sin excepciones.

#### Imágenes Informativas

```html
<!-- ✅ GOOD: alt descriptivo -->
<img
  src="user-avatar.jpg"
  alt="Avatar de Juan García, usuario premium desde 2023"
>

<!-- ❌ BAD: alt genérico -->
<img src="user-avatar.jpg" alt="Avatar">

<!-- ❌ BAD: sin alt -->
<img src="user-avatar.jpg">
```

#### Imágenes Decorativas

```html
<!-- ✅ GOOD: alt vacío (screen reader las ignora) -->
<img src="decorative-line.png" alt="">

<!-- ❌ BAD: alt con descripción decorativa -->
<img src="decorative-line.png" alt="Línea decorativa">
<!-- Screen reader lo anuncia innecesariamente -->
```

#### Texto en Imágenes

```html
<!-- Si la imagen CONTIENE texto: incluirlo en alt -->
<img
  src="screenshot.png"
  alt="Panel de control: CPU 45%, RAM 72%, Disk 89%"
>
```

### Vídeo Accesible

```html
<!-- ✅ GOOD: Video con controls nativos -->
<video
  controls
  width="640"
  height="360"
  poster="thumbnail.jpg"
  aria-label="Demostración de SoftArchitect"
>
  <source src="video.mp4" type="video/mp4">
  <source src="video.webm" type="video/webm">

  <!-- Fallback para navegadores sin soporte -->
  <p>
    Tu navegador no soporta video.
    <a href="video.mp4">Descarga el video aquí</a>
  </p>
</video>

<!-- ✅ OBLIGATORIO: Subtítulos -->
<video controls>
  <source src="video.mp4" type="video/mp4">
  <track kind="captions" src="subtitles-es.vtt" srclang="es">
  <track kind="captions" src="subtitles-en.vtt" srclang="en">
</video>
```

---

## Landmarks y Navegación

### Landmarks Principales

Los screen readers usan landmarks para "saltar" entre secciones.

```html
<body>
  <!-- Landmark 1: Header/Banner -->
  <header role="banner">
    <h1>SoftArchitect</h1>
    <!-- Navegación principal -->
  </header>

  <!-- Landmark 2: Navegación -->
  <nav role="navigation" aria-label="Navegación principal">
    <a href="/">Inicio</a>
    <a href="/docs">Docs</a>
  </nav>

  <!-- Landmark 3: Main (el más importante) -->
  <main role="main">
    <!-- Contenido principal -->
  </main>

  <!-- Landmark 4: Sidebar (complementario) -->
  <aside role="complementary" aria-label="Sidebar">
    <!-- Contenido relacionado -->
  </aside>

  <!-- Landmark 5: Footer -->
  <footer role="contentinfo">
    <!-- Información de cierre -->
  </footer>
</body>
```

### Navegación con Breadcrumbs

```html
<nav aria-label="Rutas de navegación">
  <ol>
    <li><a href="/">Inicio</a></li>
    <li><a href="/docs">Documentación</a></li>
    <li><a href="/docs/api">API</a></li>
    <li aria-current="page">Referencia</li>
  </ol>
</nav>
```

---

## Accesibilidad del Teclado

### Regla: TODO Interactivo Debe Ser Accesible por Teclado

#### Orden de Tabulación

```html
<!-- ✅ GOOD: Orden natural de flujo -->
<form>
  <input type="text" placeholder="Nombre">    <!-- Tab 1 -->
  <input type="email" placeholder="Email">    <!-- Tab 2 -->
  <button type="submit">Enviar</button>       <!-- Tab 3 -->
</form>

<!-- ❌ BAD: Orden confuso (tabindex positivo) -->
<form>
  <input type="text" placeholder="Nombre" tabindex="3">
  <input type="email" placeholder="Email" tabindex="1">
  <button type="submit" tabindex="2">Enviar</button>
</form>
<!-- Tab order: Email → Enviar → Nombre (confuso!) -->
```

#### Skip Links (Saltar a main)

```html
<!-- ✅ GOOD: Link para saltar navegación -->
<a href="#main" class="skip-link">Saltar a contenido principal</a>

<style>
.skip-link {
  position: absolute;
  left: -9999px;  /* Oculto visualmente */
}

.skip-link:focus {
  left: 0;  /* Visible al recibir foco */
  top: 0;
  z-index: 999;
}
</style>

<nav>Navegación...</nav>
<main id="main">Contenido principal...</main>
```

#### Teclado en Componentes Custom

```html
<!-- ✅ GOOD: Elemento custom con soporte de teclado -->
<div role="menuitem" tabindex="0" onkeydown="handleKeyDown(event)">
  Opción del menú
</div>

<script>
function handleKeyDown(event) {
  if (event.key === 'Enter' || event.key === ' ') {
    handleMenuItemClick();
  }
}
</script>

<!-- ❌ BAD: Sin soporte de teclado -->
<div onclick="handleClick()">Opción del menú</div>
```

---

## Anti-Patterns & Errores Comunes

### ❌ Div Soup (El Gran Crimen)

```html
<!-- ❌ TERRIBLE: Puro divs, sin semántica -->
<div class="header">
  <div class="logo">Logo</div>
  <div class="nav">
    <div class="nav-item"><div onclick="...">Home</div></div>
    <div class="nav-item"><div onclick="...">Docs</div></div>
  </div>
</div>

<!-- ✅ CORRECTO: Semántica clara -->
<header>
  <div class="logo">Logo</div>
  <nav>
    <a href="/">Home</a>
    <a href="/docs">Docs</a>
  </nav>
</header>
```

### ❌ Ignorar Accessibilidad Nativa

```html
<!-- ❌ BAD: Reinventar botones -->
<div onclick="submit()">Enviar</div>  <!-- Sin Enter, sin foco, sin screen reader -->

<!-- ✅ GOOD: Usar HTML5 nativo -->
<button type="submit">Enviar</button>  <!-- Todo automático -->
```

### ❌ Formularios Sin Labels

```html
<!-- ❌ BAD: Inputs sin labels -->
<input type="text" placeholder="Email">
<input type="password" placeholder="Contraseña">

<!-- ✅ GOOD: Labels explícitos -->
<label for="email">Email:</label>
<input type="email" id="email">

<label for="password">Contraseña:</label>
<input type="password" id="password">
```

### ❌ Imágenes Sin Alt

```html
<!-- ❌ BAD: Imagen sin contexto -->
<img src="profile.jpg">

<!-- ✅ GOOD: Alt descriptivo -->
<img src="profile.jpg" alt="Perfil de María López, CEO">
```

### ❌ Colores Como Único Indicador

```html
<!-- ❌ BAD: Solo rojo para error (daltónicos no ven) -->
<input style="border: 2px solid red;">

<!-- ✅ GOOD: Color + icono + texto -->
<input aria-invalid="true">
<span role="alert">❌ Campo requerido</span>
```

---

## Checklist de Accesibilidad

### Pre-Deployment

```bash
# ✅ 1. Validar HTML
[ ] HTML válido (W3C Validator)
[ ] Sin atributos duplicados
[ ] Jerarquía de headings correcta (h1 → h2 → h3, sin saltos)

# ✅ 2. Semántica
[ ] NO hay "Div Soup" innecesario
[ ] Botones con <button>, links con <a>
[ ] Landmarks presentes: <header>, <nav>, <main>, <footer>

# ✅ 3. Formularios
[ ] TODA <input> tiene <label>
[ ] Labels asociados por id (for=...)
[ ] Mensajes de error con role="alert"
[ ] Campos requeridos marcados con aria-required

# ✅ 4. Imágenes
[ ] TODO <img> tiene alt
[ ] alt descriptivo (no "imagen" o "foto")
[ ] Imágenes decorativas tienen alt=""
[ ] Texto en imágenes incluido en alt

# ✅ 5. Teclado
[ ] TODO interactivo es accesible por Tab
[ ] Sin tabindex > 0 (salvo casos excepcionales)
[ ] Skip links presente (saltar a main)
[ ] Focus visible en todos los elementos

# ✅ 6. Colores & Contraste
[ ] Contraste ≥ 4.5:1 (texto normal vs fondo)
[ ] Contraste ≥ 3:1 (texto grande o UI)
[ ] No usar color SOLO como indicador (+ icono/texto)

# ✅ 7. Medios
[ ] Videos tienen captions (subtítulos)
[ ] Audio tiene transcripción
[ ] Autoplay desactivado (o muted)

# ✅ 8. Testing
[ ] Testeado con NVDA/JAWS/VoiceOver
[ ] Zoom 200% sin problemas
[ ] Navegación completa por teclado
[ ] Sin errores de axe DevTools

# ✅ 9. ARIA
[ ] ARIA solo para componentes complejos
[ ] aria-label para botones de solo-icono
[ ] role="alert" para contenido dinámico
[ ] Validar ARIA con screen reader

# ✅ 10. Documentación
[ ] Página de accesibilidad con declaración
[ ] Instrucciones de teclado documentadas
[ ] Formulario de feedback accesible
```

---

## Conclusión

**Accesibilidad no es un añadido; es un requisito fundamental.**

1. ✅ Usa HTML5 semántico (protege a ~20% de usuarios con disabilities)
2. ✅ Labels + ARIA para formularios complejos
3. ✅ Teclado navegable desde el inicio
4. ✅ Tests con screen readers reales

**Dogfooding Validation:** SoftArchitect valida su propia web con axe DevTools en cada deploy.
