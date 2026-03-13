# 🎨 Operación Da Vinci — Renderizado de Diagramas Mermaid

> **Fecha:** 26/02/2026
> **Estado:** ✅ Fase 1 Completada (API mermaid.ink)
> **Categoría:** Architecture Decision Record (ADR)
> **Iniciativa:** Operación Da Vinci — Diagramas Mermaid en Flutter Desktop
> **Autor:** ArchitectZero (SoftArchitect AI)

---

## 📖 Tabla de Contenidos

1. [Contexto y Objetivo Original](#1-contexto-y-objetivo-original)
2. [El Bloqueo Técnico — Limitaciones de WebView en Linux Desktop](#2-el-bloqueo-técnico--limitaciones-de-webview-en-linux-desktop)
3. [La Decisión Arquitectónica — El Pivotaje a mermaid.ink](#3-la-decisión-arquitectónica--el-pivotaje-a-mermaidink)
4. [Killer Feature — El Sanitizador de Alucinaciones de la IA](#4-killer-feature--el-sanitizador-de-alucinaciones-de-la-ia)
5. [Componentes Clave](#5-componentes-clave)
6. [Notas de Setup para Contribuidores](#6-notas-de-setup-para-contribuidores)
7. [Próximos Pasos (Backlog)](#7-próximos-pasos-backlog)

---

## 1. Contexto y Objetivo Original

El Master Workflow de SoftArchitect AI se apoya intensivamente en diagramas de arquitectura. El LLM genera bloques ` ```mermaid ` dentro de sus respuestas Markdown y dentro de los documentos de contexto generados. El objetivo era renderizar estos diagramas **de forma visual e incrustada**, directamente dentro del panel de chat y del visor de documentos.

### La Visión 100% Offline

El requisito original era inequívoco:

> **Todo el renderizado de diagramas debe ocurrir localmente, sin llamadas de red, preservando el principio de "Soberanía de Datos" del proyecto.**

El plan inicial era embeber `mermaid.min.js` dentro de una página HTML local servida por un widget `WebView`, y luego pasar el código fuente del diagrama mediante un puente JavaScript (`evaluateJavascript`). Se evaluaron dos paquetes candidatos:

| Paquete | Versión | Notas |
|---|---|---|
| `webview_flutter` | ^4.x | WebView oficial de Flutter |
| `flutter_inappwebview` | ^6.x | Mayor control sobre el puente JS |

Ambos paquetes eran capaces de lograr el objetivo en Android / iOS / macOS. El bloqueo apareció específicamente en **Linux Desktop**.

---

## 2. El Bloqueo Técnico — Limitaciones de WebView en Linux Desktop

### Lo que Encontramos

Tras añadir los paquetes e intentar inicializar el widget WebView, Flutter lanzaba un error de aserción en tiempo de ejecución:

```
WebViewPlatform.instance != null
Failed assertion: line 42 pos 14
```

#### Causa Raíz

Los paquetes `webview_flutter` y `flutter_inappwebview` delegan el renderizado a la implementación nativa de WebView del sistema operativo. En Linux, esto significa:

- **`webview_flutter_linux`** delega a `WebKitGTK` vía `libwebkit2gtk-4.1-dev`
- **`flutter_inappwebview_linux`** puede delegar también a `WPE WebKit` vía `libwpewebkit-1.0-dev`

Estos paquetes del sistema **no** están preinstalados en un escritorio Ubuntu / Debian estándar. Incluso instalados manualmente:

```bash
sudo apt install libwebkit2gtk-4.1-dev
# o bien
sudo apt install libwpewebkit-1.0-dev
```

Los paquetes seguían sin poder renderizar el WebView **inline** dentro del árbol de widgets. La implementación abría ventanas separadas a nivel de SO, desconectando por completo el diagrama del flujo del chat y rompiendo la UX.

### Impacto

| Criterio | Estado |
|---|---|
| Renderizado inline en el panel de chat | ❌ No es posible |
| Renderizado en la misma ventana | ❌ Abre ventana separada |
| Instalación sin dependencias extra | ❌ Requiere paquetes GTK pesados |
| Compatibilidad con CI/CD | ❌ Los agentes de build carecen de GTK |

**Decisión: Bloqueado temporalmente. Se requiere pivotaje para desbloquear el desarrollo de la feature.**

---

## 3. La Decisión Arquitectónica — El Pivotaje a mermaid.ink

### Repliegue Táctico

Se introdujo la API de renderizado **mermaid.ink** como solución temporal pero de calidad de producción. La API es un servicio público, gratuito y sin estado que acepta un payload JSON codificado en Base64 y devuelve una imagen PNG/SVG.

```
GET https://mermaid.ink/img/<base64url-payload>
```

### Algoritmo de Codificación

```dart
// En MermaidView — lib/shared/presentation/widgets/mermaid_view.dart
String get _imageUrl {
  final jsonPayload = jsonEncode({
    'code': _sanitizedCode,
    'mermaid': {'theme': 'dark', 'backgroundColor': 'transparent'},
  });

  final bytes = utf8.encode(jsonPayload);
  final base64Str = base64UrlEncode(bytes).replaceAll('=', '');

  return 'https://mermaid.ink/img/$base64Str';
}
```

1. Envolver el código Mermaid en un envelope JSON con metadatos de tema.
2. Codificar con `utf8.encode` → `base64UrlEncode`.
3. Eliminar el relleno (`=`) — requerido por la API.
4. Pasar la URL a `Image.network()`.

### Por Qué Funciona Bien

- **Cero dependencias Flutter extra**: usa únicamente el core de Dart `dart:convert`.
- **Permanece inline**: se renderiza como widget `Image` nativo dentro del árbol del chat / documento.
- **Estado de carga**: el `loadingBuilder` nativo muestra un spinner durante la descarga.
- **Estado de error**: el `errorBuilder` muestra un badge de advertencia si la API rechaza el payload.
- **Compatible con tema oscuro**: el tema se incrusta en el payload.

### Trade-offs Aceptados

| Atributo | Motor Offline (objetivo) | mermaid.ink (actual) |
|---|---|---|
| Requiere red | ❌ No | ✅ Sí |
| Privacidad | ✅ 100% local | ⚠️ Diagrama enviado a 3rd party |
| Soporte Linux | ❌ Bloqueado | ✅ Funciona en todas las plataformas |
| Latencia | < 10 ms | ~ 300–800 ms (red) |
| Dependencias | Paquetes pesados del SO | Ninguna |

> **Nota de privacidad:** Únicamente el código del diagrama se envía a los servidores de `mermaid.ink`. No se exponen mensajes del usuario, metadatos del proyecto ni claves de API. Para equipos con políticas de gobierno de datos estrictas, se puede sustituir por una instancia auto-alojada de mermaid.ink cambiando una única constante.

---

## 4. Killer Feature — El Sanitizador de Alucinaciones de la IA

### El Problema

Durante las pruebas de integración, el LLM generaba ocasionalmente código Mermaid sintácticamente inválido. El patrón de error más frecuente era una notación de flecha malformada:

```
%% Generado por el LLM (INCORRECTO)
A -->|Etiqueta|> B
             ^^^
             El |> extra provoca HTTP 400 en mermaid.ink
```

La API devolvía HTTP 400 para estos payloads, activando el widget de estado de error. El sanitizador se introdujo para prevenir esto de forma silenciosa, antes de la llamada de red.

### La Solución — Capa de Sanitización con Regex

```dart
// En MermaidView — getter sanitizedCode
String get _sanitizedCode => code
    // Corrige -->|Etiqueta|> → -->|Etiqueta|
    .replaceAll(RegExp(r'\|>\s*'), '| ')
    // Corrige ->(simple) → -->(doble)
    .replaceAll(RegExp(r'(?<!-)−>\|'), '-->|')
    .replaceAll('->|', '-->|');
```

| Patrón | Entrada | Salida | Motivo |
|---|---|---|---|
| `\|>\s*` | `-->|Despliega|>` | `-->|Despliega| ` | Elimina el `>` sobrante tras la etiqueta |
| `(?<!-)−>\|` | `−>|Auth|` | `-->|Auth|` | Corrige flecha con guión Unicode |
| `->|` | `->|Deploy|` | `-->|Deploy|` | Normaliza flecha con guión simple |

Esta sanitización se ejecuta **100% en cliente**, sin overhead de red, en cada renderizado de `MermaidView`.

---

## 5. Componentes Clave

### 5.1 `MermaidView` — Widget de Renderizado Central

**Ruta:** `lib/shared/presentation/widgets/mermaid_view.dart`

Un `StatelessWidget` puro que actúa como pipeline de renderizado:

```
String code (salida cruda del LLM)
    │
    ▼
_sanitizedCode    ← Sanitizador regex elimina patrones inválidos
    │
    ▼
_imageUrl         ← JSON encode → UTF-8 → Base64 URL-safe → URL mermaid.ink
    │
    ▼
Image.network()   ← Renderizado inline con estados de carga y error
```

### 5.2 `MermaidBuilder` — El Francotirador de `SmartMessageRenderer`

**Ruta:** `lib/shared/presentation/widgets/markdown_builders/mermaid_builder.dart`

Un `MarkdownElementBuilder` inyectado en `MarkdownBody.builders`. Intercepta los elementos `<code>` de Markdown cuya clase CSS es `language-mermaid` y los redirige a `MermaidView`. El resto de bloques de código se dejan intactos para el renderizador por defecto.

```dart
class MermaidBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final classList = element.attributes['class'] ?? '';
    if (classList.contains('language-mermaid')) {
      return MermaidView(code: element.textContent);
    }
    return null; // Continúa con el renderizado por defecto
  }
}
```

`SmartMessageRenderer` lo registra así:

```dart
MarkdownBody(
  data: content,
  builders: {'code': MermaidBuilder()},
  ...
)
```

### 5.3 `_CodeElementBuilder` — El Francotirador Híbrido de `MarkdownPreviewWidget`

**Ruta:** `lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart`

El widget de vista previa de documentos usa un `_CodeElementBuilder` local y privado que implementa el mismo patrón de interceptación, pero además gestiona los bloques de código con coloreado de sintaxis vía `flutter_highlighter`:

```dart
class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final language = /* extraído de class="language-X" */ ...;

    // Ruta: mermaid → MermaidView
    if (language == 'mermaid') {
      return MermaidView(code: codeContent);
    }

    // Ruta: todo lo demás → HighlightView (colores de sintaxis)
    return HighlightView(
      codeContent,
      language: language,
      theme: atomOneDarkTheme,
      ...
    );
  }
}
```

Este patrón de "francotirador híbrido" garantiza que un único mapa `builders` gestione **todos** los tipos de bloques de código sin lógica condicional en el árbol de widgets.

### 5.4 `MarkdownPreviewWidget` — Corrección de `PathNotFoundException`

Durante la vista previa de documentos, se llama a `_loadFileContent()` cuando se proporciona un `filename`. Antes de la corrección, intentar leer un archivo que nunca se había guardado (es decir, que solo existía como contenido en memoria del streaming) lanzaba un `PathNotFoundException`, rompiendo el panel de vista previa.

La corrección envuelve la llamada a `file.readAsString()` en un manejador de excepciones tipado y regresa de forma controlada al prop `widget.content`:

```dart
Future<void> _loadFileContent() async {
  try {
    final file = File(widget.filename!);
    final content = await file.readAsString();
    if (mounted && !_isEditing) {
      setState(() => _textController.text = content);
    }
  } on Exception catch (e) {
    debugPrint('⚠️ Error leyendo archivo: $e');
    // Fallback controlado al contenido en memoria
    if (mounted && !_isEditing) {
      setState(() => _textController.text = widget.content ?? '');
    }
  }
}
```

---

## 6. Notas de Setup para Contribuidores

> **⚠️ Nota para futuros contribuidores — Soporte WebView en Linux Desktop**

Si el equipo decide retomar el camino de renderizado offline con WebView (Fase 2.0), las siguientes bibliotecas a nivel de SO **deben** estar instaladas en cualquier host de build Linux o máquina de desarrollo antes de ejecutar `flutter build linux` con paquetes WebView:

```bash
# Opción A: WebKit GTK (webview_flutter_linux)
sudo apt install libwebkit2gtk-4.1-dev

# Opción B: WPE WebKit (flutter_inappwebview_linux)
sudo apt install libwpewebkit-1.0-dev

# También necesario en la mayoría de entornos mínimos
sudo apt install build-essential cmake ninja-build
```

Estos paquetes también deben declararse en el entorno del runner de GitHub Actions o en cualquier imagen Docker usada para CI/CD.

---

## 7. Próximos Pasos (Backlog)

| Prioridad | Tarea | Notas |
|---|---|---|
| P1 | **Evaluar madurez de WebView en Linux** | Re-evaluar cuando `webview_flutter_linux` >= 1.0 sea estable. Seguimiento en: [flutter/plugins#7246](https://github.com/flutter/flutter/issues) |
| P1 | **Opcional: mermaid.ink auto-alojado** | Desplegar `mermaid.ink` como sidecar Docker en `infrastructure/` para equipos que requieran soberanía total de datos (cero llamadas externas) |
| P2 | **Modo de renderizado SVG** | Usar el endpoint `mermaid.ink/svg/` + `flutter_svg` para diagramas independientes de resolución |
| P2 | **Caché de diagramas** | Añadir caché LRU indexado por hash del diagrama para evitar llamadas redundantes a la API para diagramas idénticos durante el streaming |
| P3 | **Ampliar reglas del sanitizador** | Monitorizar la salida del LLM en staging; añadir nuevos patrones regex para nuevas variantes de alucinaciones |
| P3 | **UI de fallback offline** | Si `mermaid.ink` no es accesible (sin internet), mostrar el código crudo en un bloque de código con estilo en lugar del widget de error |

---

> **Principio arquitectónico preservado:** El pivotaje a `mermaid.ink` se realizó de forma transparente sin cambiar la API pública de ningún widget consumidor. Todos los puntos de uso (`SmartMessageRenderer`, `MarkdownPreviewWidget`) continúan pasando cadenas de código Mermaid crudo sin saber cómo se implementa el renderizado — se preserva el principio de Inversión de Dependencias.
