# 🎨 Propuestas de Mejora: HU-3.x Proyecto-First Paradigm

> **Fecha:** 02/02/2026
> **Estado:** 💡 PROPUESTAS EN REVISIÓN
> **Tipo:** Technical Deep Dive + UX Enhancements
> **Audiencia:** Architecture Review Board

---

## 📖 Tabla de Contenidos

1. [Mejoras en Diseño de UI](#-mejoras-en-diseño-de-ui)
2. [Mejoras en Arquitectura de Backend](#-mejoras-en-arquitectura-de-backend)
3. [Mejoras en Experiencia de Usuario](#-mejoras-en-experiencia-de-usuario)
4. [Mejoras en Seguridad](#-mejoras-en-seguridad)
5. [Mejoras en Pruebaing](#-mejoras-en-pruebaing)
6. [Trade-offs y Alternativas](#-trade-offs-y-alternativas)

---

## 🎨 Mejoras en Diseño de UI

### 1. Proyecto-Centric Navigation (Propuesta)

**Mejora sobre lo propuesto:**

Agregar un "Quick Access" panel que muestre:
- Documentoos completados vs. pendientes (progress bar)
- Últimas interacciones (avatar + timestamp)
- Botón rápido "Generate Siguiente Missing Doc"

**Código Concepto (Dart):**

```dart
class ProjectDashboard extends ConsumerWidget {
  final Project project;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectState = ref.watch(projectStateProvider(project.id));

    return Row(
      children: [
        // Left: Summary Panel
        ProjectSummaryPanel(
          completedDocs: projectState.completedDocuments.length,
          totalDocs: projectState.totalRequiredDocuments.length,
          progress: projectState.progress, // 0.65 = 65%
          lastModified: projectState.lastModified,
        ),

        // Center: Chat Area
        Expanded(
          child: ChatPanel(projectId: project.id),
        ),

        // Right: File Tree Live
        ProjectFileTreePanel(basePath: project.basePath),
      ],
    );
  }
}
```

**Beneficios:**
- Usuario ve en tiempo real qué documentoos faltan
- "Generate Siguiente" no requiere pregunta (IA lo sugiere automáticamente)
- Validación visual: progreso tangible

---

### 2. Documento Proposal Widget (Enhanced)

**Propuesta Mejorada:**

El widget de propuesta debe mostrar:

```
┌─────────────────────────────────────────────────────┐
│ 📄 Propuesta: VISION_AND_PROMISE.md                 │
├─────────────────────────────────────────────────────┤
│ Template: [VISION_AND_PROMISE.en.md]               │
│ Confidence: ██████░░░░ 85%                         │
│ Based on: 3 tech-pack sources                      │
├─────────────────────────────────────────────────────┤
│                                                     │
│ [Markdown Preview - Scrollable]                    │
│ # Vision and Promise                               │
│                                                     │
│ SoftArchitect AI es un asistente que...           │
│                                                     │
│ ## Principios Clave                                │
│ - Privacidad total                                 │
│ - Offline first...                                 │
│                                                     │
├─────────────────────────────────────────────────────┤
│ [Sources] [Edit] [✅ Accept] [❌ Reject]          │
└─────────────────────────────────────────────────────┘
```

**Característica Nueva: "Edit Mode"**

Permitir al usuario editar la propuesta ANTES de validar (no después).

```dart
class DocumentProposalWidget extends StatefulWidget {
  final DocumentProposal proposal;
  final Function(String) onValidate; // Persiste versión editada
  final Function(String) onReject;

  @override
  State<DocumentProposalWidget> createState() => _DocumentProposalWidgetState();
}

class _DocumentProposalWidgetState extends State<DocumentProposalWidget> {
  late TextEditingController _contentController;
  bool _isEditMode = false;

  @override
  void initState() {
    _contentController = TextEditingController(text: widget.proposal.content);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isEditMode
        ? _buildEditMode()
        : _buildPreviewMode();
  }

  Widget _buildPreviewMode() {
    return Column(
      children: [
        MarkdownBody(data: widget.proposal.content),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton.icon(
              icon: Icon(Icons.edit),
              label: Text("Edit"),
              onPressed: () => setState(() => _isEditMode = true),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.check),
              label: Text("Accept"),
              onPressed: () => widget.onValidate(_contentController.text),
            ),
            OutlinedButton.icon(
              icon: Icon(Icons.close),
              label: Text("Reject"),
              onPressed: () => widget.onReject(widget.proposal.id),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      children: [
        TextField(
          controller: _contentController,
          maxLines: null,
          decoration: InputDecoration(
            label: Text("Edit document content"),
            border: OutlineInputBorder(),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              child: Text("Cancel"),
              onPressed: () => setState(() => _isEditMode = false),
            ),
            ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text("Save & Accept"),
              onPressed: () {
                widget.onValidate(_contentController.text);
                setState(() => _isEditMode = false);
              },
            ),
          ],
        ),
      ],
    );
  }
}
```

**Beneficios:**
- Usuario puede "ajustar" propuestas sin rechazarlas completamente
- Trace de cambios: versión original ↔ versión editada
- Audit trail mostrará quién editó qué

---

### 3. Sidebar Proyecto Organization

**Mejora Propuesta:**

Agrupar proyectos por estado:

```
Proyectos Activos (2)
├─ 🟢 MyArchitecture_v1 (85% completado)
└─ 🟡 WebApp_Design (40% completado)

Archivados (3)
├─ 🔵 OldProject_2025
├─ 🔵 TestProject
└─ 🔵 PoC_Phase1

[+ Crear Nuevo Proyecto]
```

---

## 🏗️ Mejoras en Arquitectura de Backend

### 1. ProyectoMetadataService (Nueva abstracción)

**Propuesta:**

```python
# src/server/services/project/project_metadata_service.py

from typing import TypeDict
from datetime import datetime
import json

class ProjectMetadata(TypeDict):
    """Schema de .project.json"""
    id: str
    name: str
    base_path: str
    created_at: str  # ISO 8601
    updated_at: str
    version: str  # Versión de estructura de proyecto
    state: str  # "draft", "in_progress", "completed"
    completion_percentage: float
    rag_knowledge_set: str  # ID del knowledge base usado
    owner: str  # Nombre del usuario (para auditoría)

class ProjectMetadataService:
    """
    Gestiona el archivo .project.json de cada proyecto.

    Responsabilidades:
    - Leer/escribir metadata
    - Validar versión de estructura
    - Trackear estado de completitud
    - Auditoría de cambios
    """

    async def read_project_metadata(self, project_path: str) -> ProjectMetadata:
        """Lee .project.json con validación"""
        metadata_file = Path(project_path) / ".project.json"

        if not metadata_file.exists():
            raise ProjectNotFoundError(f"No metadata found: {metadata_file}")

        with open(metadata_file, "r", encoding="utf-8") as f:
            data = json.load(f)

        # Validación
        self._validate_metadata_schema(data)

        return data

    async def update_project_state(
        self,
        project_path: str,
        new_state: str,
        completion_percentage: float,
    ) -> ProjectMetadata:
        """Actualiza estado y completitud"""
        metadata = await self.read_project_metadata(project_path)

        metadata["state"] = new_state
        metadata["completion_percentage"] = completion_percentage
        metadata["updated_at"] = datetime.now().isoformat()

        await self._write_project_metadata(project_path, metadata)

        return metadata

    def _validate_metadata_schema(self, data: dict) -> None:
        """Validar que .project.json tenga campos requeridos"""
        required_fields = ["id", "name", "base_path", "created_at", "state"]
        missing = [f for f in required_fields if f not in data]

        if missing:
            raise ValidationError(f"Missing fields in .project.json: {missing}")
```

**Beneficios:**
- Metadata centralizada y validada
- Tracking de progreso automático
- Auditabilidad

---

### 2. DocumentoProposalService (Nueva capa de negocio)

**Propuesta:**

```python
# src/server/services/project/document_proposal_service.py

from core.exceptions.base import ValidationError
from services.rag.vector_store import VectorStoreService

class DocumentProposalService:
    """
    Orquesta la creación y validación de propuestas de documentos.

    Flujo:
    1. Recibir input del usuario
    2. Consultar RAG con contexto de proyecto
    3. Generar propuesta (template + contenido)
    4. Retornar al frontend para validación
    """

    def __init__(
        self,
        vector_store: VectorStoreService,
        llm_service: "LLMService",
        project_metadata_service: ProjectMetadataService,
    ):
        self.vector_store = vector_store
        self.llm_service = llm_service
        self.project_metadata_service = project_metadata_service

    async def generate_document_proposal(
        self,
        project_id: str,
        document_type: str,
        user_context: str,  # "I want a VISION document for a mobile app"
    ) -> DocumentProposal:
        """
        Generar propuesta de documento basada en RAG + LLM.

        Flujo:
        1. Buscar en RAG: template del documento_type
        2. Buscar en RAG: contexto relevante del proyecto
        3. Llamar LLM con sistema prompt + contexto
        4. Retornar propuesta con sources
        """

        # 1. Obtener template del RAG
        template_chunks = await self.vector_store.query(
            query_text=f"template for {document_type}",
            n_results=1,
            collection_name="templates"
        )

        if not template_chunks.get("documents"):
            raise ValidationError(f"No template found for {document_type}")

        template = template_chunks["documents"][0]

        # 2. Obtener contexto relevante
        context_chunks = await self.vector_store.query(
            query_text=user_context,
            n_results=5,
            collection_name="tech_packs"
        )

        sources = context_chunks.get("ids", [])
        relevant_context = "\n".join(context_chunks.get("documents", []))

        # 3. Llamar LLM
        prompt = f"""
        Based on the following template and context, generate a {document_type} document.

        Template:
        {template}

        Context:
        {relevant_context}

        User Request:
        {user_context}

        Generate only the document content (Markdown format). Do not include template markers.
        """

        generated_content = await self.llm_service.generate(
            prompt=prompt,
            temperature=0.7,
            max_tokens=2000,
        )

        # 4. Retornar propuesta
        proposal = DocumentProposal(
            id=generate_id(),
            document_type=document_type,
            content=generated_content,
            template_id=template_chunks["ids"][0],
            sources=sources,
            confidence=0.85,  # Placeholder; podría calcularse
            status="proposed",
        )

        return proposal
```

**Beneficios:**
- Separación clara entre generación y persistencia
- Rastreo de sources (para credibilidad)
- Reutilizable desde diferentes endpoints

---

### 3. Endpoint Mejorado: `/api/v1/proyectos/{id}/chat/stream`

**Propuesta:**

```python
# src/server/api/v1/endpoints/projects.py

from fastapi import APIRouter, HTTPException, Path
from fastapi.responses import StreamingResponse

router = APIRouter(prefix="/projects", tags=["projects"])

@router.post("/{project_id}/chat/stream")
async def chat_with_project_stream(
    project_id: str = Path(..., description="Project ID"),
    message: str,
    document_type: Optional[str] = None,  # Si es None → conversación; si es string → propuesta
) -> StreamingResponse:
    """
    Endpoint de chat con soporte para propuestas de documentos.

    Modos:
    1. document_type=None → Conversación normal (streaming)
    2. document_type="VISION" → Propuesta de documento + sources

    Retorna: SSE stream
    ```
    data: {"type": "text", "content": "Lorem ipsum..."}
    data: {"type": "documento_proposal", "proposal": {...}}
    ```
    """

    try:
        # Validar que proyecto existe
        project = await project_service.get_project(project_id)

        # Determinar modo
        if document_type:
            # Modo: generar propuesta
            async def generate():
                proposal = await document_proposal_service.generate_document_proposal(
                    project_id=project_id,
                    document_type=document_type,
                    user_context=message,
                )

                # Retornar propuesta completa
                yield f"data: {json.dumps({'type': 'document_proposal', 'proposal': proposal.dict()})}\n\n"
        else:
            # Modo: conversación normal (streaming)
            async def generate():
                async for chunk in chat_service.chat_stream(
                    project_id=project_id,
                    message=message,
                ):
                    yield f"data: {json.dumps({'type': 'text', 'content': chunk})}\n\n"

        return StreamingResponse(
            generate(),
            media_type="text/event-stream",
            headers={
                "Cache-Control": "no-cache",
                "Connection": "keep-alive",
            }
        )

    except ProjectNotFoundError:
        raise HTTPException(status_code=404, detail="Project not found")
    except Exception as e:
        logger.error(f"Stream error: {e}")
        raise HTTPException(status_code=500, detail="Internal server error")

@router.post("/{project_id}/document/validate")
async def validate_and_save_document(
    project_id: str = Path(...),
    proposal_id: str,
    content: Optional[str] = None,  # Versión editada por usuario (si aplica)
) -> DocumentSaveResult:
    """
    Persistir un documento propuesto tras validación.

    Flujo:
    1. Obtener propuesta del histórico (en memoria o BD)
    2. Usar contenido editado (si existe) o contenido original
    3. Llamar FileSystemService para guardar
    4. Actualizar metadata del proyecto
    5. Retornar confirmación
    """

    try:
        # Obtener propuesta
        proposal = await chat_service.get_proposal(proposal_id)

        if not proposal:
            raise ValidationError(f"Proposal not found: {proposal_id}")

        # Usar contenido editado o original
        final_content = content or proposal.content

        # Persistir
        result = await filesystem_service.write_validated_document(
            project_path=project.base_path,
            document_type=proposal.document_type,
            content=final_content,
            metadata={
                "proposal_id": proposal_id,
                "sources": proposal.sources,
                "edited_by_user": content is not None,
            },
        )

        # Actualizar proyecto state
        await project_metadata_service.update_project_state(
            project_path=project.base_path,
            new_state="in_progress",
            completion_percentage=await calculate_completion(project.id),
        )

        return DocumentSaveResult(
            status="success",
            file_path=result.file_path,
            message=f"Document saved: {result.file_path}",
        )

    except Exception as e:
        logger.error(f"Validation error: {e}")
        raise HTTPException(status_code=400, detail=str(e))
```

---

## 🎯 Mejoras en Experiencia de Usuario

### 1. "Proyecto Wizard" (Onboarding Mejorado)

**Propuesta:**

En lugar de un modal simple, un asistente paso a paso:

```
Step 1: "¿Cuál es tu rol?"
├─ Arquitecto de Software
├─ Tech Lead
├─ Full-Stack Developer
└─ Otro

Step 2: "¿Cuál es tu proyecto?"
├─ Microservicios
├─ Web App
├─ Mobile App
└─ Infraestructura

Step 3: "¿Dónde guardar?"
└─ [File Picker]

Step 4: "Configuración de IA"
├─ Local (Ollama): Privacidad total
└─ Cloud (Groq): Más rápido
```

Resultadoado: proyecto pre-poblado con ciertos documentoos sugeridos.

---

### 2. "Documento Generation Timeline"

**Propuesta:**

Una vista tipo "checklist" que muestre:

```
📋 Documentos del Proyecto

Fase 1: Definición
├─ [✅] VISION_AND_PROMISE.md (Completado hace 2 horas)
├─ [⏳] USER_JOURNEY_MAP.md (En revisión)
└─ [❌] REQUIREMENTS_ANALYSIS.md (Pendiente)

Fase 2: Diseño
├─ [❌] ARCHITECTURE.md (Bloqueado por Fase 1)
├─ [❌] DESIGN_SYSTEM.md
└─ [❌] ERROR_HANDLING_STANDARD.md

Fase 3: Implementación
├─ [❌] API_INTERFACE_CONTRACT.md
├─ [❌] SECURITY_HARDENING_POLICY.md
└─ [❌] TESTING_STRATEGY.md

[🚀 Generate Next Doc]  [💾 Save All]
```

**Beneficios:**
- Usuario ve dependencias entre documentoos
- Puede generar en orden recomendado
- Motivación (progreso visible)

---

## 🔒 Mejoras en Seguridad

### 1. Path Validation & Sandbox

**Propuesta:**

```python
# src/server/services/filesystem/path_validator.py

import os
from pathlib import Path
from typing import Tuple

class PathValidator:
    """Validar que paths no salgan del proyecto sandbox"""

    @staticmethod
    def is_safe_path(
        project_base: str,
        target_path: str,
    ) -> Tuple[bool, Optional[str]]:
        """
        Validar que target_path está dentro de project_base.

        Returns:
            (is_safe, error_message)
        """

        # Resolver paths absolutos
        base = Path(project_base).resolve()
        target = Path(target_path).resolve()

        # Verificar que target está dentro de base
        try:
            target.relative_to(base)
            return True, None
        except ValueError:
            return False, f"Path escape detected: {target_path}"

    @staticmethod
    def sanitize_filename(filename: str) -> str:
        """Sanitizar nombre de archivo"""
        # Remover caracteres peligrosos
        unsafe_chars = "<>:\"/\\|?*"
        for char in unsafe_chars:
            filename = filename.replace(char, "_")

        # Remover leading/trailing dots (Windows)
        filename = filename.strip(". ")

        # Evitar reserved names (Windows)
        reserved = ["CON", "PRN", "AUX", "NUL"]
        if filename.upper() in reserved:
            filename = f"_{filename}"

        return filename
```

### 2. Permissions Check

**Propuesta:**

```python
# Antes de escribir, validar permisos

async def write_validated_document(self, project_path: str, ...) -> FileWriteResult:
    """
    Escribir documento con checks de seguridad.
    """

    # 1. Validar path
    is_safe, error = PathValidator.is_safe_path(
        project_base=project_path,
        target_path=f"{project_path}/context/DOCUMENT.md"
    )

    if not is_safe:
        raise SecurityError(f"Path validation failed: {error}")

    # 2. Validar permisos de escritura
    context_dir = Path(project_path) / "context"

    if not os.access(context_dir, os.W_OK):
        raise PermissionError(f"No write permission: {context_dir}")

    # 3. Crear backup
    target_file = context_dir / "DOCUMENT.md"
    if target_file.exists():
        backup_file = context_dir / f"DOCUMENT.md.bak.{datetime.now().isoformat()}"
        shutil.copy2(target_file, backup_file)

    # 4. Escribir
    with open(target_file, "w", encoding="utf-8") as f:
        f.write(content)

    return FileWriteResult(
        status="success",
        file_path=str(target_file),
        backup_path=str(backup_file) if target_file.exists() else None,
    )
```

---

## 🧪 Mejoras en Pruebaing

### 1. Prueba Strategy para ArchivoSystemService

**Propuesta:**

```python
# src/server/tests/unit/services/filesystem/test_file_system_service.py

import pytest
from pathlib import Path
from unittest.mock import patch, MagicMock

class TestFileSystemService:
    """
    Unit tests para FileSystemService.

    Usar pytest.tmp_path para aislamiento.
    """

    @pytest.fixture
    def file_service(self):
        """Instancia del servicio"""
        return FileSystemService()

    @pytest.fixture
    def temp_project(self, tmp_path):
        """Proyecto temporal para tests"""
        project_dir = tmp_path / "test_project"
        project_dir.mkdir()
        return project_dir

    @pytest.mark.asyncio
    async def test_create_project_creates_correct_structure(
        self,
        file_service,
        temp_project
    ):
        """✅ Crear proyecto crea estructura base"""

        result = await file_service.create_project(
            project_name="TestProject",
            base_path=str(temp_project),
        )

        assert result.status == "success"
        assert (temp_project / "context").exists()
        assert (temp_project / ".project.json").exists()

    @pytest.mark.asyncio
    async def test_write_document_creates_backup(
        self,
        file_service,
        temp_project
    ):
        """✅ Escribir documento crea backup de versión anterior"""

        context_dir = temp_project / "context"
        context_dir.mkdir()

        # Primera escritura
        result1 = await file_service.write_validated_document(
            project_path=str(temp_project),
            document_type="VISION",
            content="Version 1",
        )

        assert result1.status == "success"

        # Segunda escritura (debe crear backup)
        result2 = await file_service.write_validated_document(
            project_path=str(temp_project),
            document_type="VISION",
            content="Version 2",
        )

        assert result2.status == "success"
        assert result2.backup_path is not None
        assert Path(result2.backup_path).exists()

    @pytest.mark.asyncio
    async def test_path_traversal_attack_prevented(
        self,
        file_service,
        temp_project
    ):
        """❌ Intentar path traversal falla"""

        with pytest.raises(SecurityError, match="Path escape"):
            await file_service.write_validated_document(
                project_path=str(temp_project),
                document_type="../../etc/passwd",
                content="hacked",
            )

    @pytest.mark.asyncio
    async def test_permission_denied_handled_gracefully(
        self,
        file_service,
        temp_project
    ):
        """❌ Sin permisos de escritura → error legible"""

        context_dir = temp_project / "context"
        context_dir.mkdir()

        # Remover permisos
        context_dir.chmod(0o444)  # Read-only

        with pytest.raises(PermissionError):
            await file_service.write_validated_document(
                project_path=str(temp_project),
                document_type="VISION",
                content="test",
            )

        # Restaurar permisos para cleanup
        context_dir.chmod(0o755)
```

### 2. Integración Pruebas

**Propuesta:**

```python
# src/server/tests/integration/test_project_workflow.py

@pytest.mark.asyncio
async def test_full_project_workflow(
    async_client,  # FastAPI test client
    temp_project_dir,
):
    """
    Test end-to-end: Create project → Chat → Generate doc → Validate → Persist
    """

    # 1. Crear proyecto
    response = await async_client.post(
        "/api/v1/projects",
        json={"name": "TestArch", "base_path": str(temp_project_dir)},
    )
    assert response.status_code == 201
    project_id = response.json()["id"]

    # 2. Chat: pedir propuesta de documento
    response = await async_client.post(
        f"/api/v1/projects/{project_id}/chat/stream",
        json={
            "message": "Create a VISION document",
            "document_type": "VISION",
        },
    )
    assert response.status_code == 200

    # Parsear SSE stream
    proposal_data = None
    async for line in response.aiter_lines():
        if line.startswith("data: "):
            data = json.loads(line[6:])
            if data.get("type") == "document_proposal":
                proposal_data = data["proposal"]
                break

    assert proposal_data is not None
    proposal_id = proposal_data["id"]

    # 3. Validar y guardar
    response = await async_client.post(
        f"/api/v1/projects/{project_id}/document/validate",
        json={"proposal_id": proposal_id},
    )
    assert response.status_code == 200

    # 4. Verificar que archivo fue guardado
    vision_file = temp_project_dir / "context" / "VISION.md"
    assert vision_file.exists()
    assert len(vision_file.read_text()) > 0
```

---

## ⚖️ Trade-offs y Alternativas

### Trade-off 1: Edit Mode vs. Reject & Regenerate

**Opción A (Propuesta):** Edit Mode
- ✅ Usuario controla el contenido
- ✅ Una sola propuesta → validación → guardar
- ❌ Más complejo de implementar (double state)

**Opción B (Alternativa):** Reject & Regenerate
- ✅ Más simple
- ✅ Usuario puede "reroll" propuestas
- ❌ Menos control (tiene que rechazar y esperar)

**Recomendación:** Opción A (Edit Mode) es mejor UX.

---

### Trade-off 2: ArchivoSystemService vs. DatabaseCentric

**Opción A (Propuesta):** Archivo system como source of truth
- ✅ Usuario ve archivos en su carpeta (tangible)
- ✅ Compatible con Git (fácil versionado)
- ✅ Portable (mover carpeta = mover proyecto)
- ❌ Más complejo de manejar permisos

**Opción B (Alternativa):** SQLite como source of truth
- ✅ Más simple de gestionar
- ✅ Queries más rápidas
- ❌ Usuario nunca ve los "documentoos reales"
- ❌ Acoplamiento a BD

**Recomendación:** Opción A (Archivo system) alineado con visión "local-first".

---

### Trade-off 3: Estimación: 70 pts vs. 50 pts

**Opción A (Propuesta):** 70 pts (descomposición en 5 HUs)
- ✅ Más realista
- ✅ Más pruebaeable
- ❌ Añade "overhead" (más HUs = más PR reviews)

**Opción B (Alternativa):** 50 pts (mantener 3 HUs)
- ✅ Menos HUs = menos overhead
- ❌ Subestimación probable
- ❌ Descubrimiento de complejidad mid-sprint

**Recomendación:** Opción A (70 pts) para evitar sorpresas.

---

## 📊 Summary de Mejoras Propuestas

| Mejora | Complejidad | Impacto | Prioridad |
|--------|-------------|--------|-----------|
| **Edit Mode** | Medio | Alto | 1 |
| **ProyectoMetadataService** | Medio | Medio | 2 |
| **DocumentoProposalService** | Bajo | Alto | 1 |
| **Proyecto Wizard** | Bajo | Bajo | 3 |
| **Timeline Checklist** | Bajo | Medio | 2 |
| **Path Validation** | Bajo | Alto | 1 |
| **Comprehensive Pruebas** | Medio | Alto | 1 |

---

## ✅ Recomendaciones Finales

1. **Implementar Opción B (5 HUs)** con estimación 70 pts
2. **Agregar Edit Mode** a HU-3.3 (impacto alto, no mucho overhead)
3. **Crear DocumentoProposalService** como arquitectura limpia (Use Case)
4. **Inversión en Pruebas** desde day 1 (especialmente ArchivoSystemService)
5. **Path Validation** es crítica (seguridad del usuario)

---

**Documentoo preparado para integración en decisiones arquitectónicas.**
