# 🤖 Automatización y DevOps (Docs-as-Code)

Este documento describe los pipelines de automatización que mantienen sincronizada la documentación y el código del proyecto.

## 1. Pipeline de Sincronización de Documentación (Docs Sync)

El objetivo es mantener una "Fuente de Verdad Única" en el repositorio Git, pero publicar automáticamente el contenido en Notion para facilitar su lectura y gestión del conocimiento.

### Arquitectura del Flujo
* **Origen:** Repositorio GitHub (`main` / `develop`).
* **Orquestador:** n8n (Self-hosted en HomeLab vía CasaOS).
* **Destino:** Notion Database ("SoftArchitect Knowledge Base").

### Lógica del Workflow (n8n)
El flujo se activa mediante Webhooks y sigue un patrón "Upsert" (Update or Insert):

1.  **Trigger:** `GitHub Webhook` detecta un `push` que modifica archivos Markdown (`.md`).
2.  **Extracción:** Se descarga el contenido "raw" del archivo modificado.
3.  **Búsqueda (Look-up):** n8n consulta la Base de Datos de Notion filtrando por la propiedad personalizada **`Ruta Local`** (ej: `packages/docs/README.md`).
4.  **Decisión:**
    * **Si existe:** Obtiene el `PageID` y actualiza el contenido (bloques).
    * **Si no existe:** Crea una nueva página en la Base de Datos, asignando el título y la propiedad `Ruta Local`.

### Configuración Requerida
* **Notion Integration Token:** Token interno con permisos de lectura/escritura.
* **Database ID:** ID de la base de datos destino (Configurado en n8n como "Expression" fija).
* **Propiedades Notion:** La base de datos debe tener una propiedad de tipo texto llamada `Ruta Local`.

---

## 2. Infraestructura de Desarrollo Híbrida

### Acceso Remoto (SSH Tunneling)
Para permitir el desarrollo local utilizando la potencia del HomeLab sin exponer puertos inseguros:

* **Herramienta:** VS Code Remote - SSH.
* **Red:** Tailscale (Mesh VPN).
* **Docker:** Ejecución remota de contenedores pesados (Ollama, ChromaDB).