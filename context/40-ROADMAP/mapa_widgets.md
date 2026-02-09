1. **Mapeo de HUs:** Cada componente indicará exactamente qué Historia de Usuario (HU) lo "paga" o requiere.
2. **Estilos Autónomos:** Cada bloque HTML incluirá su propio `<head>` con Tailwind, fuentes y estilos CSS completos. Podrás guardar cada bloque en un archivo `.html` separado y **funcionará perfectamente sin dependencias externas**.

Aquí tienes el **Inventario Maestro de UI (Sprint 3) - Edición Ejecutable**.

---

# 🎨 SOFTARCHITECT AI - UI GOLDEN KIT (SPRINT 3)

> **Estado:** 🚀 LISTO PARA IMPLEMENTAR
> **Instrucciones:** Copia cada bloque de código en un archivo `.html` para ver el diseño exacto.

---

## 1. PANTALLA PRINCIPAL (DASHBOARD)

Esta es la pantalla de "Bienvenida y Gestión".

* **🛠️ Implementación en HU:**
* **HU-3.1:** Estructura general, Sidebar, Grid de Proyectos, Navegación.
* **HU-3.1:** Persistencia de la lista (lectura de SQLite).


* **📱 Pantalla Flutter:** `ProjectSelectionScreen`
* **📄 Guardar como:** `dashboard.html`

```html
<!DOCTYPE html>
<html class="dark" lang="es">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>SoftArchitect - Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0d0df2",
                        "sidebar": "#161B22",
                        "main": "#0D1117",
                        "border-dark": "#30363d",
                        "text-secondary": "#8b949e",
                        "text-primary": "#E6EDF3"
                    },
                    fontFamily: {
                        "sans": ["Inter", "sans-serif"],
                        "mono": ["JetBrains Mono", "monospace"],
                    }
                }
            }
        }
    </script>
    <style>
        ::-webkit-scrollbar { width: 8px; }
        ::-webkit-scrollbar-track { background: #161B22; }
        ::-webkit-scrollbar-thumb { background: #30363d; border-radius: 4px; }
        ::-webkit-scrollbar-thumb:hover { background: #8b949e; }
    </style>
</head>
<body class="bg-main text-text-primary font-sans h-screen flex overflow-hidden selection:bg-primary/30">

    <aside class="w-16 bg-sidebar border-r border-border-dark flex flex-col items-center py-6 shrink-0 z-20">
        <div class="mb-8">
            <div class="w-10 h-10 rounded-lg bg-primary/20 flex items-center justify-center text-primary shadow-[0_0_15px_rgba(13,13,242,0.3)]">
                <span class="material-symbols-outlined text-[24px]">terminal</span>
            </div>
        </div>

        <nav class="flex flex-col gap-4 w-full px-2">
            <button class="p-3 rounded-lg bg-primary/10 text-primary border border-primary/20" title="Proyectos">
                <span class="material-symbols-outlined">folder_open</span>
            </button>
            <button class="p-3 rounded-lg text-text-secondary hover:text-white hover:bg-white/5 transition-colors" title="Búsqueda Global">
                <span class="material-symbols-outlined">search</span>
            </button>
        </nav>

        <div class="mt-auto flex flex-col gap-4 mb-4">
            <button class="p-3 rounded-lg text-text-secondary hover:text-white hover:bg-white/5 transition-colors" title="Configuración">
                <span class="material-symbols-outlined">settings</span>
            </button>
        </div>
    </aside>

    <main class="flex-1 flex flex-col min-w-0 bg-main p-8 overflow-y-auto">

        <header class="flex justify-between items-center mb-10">
            <div>
                <h1 class="text-2xl font-bold tracking-tight text-white">Mis Proyectos</h1>
                <p class="text-text-secondary text-sm mt-1">Gestión local de arquitectura</p>
            </div>
            <button class="flex items-center gap-2 bg-primary hover:bg-blue-600 text-white px-5 py-2.5 rounded-lg font-medium shadow-lg shadow-primary/20 transition-all border border-primary/50 hover:shadow-primary/40">
                <span class="material-symbols-outlined text-[20px]">add</span>
                <span>Nuevo Proyecto</span>
            </button>
        </header>

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">

            <div class="group bg-sidebar border border-border-dark rounded-xl p-5 hover:border-primary/50 transition-all cursor-pointer shadow-lg hover:shadow-xl hover:shadow-primary/5 relative overflow-hidden">
                <div class="absolute top-0 right-0 p-4 opacity-0 group-hover:opacity-100 transition-opacity">
                    <span class="material-symbols-outlined text-primary">open_in_new</span>
                </div>
                <div class="flex justify-between items-start mb-4">
                    <div class="w-10 h-10 rounded bg-blue-500/10 flex items-center justify-center text-blue-400 border border-blue-500/20">
                        <span class="material-symbols-outlined">domain</span>
                    </div>
                    <span class="px-2 py-1 rounded-full bg-green-500/10 text-green-400 text-[10px] font-mono border border-green-500/20 uppercase tracking-wide">Requisitos</span>
                </div>
                <h3 class="text-lg font-semibold text-white mb-1 group-hover:text-primary transition-colors">E-Commerce Platform</h3>
                <div class="flex items-center gap-1 text-xs text-text-secondary font-mono mb-4 truncate bg-main/50 p-1 rounded">
                    <span class="material-symbols-outlined text-[14px]">folder</span>
                    <span class="truncate">~/Dev/Clients/ShopifyKiller</span>
                </div>
                <div class="flex justify-between items-center pt-4 border-t border-border-dark/50">
                    <span class="text-xs text-text-secondary font-medium">Hace 2h</span>
                    <span class="material-symbols-outlined text-text-secondary text-[18px] group-hover:translate-x-1 transition-transform group-hover:text-white">arrow_forward</span>
                </div>
            </div>

            <div class="group bg-sidebar border border-border-dark rounded-xl p-5 hover:border-primary/50 transition-all cursor-pointer shadow-lg hover:shadow-xl hover:shadow-primary/5">
                <div class="flex justify-between items-start mb-4">
                    <div class="w-10 h-10 rounded bg-purple-500/10 flex items-center justify-center text-purple-400 border border-purple-500/20">
                        <span class="material-symbols-outlined">smartphone</span>
                    </div>
                    <span class="px-2 py-1 rounded-full bg-yellow-500/10 text-yellow-400 text-[10px] font-mono border border-yellow-500/20 uppercase tracking-wide">Contexto</span>
                </div>
                <h3 class="text-lg font-semibold text-white mb-1 group-hover:text-primary transition-colors">Uber for Dogs</h3>
                <div class="flex items-center gap-1 text-xs text-text-secondary font-mono mb-4 truncate bg-main/50 p-1 rounded">
                    <span class="material-symbols-outlined text-[14px]">folder</span>
                    <span class="truncate">~/Personal/UberDogs</span>
                </div>
                <div class="flex justify-between items-center pt-4 border-t border-border-dark/50">
                    <span class="text-xs text-text-secondary font-medium">Ayer</span>
                    <span class="material-symbols-outlined text-text-secondary text-[18px] group-hover:translate-x-1 transition-transform group-hover:text-white">arrow_forward</span>
                </div>
            </div>

        </div>
    </main>
</body>
</html>

```

---

## 2. MODAL DE CREACIÓN DE PROYECTO

El formulario para iniciar la magia.

* **🛠️ Implementación en HU:**
* **HU-3.1:** UI del diálogo, validación de inputs.
* **HU-3.2:** Lógica subyacente (botón "Examinar" llama a `file_picker`, botón "Crear" llama a `FileSystemService`).


* **📱 Widget Flutter:** `CreateProjectDialog`
* **📄 Guardar como:** `create_project_modal.html`

```html
<!DOCTYPE html>
<html class="dark" lang="es">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Modal Crear Proyecto</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0d0df2",
                        "sidebar": "#161B22",
                        "border-dark": "#30363d",
                        "input-bg": "#0D1117",
                        "text-secondary": "#8b949e",
                    },
                    fontFamily: { "sans": ["Inter", "sans-serif"] }
                }
            }
        }
    </script>
</head>
<body class="bg-gray-900/80 backdrop-blur-sm font-sans h-screen flex items-center justify-center">

    <div class="w-full max-w-lg bg-sidebar border border-border-dark rounded-xl shadow-2xl overflow-hidden ring-1 ring-white/10 animate-[fadeIn_0.2s_ease-out]">

        <div class="px-6 py-4 border-b border-border-dark flex justify-between items-center bg-[#1c2128]">
            <h2 class="text-white font-semibold text-lg flex items-center gap-2">
                <span class="material-symbols-outlined text-primary">folder_special</span> Nuevo Proyecto
            </h2>
            <button class="text-text-secondary hover:text-white transition-colors bg-white/5 hover:bg-white/10 p-1 rounded">
                <span class="material-symbols-outlined text-[20px]">close</span>
            </button>
        </div>

        <div class="p-6 space-y-6">

            <div class="space-y-2">
                <label class="block text-sm font-medium text-gray-300">Nombre del Proyecto</label>
                <input type="text" placeholder="Ej: MySuperApp" class="w-full bg-input-bg border border-border-dark rounded-lg px-4 py-2.5 text-white focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-gray-600 shadow-inner">
                <p class="text-xs text-text-secondary flex items-center gap-1">
                    <span class="material-symbols-outlined text-[14px]">info</span>
                    Solo caracteres alfanuméricos, guiones y guiones bajos.
                </p>
            </div>

            <div class="space-y-2">
                <label class="block text-sm font-medium text-gray-300">Ruta Base (Local)</label>
                <div class="flex gap-2">
                    <input type="text" value="~/Documents/SoftArchitectProjects" readonly class="flex-1 bg-input-bg border border-border-dark rounded-lg px-4 py-2.5 text-gray-400 focus:outline-none cursor-not-allowed font-mono text-sm opacity-70">
                    <button class="bg-[#21262d] hover:bg-[#30363d] border border-border-dark text-white px-4 py-2 rounded-lg text-sm font-medium transition-colors flex items-center gap-2 shadow-sm hover:border-gray-500">
                        <span class="material-symbols-outlined text-[18px]">folder_open</span>
                        Examinar...
                    </button>
                </div>
                <p class="text-xs text-text-secondary">Se creará la carpeta <code>/context</code> automáticamente.</p>
            </div>

            <div class="space-y-2">
                <label class="block text-sm font-medium text-gray-300">Descripción Corta</label>
                <textarea rows="3" placeholder="¿Qué vamos a construir hoy?" class="w-full bg-input-bg border border-border-dark rounded-lg px-4 py-2.5 text-white focus:outline-none focus:border-primary focus:ring-1 focus:ring-primary transition-all placeholder-gray-600 resize-none shadow-inner"></textarea>
            </div>

        </div>

        <div class="px-6 py-4 border-t border-border-dark bg-[#1c2128] flex justify-end gap-3">
            <button class="px-4 py-2 rounded-lg text-gray-300 hover:text-white hover:bg-white/5 transition-colors font-medium text-sm">Cancelar</button>
            <button class="px-6 py-2 rounded-lg bg-primary hover:bg-blue-600 text-white font-medium text-sm shadow-lg shadow-primary/20 transition-all flex items-center gap-2 border border-primary/50">
                <span class="material-symbols-outlined text-[18px]">rocket_launch</span>
                Crear Proyecto
            </button>
        </div>

    </div>

</body>
</html>

```

---

## 3. WORKSPACE IDE (LAYOUT COMPLETO)

El entorno de trabajo principal.

* **🛠️ Implementación en HU:**
* **HU-3.1:** Layout de 3 columnas, Header con navegación.
* **HU-3.2:** Árbol de archivos lateral (integración real con disco).
* **HU-3.3:** Contenedor central (Chat) y barra de progreso.


* **📱 Pantalla Flutter:** `ProjectWorkspaceScreen`
* **📄 Guardar como:** `workspace.html`

```html
<!DOCTYPE html>
<html class="dark" lang="es">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>SoftArchitect IDE - Workspace</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0d0df2",
                        "sidebar": "#161B22",
                        "main": "#0D1117",
                        "border-dark": "#30363d",
                        "text-primary": "#E6EDF3",
                        "text-secondary": "#8b949e",
                        "success": "#238636"
                    },
                    fontFamily: {
                        "sans": ["Inter", "sans-serif"],
                        "mono": ["Fira Code", "monospace"],
                    }
                }
            }
        }
    </script>
    <style>
        ::-webkit-scrollbar { width: 8px; height: 8px; }
        ::-webkit-scrollbar-track { background: #0D1117; }
        ::-webkit-scrollbar-thumb { background: #30363d; border-radius: 4px; border: 2px solid #0D1117; }
        ::-webkit-scrollbar-thumb:hover { background: #8b949e; }
    </style>
</head>
<body class="bg-main text-text-primary font-sans h-screen flex flex-col overflow-hidden">

    <header class="h-14 bg-sidebar border-b border-border-dark flex items-center justify-between px-4 shrink-0 z-20 shadow-md">
        <div class="flex items-center gap-4">
            <button class="text-text-secondary hover:text-white p-1 hover:bg-white/10 rounded transition-colors" title="Volver al Dashboard">
                <span class="material-symbols-outlined">arrow_back</span>
            </button>
            <div class="h-6 w-px bg-border-dark"></div>
            <div class="flex items-center gap-2">
                <h1 class="font-semibold text-sm">Uber for Dogs</h1>
                <span class="text-[10px] text-text-secondary bg-[#0D1117] px-2 py-0.5 rounded border border-border-dark font-mono">~/Personal/UberDogs</span>
            </div>
        </div>

        <div class="flex flex-col items-center w-1/3">
            <div class="flex justify-between w-full text-[10px] uppercase font-bold text-text-secondary mb-1">
                <span>Progreso de Arquitectura</span>
                <span class="text-primary">Doc 3 / 25</span>
            </div>
            <div class="w-full h-1.5 bg-[#0D1117] rounded-full overflow-hidden border border-border-dark">
                <div class="h-full bg-primary w-[12%] shadow-[0_0_10px_#0d0df2]"></div>
            </div>
        </div>

        <div class="flex items-center gap-3">
            <button class="p-2 text-text-secondary hover:text-white hover:bg-white/5 rounded-lg border border-transparent hover:border-border-dark transition-all" title="Exportar">
                <span class="material-symbols-outlined text-[20px]">download</span>
            </button>
        </div>
    </header>

    <div class="flex flex-1 overflow-hidden">

        <aside class="w-64 bg-sidebar border-r border-border-dark flex flex-col shrink-0 select-none">
            <div class="p-3 text-[11px] font-bold text-text-secondary uppercase tracking-wider flex justify-between items-center bg-[#1c2128] border-b border-border-dark">
                <span>Explorador</span>
                <span class="material-symbols-outlined text-[16px] cursor-pointer hover:text-white" title="Refrescar Árbol">refresh</span>
            </div>
            <div class="flex-1 overflow-y-auto px-2 py-2 font-mono text-[13px]">
                <div class="flex items-center gap-1 py-1 px-2 text-white bg-[#21262d] rounded cursor-pointer mb-1 border border-border-dark">
                    <span class="material-symbols-outlined text-[18px]">expand_more</span>
                    <span class="material-symbols-outlined text-[18px] text-blue-400">folder_open</span>
                    <span class="font-bold">context</span>
                </div>
                <div class="pl-3 border-l border-border-dark/30 ml-2.5 space-y-0.5">
                    <div>
                        <div class="flex items-center gap-2 py-1 px-2 text-text-secondary hover:bg-[#21262d] hover:text-white cursor-pointer rounded transition-colors">
                            <span class="material-symbols-outlined text-[16px] text-yellow-400">folder</span>
                            <span>10-CONTEXT</span>
                        </div>
                        <div class="pl-5 border-l border-border-dark/30 ml-1.5 mt-0.5">
                            <div class="flex items-center gap-2 py-1 px-2 text-white bg-[#21262d] cursor-pointer rounded border-l-2 border-primary shadow-sm">
                                <span class="material-symbols-outlined text-[16px] text-primary">description</span>
                                <span>MANIFESTO.md</span>
                            </div>
                        </div>
                    </div>
                    <div class="flex items-center gap-2 py-1 px-2 text-text-secondary hover:bg-[#21262d] hover:text-white cursor-pointer rounded transition-colors">
                        <span class="material-symbols-outlined text-[16px] text-yellow-400">folder</span>
                        <span>20-REQUIREMENTS</span>
                    </div>
                </div>
                <div class="flex items-center gap-2 py-1 px-2 text-text-secondary hover:bg-[#21262d] hover:text-white cursor-pointer rounded mt-1 ml-2">
                    <span class="material-symbols-outlined text-[16px] text-gray-400">description</span>
                    <span>README.md</span>
                </div>
            </div>
        </aside>

        <main class="flex-1 bg-main relative flex items-center justify-center border-r border-border-dark">
            <p class="text-text-secondary text-sm">[SequentialChatScreen - Ver chat_components.html]</p>
        </main>

        <aside class="w-[450px] bg-[#0D1117] border-l border-border-dark flex flex-col shrink-0 hidden lg:flex">
            <div class="h-9 bg-sidebar border-b border-border-dark flex items-center justify-between px-3">
                <span class="text-[10px] font-bold text-text-secondary uppercase tracking-wider flex items-center gap-2">
                    <span class="material-symbols-outlined text-[14px]">visibility</span>
                    Preview: PROJECT_MANIFESTO.md
                </span>
                <div class="flex gap-1">
                    <button class="p-1 text-text-secondary hover:text-white rounded hover:bg-white/5"><span class="material-symbols-outlined text-[16px]">edit</span></button>
                    <button class="p-1 text-text-secondary hover:text-white rounded hover:bg-white/5"><span class="material-symbols-outlined text-[16px]">close</span></button>
                </div>
            </div>
            <div class="flex-1 p-8 overflow-y-auto prose prose-invert prose-sm max-w-none bg-[#0D1117]">
                <h1 class="text-3xl font-bold mb-4">Project Manifesto: Uber for Dogs</h1>
                <h2 class="text-xl font-semibold mt-6 mb-3 text-white border-b border-border-dark pb-1">1. Vision</h2>
                <p class="text-gray-400 leading-relaxed">Connect dog owners with reliable walkers instantly, ensuring safety and joy for pets through a seamless mobile experience.</p>
                <h2 class="text-xl font-semibold mt-6 mb-3 text-white border-b border-border-dark pb-1">2. Core Values</h2>
                <ul class="list-disc pl-5 space-y-2 text-gray-400">
                    <li><strong class="text-white">Safety First:</strong> Verified walkers only.</li>
                    <li><strong class="text-white">Real-time Updates:</strong> GPS tracking enabled.</li>
                    <li><strong class="text-white">Simplicity:</strong> One-tap booking mechanism.</li>
                </ul>
            </div>
        </aside>

    </div>

</body>
</html>

```

---

## 4. COMPONENTES DE CHAT (UI ELEMENTS)

Los bloques interactivos dentro del chat.

* **🛠️ Implementación en HU:**
* **HU-3.3:** Burbujas de usuario, Tarjeta de Propuesta (ProposalCard).
* **HU-3.4:** Feedback de errores (Snackbar/Toast).
* **HU-3.5:** Indicadores de carga (Streaming).


* **📱 Widgets Flutter:** `ProposalCardWidget`, `UserMessageBubble`, `FeedbackBanner`
* **📄 Guardar como:** `chat_components.html`

```html
<!DOCTYPE html>
<html class="dark" lang="es">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Chat Components</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Fira+Code:wght@400;500&display=swap" rel="stylesheet"/>
    <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:wght,FILL@100..700,0..1&display=swap" rel="stylesheet"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            darkMode: "class",
            theme: {
                extend: {
                    colors: {
                        "primary": "#0d0df2",
                        "sidebar": "#161B22",
                        "main": "#0D1117",
                        "border-dark": "#30363d",
                        "text-primary": "#E6EDF3",
                        "text-secondary": "#8b949e",
                        "success": "#238636",
                        "error": "#da3633",
                        "warning": "#d29922",
                        "input-bg": "#0D1117"
                    },
                    fontFamily: {
                        "sans": ["Inter", "sans-serif"],
                        "mono": ["Fira Code", "monospace"],
                    }
                }
            }
        }
    </script>
</head>
<body class="bg-main text-text-primary font-sans min-h-screen p-10 flex justify-center bg-[url('https://www.transparenttextures.com/patterns/cubes.png')]">

    <div class="w-full max-w-3xl space-y-12">

        <h1 class="text-xl font-bold border-b border-border-dark pb-4 mb-8 text-white">Catálogo de Componentes de Chat (HU-3.3)</h1>

        <section class="space-y-2">
            <h3 class="text-[10px] font-mono text-text-secondary uppercase tracking-wider mb-4 border-l-2 border-primary pl-2">1. Widget: UserMessageBubble</h3>
            <div class="flex justify-end gap-3 group">
                <div class="bg-[#1F6FEB]/20 border border-[#1F6FEB]/30 text-white px-5 py-3.5 rounded-2xl rounded-tr-sm max-w-[85%] shadow-md group-hover:shadow-primary/10 transition-all">
                    <p class="text-[14px] leading-relaxed">Necesito crear el archivo de requisitos iniciales para el proyecto enfocándome en la seguridad.</p>
                </div>
                <div class="shrink-0 w-8 h-8 rounded-full bg-gray-800 flex items-center justify-center border border-gray-700 mt-auto mb-1 shadow-inner">
                    <span class="text-[10px] font-bold text-gray-400">YO</span>
                </div>
            </div>
        </section>

        <section class="space-y-2">
            <h3 class="text-[10px] font-mono text-text-secondary uppercase tracking-wider mb-4 border-l-2 border-primary pl-2">2. Widget: StreamingIndicator</h3>
            <div class="flex gap-3">
                <div class="shrink-0 w-8 h-8 rounded-lg bg-primary/20 flex items-center justify-center text-primary mt-1 border border-primary/20 shadow-[0_0_10px_rgba(13,13,242,0.2)]">
                    <span class="material-symbols-outlined text-[18px] animate-pulse">smart_toy</span>
                </div>
                <div class="flex items-center gap-1.5 mt-3 h-6 bg-[#161B22] px-3 rounded-full border border-border-dark">
                    <span class="w-1.5 h-1.5 bg-text-secondary rounded-full animate-[bounce_1s_infinite_0ms]"></span>
                    <span class="w-1.5 h-1.5 bg-text-secondary rounded-full animate-[bounce_1s_infinite_200ms]"></span>
                    <span class="w-1.5 h-1.5 bg-text-secondary rounded-full animate-[bounce_1s_infinite_400ms]"></span>
                    <span class="ml-2 text-xs text-text-secondary">Generando propuesta...</span>
                </div>
            </div>
        </section>

        <section class="space-y-2">
            <h3 class="text-[10px] font-mono text-text-secondary uppercase tracking-wider mb-4 border-l-2 border-primary pl-2">3. Widget: ProposalCardWidget (CRÍTICO)</h3>

            <div class="flex gap-3">
                <div class="shrink-0 w-8 h-8 rounded-lg bg-primary/20 flex items-center justify-center text-primary mt-1 border border-primary/20">
                    <span class="material-symbols-outlined text-[18px]">smart_toy</span>
                </div>

                <div class="w-full">
                    <p class="text-[14px] text-gray-300 mb-3 leading-relaxed">He analizado tu solicitud. Aquí tienes una propuesta para el archivo de requisitos maestros.</p>

                    <div class="bg-[#161B22] border border-border-dark rounded-xl overflow-hidden shadow-xl ring-1 ring-white/5">

                        <div class="px-4 py-2.5 bg-[#1c2128] border-b border-border-dark flex justify-between items-center">
                            <div class="flex items-center gap-2">
                                <span class="material-symbols-outlined text-warning text-[16px]">lightbulb</span>
                                <span class="text-xs font-mono text-text-secondary font-medium">Propuesta: <span class="text-white">20-REQUIREMENTS/REQ_MASTER.md</span></span>
                            </div>
                            <div class="flex gap-2">
                                <span class="text-[10px] text-text-secondary bg-main px-2 py-0.5 rounded border border-border-dark font-mono">Markdown</span>
                                <button class="text-text-secondary hover:text-white transition-colors" title="Copiar"><span class="material-symbols-outlined text-[16px]">content_copy</span></button>
                            </div>
                        </div>

                        <div class="p-4 bg-main font-mono text-[13px] overflow-x-auto text-gray-300 border-b border-border-dark max-h-[200px] leading-6">
<pre><span class="text-primary font-bold"># Requisitos del Sistema</span>

<span class="text-secondary font-bold">## 1. Funcionales</span>
1. El usuario debe poder loguearse con Google OAuth.
2. El sistema debe exportar reportes a PDF.
3. Validación de datos en tiempo real.

<span class="text-secondary font-bold">## 2. No Funcionales</span>
- Tiempo de respuesta < 200ms.
- Encriptación AES-256 en reposo.</pre>
                        </div>

                        <div class="px-4 py-3 bg-[#161B22] flex justify-between items-center">
                            <button class="text-xs text-error hover:text-red-400 font-medium px-3 py-1.5 rounded hover:bg-error/10 transition-colors flex items-center gap-1">
                                <span class="material-symbols-outlined text-[16px]">close</span> Rechazar
                            </button>

                            <div class="flex gap-3">
                                <button class="text-xs text-text-secondary hover:text-white font-medium px-3 py-1.5 rounded hover:bg-white/5 transition-colors border border-border-dark flex items-center gap-1 bg-[#21262d]">
                                    <span class="material-symbols-outlined text-[14px]">edit</span> Refinar
                                </button>
                                <button class="text-xs bg-success hover:bg-green-600 text-white font-medium px-4 py-1.5 rounded shadow-lg shadow-success/20 transition-all flex items-center gap-1.5 border border-success/50 transform active:scale-95">
                                    <span class="material-symbols-outlined text-[16px]">check_circle</span>
                                    Validar y Guardar
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <section class="space-y-2">
            <h3 class="text-[10px] font-mono text-text-secondary uppercase tracking-wider mb-4 border-l-2 border-primary pl-2">4. Widget: ErrorBannerWidget</h3>

            <div class="flex items-start gap-3 p-4 rounded-lg bg-error/10 border border-error/30 text-error text-sm max-w-md shadow-lg backdrop-blur-sm">
                <span class="material-symbols-outlined text-[20px] mt-0.5">error</span>
                <div class="flex flex-col gap-1">
                    <span class="font-bold">Error de Escritura en Disco</span>
                    <span class="text-xs opacity-90 leading-relaxed">No se pudo guardar el archivo. Verifica que tengas permisos de escritura en la carpeta <code>/context</code>.</span>
                </div>
                <button class="ml-auto hover:bg-error/20 rounded p-1 text-error/70 hover:text-error transition-colors"><span class="material-symbols-outlined text-[18px]">close</span></button>
            </div>
        </section>

    </div>

</body>
</html>

```

¡Todo listo! Tienes el **diseño**, la **lógica** y el **mapa de implementación**. 🚀
