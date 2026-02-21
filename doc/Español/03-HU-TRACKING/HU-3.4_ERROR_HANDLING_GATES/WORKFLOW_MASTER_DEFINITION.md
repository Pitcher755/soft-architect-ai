# 🏗️ WORKFLOW MAESTRO: HU-3.4 - Manejo de Errores y Gates de Validación

> **Fecha:** 09/02/2026
> **Rama:** `feature/error-handling-gates`
> **Epic:** E3 - UX Frontend & Robustez
> **Prioridad:** 🔥 **ALTA**
> **Metodología:** TDD Estricto (Rojo → Verde → Refactorizar)
> **Nivel de Riesgo:** ALTO (Ruta crítica para readiness de producción)

---

## 📖 Tabla de Contenidos

1. [Objetivos Estratégicos](#objetivos-estratégicos)
2. [Criterios de Aceptación (Definition of Done)](#criterios-de-aceptación-definition-of-done)
3. [Arquitectura y Dependencias](#arquitectura-y-dependencias)
4. [Fase 0: Preparación del Terreno](#fase-0-preparación-del-terreno)
5. [Fase 1: TDD - ROJO (Pruebas que Fallan)](#fase-1-tdd---rojo-pruebas-que-fallan)
6. [Fase 2: TDD - VERDE (Implementación)](#fase-2-tdd---verde-implementación)
7. [Fase 3: TDD - REFACTOR (Mejoras y Robustez)](#fase-3-tdd---refactor-mejoras-y-robustez)
8. [Fase 4: Pruebaing de Integración (E2E)](#fase-4-pruebaing-de-integración-e2e)
9. [Fase 5: Documentoación y Validación](#fase-5-documentoación-y-validación)
10. [Fase 6: CI/CD y Pipeline](#fase-6-cicd-y-pipeline)
11. [Entregables Finales](#entregables-finales)

---

## 🎯 Objetivos Estratégicos

### 1. **Gates de Validación (Aseguramiento de Calidad de Datos)**
- Implementar validadores para **contenido de documentoos** (longitud mínima, estructura, codificación).
- Rechazar documentoos inválidos **antes** del almacenamiento con códigos de error específicos (`VAL_001`, `VAL_002`, `VAL_003`).
- Prevenir que datos corruptos entren a ChromaDB o SQLite.
- **Cumple:** Integridad de datos, aseguramiento de calidad.

### 2. **Lógica de Reintento con Backoff Exponencial**
- Implementar decorador `@with_retry` para operaciones críticas (consultas ChromaDB, llamadas LLM).
- **Máximo 3 reintentos** con backoff exponencial (1s, 2s, 4s).
- Registrar cada intento de reintento con contexto (operación, número de intento, delay).
- **Cumple:** Resiliencia, recuperación de fallos transitorios.

### 3. **Lógica de Fallback y Rollback**
- Si la generación de documentoos falla después de 3 reintentos → rollback al último estado válido.
- Proporcionar al usuario opción de **"Restaurar Versión Anterior"**.
- Almacenar historial de documentoos (máx 5 versiones) en SQLite para capacidad de rollback.
- **Cumple:** Seguridad del usuario, recuperación de datos.

### 4. **Notificaciones Optimizadas para UX**
- **Snackbars de Éxito/Info:** Auto-ocultar después de 5 segundos.
- **Snackbars de Error:** Requieren cierre manual (sin auto-ocultar).
- **Errores Accionables:** Incluir botón de reintentar directamente en la notificación.
- **Mensajes Localizados:** Todos los mensajes en español (es-ES).
- **Cumple:** UI optimista, empoderamiento del usuario.

### 5. **Registro Comprehensivo de Errores**
- Registrar todos los errores con contexto: `operation`, `timestamp`, `user_id`, `error_code`.
- **Nunca registrar datos sensibles** (claves API, contenidos de archivos).
- Almacenar logs en `app.log` (local) y consola Docker.
- **Cumple:** Debugging, audit trail, cumplimiento OWASP.

### 6. **Mapeo de Códigos de Error (User-Friendly)**
- Mapear errores técnicos a mensajes en español:
  - `SYS_001` → "No hay conexión con el servidor local"
  - `VAL_001` → "El documentoo generado es inválido"
  - `RAG_001` → "La base de conocimiento está vacía"
- **Sin stack traces** visibles a usuarios (solo en logs).
- **Cumple:** Experiencia de usuario, privacidad.

---

## ✅ Criterios de Aceptación (Definition of Done)

### Criterios POSITIVOS (Debe Tener)
- ✅ **Gates de Validación:** Documentoos validados por longitud (>50 chars), estructura (Markdown válido), codificación (UTF-8).
- ✅ **Lógica de Reintento:** Operaciones fallidas reintentan automáticamente (máx 3x con backoff exponencial).
- ✅ **Fallback:** Si la generación falla, el usuario puede restaurar la versión anterior del documentoo.
- ✅ **UX Snackbar:** Éxito/info auto-ocultar en 5s, errores requieren cierre manual.
- ✅ **Logging de Errores:** Todos los errores registrados con contexto (sin datos sensibles expuestos).
- ✅ **Errores Localizados:** Todos los mensajes de error en español, sin jerga técnica.
- ✅ **Cobertura de Pruebas:** >90% en gates de validación y lógica de reintentos.
- ✅ **Integración:** Funciona perfectamente con HU-3.3 (Chat Sequential Docs).

### Criterios NEGATIVOS (No Debe)
- ❌ **Sin Stack Traces:** Los usuarios nunca ven stack traces de Python/Dart.
- ❌ **Sin Mensajes Hardcoded:** Todos los mensajes provienen del catálogo centralizado de errores.
- ❌ **Sin Datos Sensibles en Logs:** Claves API, datos de usuario excluidos de logs.
- ❌ **Sin Auto-Ocultar para Errores:** Errores críticos requieren reconocimiento del usuario.
- ❌ **Sin Loops de Reintento:** Después de 3 reintentos, fallar gracefully con mensaje accionable.

---

## 🏗️ Arquitectura y Dependencias

```
┌─────────────────────────────────────────────────────────────────┐
│                    ESTRUCTURA DE CAPAS                           │
├─────────────────────────────────────────────────────────────────┤
│ CAPA DE PRESENTACIÓN (Flutter)                                  │
│   ├─ lib/core/error_handling/error_mapper.dart                  │
│   ├─ lib/core/error_handling/snackbar_service.dart              │
│   └─ lib/features/chat/presentation/notifiers/chat_notifier.dart│
├─────────────────────────────────────────────────────────────────┤
│ CAPA DE APLICACIÓN (Servicios Backend)                          │
│   ├─ src/server/app/services/validators/gates.py                │
│   ├─ src/server/app/services/validators/document_validator.py   │
│   ├─ src/server/app/core/retry.py (decorador @with_retry)       │
│   └─ src/server/app/services/rag/sequential_orchestrator.py     │
├─────────────────────────────────────────────────────────────────┤
│ CAPA DE DOMINIO (Excepciones Core)                              │
│   ├─ src/server/app/core/exceptions.py (ValidationError)        │
│   └─ lib/core/exceptions/validation_exception.dart              │
├─────────────────────────────────────────────────────────────────┤
│ CAPA DE DATOS (Persistencia)                                    │
│   ├─ SQLite: tabla document_versions (capacidad de rollback)    │
│   └─ Logs: app.log (logging estructurado JSON)                  │
├─────────────────────────────────────────────────────────────────┤
│ CONFIGURACIÓN                                                   │
│   ├─ context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md         │
│   └─ src/server/app/core/config.py (settings de retry)          │
└─────────────────────────────────────────────────────────────────┘
```

### Dependencias (Bloqueado Por)
- **HU-3.3:** Chat Sequential Docs (debe estar mergeado primero)
- **ERROR_HANDLING_STANDARD.md:** Debe existir en context/30-ARCHITECTURE/

### Bloquea (Downstream)
- **HU-3.5:** Streaming Optimization (requiere manejo robusto de errores)

---

## 🔧 Fase 0: Preparación del Terreno

**Objetivo:** Analizar manejo de errores existente, definir reglas de validación y preparar infraestructura de pruebas.

### 0.1 Auditoría de Documentoación
```bash
# Leer docs de manejo de errores existentes
cat context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md
cat context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.es.md

# Analizar manejo de excepciones actual
rg "raise.*Error" src/server/app/ -A 2
rg "Exception" src/client/lib/ -A 2
```

**Entregable:** Inventario de errores existentes y gaps.

### 0.2 Definir Reglas de Validación
Crear documentoo de especificación de validación:

**Archivo:** `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md`

```markdown
# Especificación de Reglas de Validación

## Validación de Contenido de Documentos
1. **VAL_001:** Longitud Mínima (>50 chars)
2. **VAL_002:** Estructura Markdown Válida
3. **VAL_003:** Codificación UTF-8
4. **VAL_004:** Sin Código Malicioso (patrones XSS)
5. **VAL_005:** Tamaño Máximo (<5MB)

## Reglas de Reintento
1. Reintentos máximos: 3
2. Delay base: 1.0s
3. Multiplicador de backoff: 2.0x
4. Delay máximo: 8.0s
```

### 0.3 Configurar Infraestructura de Pruebas
```bash
# Crear directorios de tests
mkdir -p tests/python/unit/services/validators
mkdir -p tests/test/unit/core/error_handling

# Agregar fixtures de tests
touch tests/python/fixtures/invalid_documents.json
touch tests/python/fixtures/valid_documents.json
```

**Checklist Fase 0:**
- [ ] ERROR_HANDLING_STANDARD.md revisado
- [ ] VALIDATION_RULES.md creado
- [ ] Directorios de pruebas creados
- [ ] Fixtures preparados

---

## 🔴 Fase 1: TDD - ROJO (Pruebas que Fallan)

**Objetivo:** Escribir pruebas comprehensivos que FALLEN (sin implementación todavía).

### 1.1 Backend: Pruebas de Gates de Validación

**Archivo:** `pruebas/python/unit/services/validators/prueba_documento_validator.py`

```python
import pytest
from app.services.validators.document_validator import DocumentValidator
from app.core.exceptions import ValidationError


class TestDocumentValidator:
    """Suite de tests para gates de validación de documentos."""

    def test_validate_minimum_length_fails_with_short_content(self):
        """VAL_001: Debe rechazar documentos más cortos de 50 chars."""
        validator = DocumentValidator()
        short_content = "Muy corto"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_content(short_content)

        assert exc_info.value.code == "VAL_001"
        assert "mínimo 50 caracteres" in exc_info.value.message

    def test_validate_markdown_structure_fails_with_invalid_markdown(self):
        """VAL_002: Debe rechazar documentos con Markdown roto."""
        validator = DocumentValidator()
        invalid_md = "# Encabezado sin cerrar [link](roto"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_markdown(invalid_md)

        assert exc_info.value.code == "VAL_002"

    def test_validate_encoding_fails_with_non_utf8(self):
        """VAL_003: Debe rechazar contenido no codificado en UTF-8."""
        validator = DocumentValidator()
        # Simular error de codificación Latin-1
        invalid_bytes = b"\xff\xfe UTF-8 Inválido"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_encoding(invalid_bytes)

        assert exc_info.value.code == "VAL_003"

    def test_validate_xss_patterns_fails_with_malicious_code(self):
        """VAL_004: Debe detectar y rechazar patrones XSS."""
        validator = DocumentValidator()
        malicious_content = "<script>alert('XSS')</script>"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_safety(malicious_content)

        assert exc_info.value.code == "VAL_004"

    def test_validate_size_fails_with_oversized_content(self):
        """VAL_005: Debe rechazar documentos mayores a 5MB."""
        validator = DocumentValidator()
        huge_content = "x" * (5 * 1024 * 1024 + 1)  # 5MB + 1 byte

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_size(huge_content)

        assert exc_info.value.code == "VAL_005"

    def test_validate_all_passes_with_valid_document(self):
        """Debe pasar validación con contenido válido."""
        validator = DocumentValidator()
        valid_content = "# Documento Válido\n\nEste es un documento Markdown válido con longitud suficiente."

        result = validator.validate_all(valid_content)

        assert result is True
```

**Resultadoado Esperado:** ❌ Todos los pruebas FALLAN (clases/métodos no existen todavía).

### 1.2 Backend: Pruebas de Lógica de Reintento

**Archivo:** `pruebas/python/unit/core/prueba_retry.py`

```python
import pytest
from unittest.mock import Mock, patch
from app.core.retry import with_retry
from app.core.exceptions import RetryExhaustedError


class TestRetryDecorator:
    """Suite de tests para decorador @with_retry."""

    def test_retry_succeeds_on_first_attempt(self):
        """Debe ejecutarse exitosamente sin reintentos."""
        mock_func = Mock(return_value="éxito")
        decorated = with_retry(max_retries=3)(mock_func)

        result = decorated()

        assert result == "éxito"
        assert mock_func.call_count == 1

    def test_retry_succeeds_on_second_attempt(self):
        """Debe reintentar una vez y tener éxito."""
        mock_func = Mock(side_effect=[ConnectionError(), "éxito"])
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        result = decorated()

        assert result == "éxito"
        assert mock_func.call_count == 2

    def test_retry_exhausted_after_max_attempts(self):
        """Debe lanzar RetryExhaustedError después de 3 intentos fallidos."""
        mock_func = Mock(side_effect=ConnectionError("Fallo persistente"))
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        with pytest.raises(RetryExhaustedError) as exc_info:
            decorated()

        assert mock_func.call_count == 3
        assert "Fallo persistente" in str(exc_info.value)

    def test_retry_exponential_backoff_timing(self):
        """Debe aplicar backoff exponencial (1s, 2s, 4s)."""
        mock_func = Mock(side_effect=[ConnectionError(), ConnectionError(), "éxito"])
        decorated = with_retry(max_retries=3, base_delay=1.0)(mock_func)

        with patch('time.sleep') as mock_sleep:
            result = decorated()

            assert result == "éxito"
            assert mock_sleep.call_count == 2
            mock_sleep.assert_any_call(1.0)  # Primer reintento
            mock_sleep.assert_any_call(2.0)  # Segundo reintento

    def test_retry_logs_each_attempt(self, caplog):
        """Debe registrar cada intento de reintento con contexto."""
        mock_func = Mock(side_effect=[ConnectionError(), "éxito"])
        mock_func.__name__ = "operacion_test"
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        decorated()

        assert "Reintento 1/3 para operacion_test" in caplog.text
```

**Resultadoado Esperado:** ❌ Todos los pruebas FALLAN (`with_retry` no existe todavía).

### 1.3 Frontend: Pruebas de Error Mapper

**Archivo:** `pruebas/prueba/unit/core/error_handling/error_mapper_prueba.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soft_architect_ai/core/error_handling/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    late ErrorMapper errorMapper;

    setUp(() {
      errorMapper = ErrorMapper();
    });

    test('debe mapear SYS_001 a mensaje en español', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('servidor local'));
      expect(message, isNot(contains('ConnectionRefusedError')));
    });

    test('debe mapear VAL_001 a mensaje de validación en español', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('documento'));
      expect(message, contains('inválido'));
    });

    test('debe proporcionar mensaje genérico para código de error desconocido', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('error'));
      expect(message, contains(errorCode));
    });

    test('debe proporcionar sugerencia accionable para cada error', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final suggestion = errorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Docker'));
    });
  });
}
```

**Resultadoado Esperado:** ❌ Todos los pruebas FALLAN (clase ErrorMapper no existe).

### 1.4 Ejecutar Todos los Pruebas ROJOS

```bash
# Tests backend (Python)
cd tests/python && pytest unit/services/validators/ unit/core/ -v

# Tests frontend (Dart)
cd tests && flutter test test/unit/core/error_handling/

# Salida Esperada: TODO ROJO (100% tasa de fallo)
```

**Checklist Fase 1:**
- [ ] 5+ pruebas de validación backend escritos (todos fallando)
- [ ] 4+ pruebas de reintento backend escritos (todos fallando)
- [ ] 3+ pruebas de error mapper frontend escritos (todos fallando)
- [ ] 3+ pruebas de snackbar frontend escritos (todos fallando)
- [ ] Todos los pruebas documentoados con docstrings
- [ ] Objetivo de cobertura de pruebas: >90%

---

## 🟢 Fase 2: TDD - VERDE (Implementación)

**Objetivo:** Implementar código MÍNIMO para hacer pasar los pruebas (sin optimización todavía).

### 2.1 Backend: Implementación de Gates de Validación

**Archivo:** `src/server/app/services/validators/documento_validator.py`

```python
"""Gates de validación de documentos para aseguramiento de calidad de contenido."""
import re
from typing import Final

from app.core.exceptions import ValidationError


class DocumentValidator:
    """Valida contenido de documentos contra gates de calidad."""

    MIN_LENGTH: Final[int] = 50
    MAX_SIZE_BYTES: Final[int] = 5 * 1024 * 1024  # 5MB
    XSS_PATTERNS: Final[list[str]] = [
        r"<script.*?>.*?</script>",
        r"javascript:",
        r"onerror\s*=",
        r"onload\s*=",
    ]

    def validate_content(self, content: str) -> bool:
        """Validar longitud mínima del contenido (VAL_001)."""
        if len(content) < self.MIN_LENGTH:
            raise ValidationError(
                code="VAL_001",
                message=f"El documento debe tener al menos {self.MIN_LENGTH} caracteres",
                operation="validate_content",
            )
        return True

    def validate_markdown(self, content: str) -> bool:
        """Validar estructura de Markdown (VAL_002)."""
        # Verificar corchetes/paréntesis sin cerrar
        if content.count('[') != content.count(']'):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (corchetes sin cerrar)",
                operation="validate_markdown",
            )
        if content.count('(') != content.count(')'):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (paréntesis sin cerrar)",
                operation="validate_markdown",
            )
        return True

    def validate_encoding(self, content: bytes) -> bool:
        """Validar codificación UTF-8 (VAL_003)."""
        try:
            content.decode('utf-8')
        except UnicodeDecodeError as e:
            raise ValidationError(
                code="VAL_003",
                message="El documento no está codificado en UTF-8",
                operation="validate_encoding",
            ) from e
        return True

    def validate_safety(self, content: str) -> bool:
        """Validar contra patrones XSS (VAL_004)."""
        for pattern in self.XSS_PATTERNS:
            if re.search(pattern, content, re.IGNORECASE):
                raise ValidationError(
                    code="VAL_004",
                    message="El documento contiene código potencialmente malicioso",
                    operation="validate_safety",
                )
        return True

    def validate_size(self, content: str) -> bool:
        """Validar tamaño máximo (VAL_005)."""
        size_bytes = len(content.encode('utf-8'))
        if size_bytes > self.MAX_SIZE_BYTES:
            raise ValidationError(
                code="VAL_005",
                message=f"El documento excede el tamaño máximo de {self.MAX_SIZE_BYTES // 1024 // 1024}MB",
                operation="validate_size",
            )
        return True

    def validate_all(self, content: str) -> bool:
        """Ejecutar todos los gates de validación."""
        self.validate_content(content)
        self.validate_markdown(content)
        self.validate_encoding(content.encode('utf-8'))
        self.validate_safety(content)
        self.validate_size(content)
        return True
```

### 2.2 Ejecutar Pruebas VERDES

```bash
# Tests backend
cd tests/python && pytest unit/services/validators/ unit/core/ -v

# Tests frontend
cd tests && flutter test test/unit/core/error_handling/

# Salida Esperada: TODO VERDE (100% tasa de éxito)
```

**Checklist Fase 2:**
- [ ] DocumentoValidator implementado con 5 gates de validación
- [ ] Decorador @with_retry implementado con backoff exponencial
- [ ] Excepciones personalizadas agregadas (ValidationError, RetryExhaustedError)
- [ ] ErrorMapper implementado con 10+ códigos de error
- [ ] SnackbarService implementado con 4 tipos de notificación
- [ ] Todos los pruebas ROJOS ahora VERDES
- [ ] Sin duplicación de código (principio DRY)

---

## 🔵 Fase 3: TDD - REFACTOR (Mejoras y Robustez)

**Objetivo:** Optimizar código, agregar logging, mejorar mensajes de error.

### 3.1 Agregar Logging Estructurado

**Archivo:** `src/server/app/core/logging_config.py`

```python
"""Configuración de logging estructurado."""
import json
import logging
from datetime import datetime
from typing import Any


class StructuredFormatter(logging.Formatter):
    """Formatter JSON para logging estructurado."""

    def format(self, record: logging.LogRecord) -> str:
        """Formatear registro de log como JSON."""
        log_data: dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "operation": getattr(record, "operation", None),
            "error_code": getattr(record, "error_code", None),
        }

        # Agregar info de excepción si está presente
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data)


def setup_logging() -> None:
    """Configurar logging de aplicación."""
    handler = logging.StreamHandler()
    handler.setFormatter(StructuredFormatter())

    logging.basicConfig(
        level=logging.INFO,
        handlers=[handler],
    )
```

**Checklist Fase 3:**
- [ ] Logging estructurado JSON implementado
- [ ] Tracking de contexto de error agregado
- [ ] Patrones de validación optimizados (cached)
- [ ] Todos los logs sanitizados (sin datos sensibles)
- [ ] Cobertura de código mantenida >90%
- [ ] Sin regresiones de performance

---

## 🧪 Fase 4: Pruebaing de Integración (E2E)

**Objetivo:** Pruebaear flujo completo de manejo de errores end-to-end.

### 4.1 Prueba de Integración Backend

**Archivo:** `pruebas/python/integration/prueba_error_handling_flow.py`

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app


class TestErrorHandlingFlow:
    """Tests E2E para flujo de manejo de errores."""

    @pytest.fixture
    def client(self):
        return TestClient(app)

    def test_validation_error_returns_400_with_code(self, client):
        """Debe retornar VAL_001 para documento inválido."""
        response = client.post(
            "/api/v1/chat/generate",
            json={"content": "Muy corto"}  # <50 chars
        )

        assert response.status_code == 400
        data = response.json()
        assert data["code"] == "VAL_001"
        assert "mínimo" in data["message"]

    def test_retry_exhausted_returns_503(self, client, monkeypatch):
        """Debe retornar 503 después de agotar reintentos."""
        # Mock ChromaDB para que siempre falle
        def mock_query(*args, **kwargs):
            raise ConnectionError("ChromaDB no disponible")

        monkeypatch.setattr("app.services.rag.vector_store.query", mock_query)

        response = client.post(
            "/api/v1/chat/generate",
            json={"content": "Contenido válido con longitud suficiente"}
        )

        assert response.status_code == 503
        data = response.json()
        assert data["code"] == "SYS_RETRY_EXHAUSTED"
```

**Checklist Fase 4:**
- [ ] Pruebas E2E backend pasan (2+ escenarios)
- [ ] Pruebas E2E frontend pasan (2+ escenarios)
- [ ] Flujo de error validado end-to-end
- [ ] Lógica de reintento verificada con mocks
- [ ] Comportamiento de snackbar validado

---

## 📚 Fase 5: Documentoación y Validación

### 5.1 Actualizar ERROR_HANDLING_STANDARD.md

Agregar códigos de error de validación y documentoación de lógica de reintentos.

### 5.2 Crear Guía de Manejo de Errores

**Archivo:** `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md`

```markdown
# Guía de Manejo de Errores para Desarrolladores

## Referencia Rápida

| Código de Error | Significado | Acción del Usuario |
|-----------------|-------------|---------------------|
| VAL_001 | Documento muy corto | Regenerar documento |
| VAL_002 | Markdown inválido | Revisar estructura |
| SYS_001 | Servidor inalcanzable | Verificar Docker |

## Configuración de Reintentos

- Reintentos máximos: 3
- Delay base: 1.0s
- Backoff: Exponencial (1s, 2s, 4s)
```

**Checklist Fase 5:**
- [ ] ERROR_HANDLING_STANDARD.md actualizado
- [ ] ERROR_HANDLING_GUIDE.md creado
- [ ] Todos los códigos de error documentoados
- [ ] Lógica de reintentos explicada
- [ ] Ejemplos proporcionados

---

## ⚙️ Fase 6: CI/CD y Pipeline

### 6.1 Verificar Cumplimiento CI/CD

```bash
# Checks backend
cd src/server
black --check app/
ruff check app/
python -m pyright app/
pytest tests/ --cov=app --cov-fail-under=90

# Checks frontend
cd src/client
dart format --set-exit-if-changed lib/
flutter analyze
flutter test --coverage

# Todo debe pasar ✅
```

**Checklist Fase 6:**
- [ ] Todo el linting pasa
- [ ] Todos los type checks pasan
- [ ] Cobertura de pruebas >90%
- [ ] GitHub Actions actualizado
- [ ] Pipeline CI verde

---

## 📦 Entregables Finales

### Artefactos de Código
- ✅ `src/server/app/services/validators/documento_validator.py`
- ✅ `src/server/app/core/retry.py`
- ✅ `src/server/app/core/exceptions.py` (actualizado)
- ✅ `src/server/app/core/logging_config.py`
- ✅ `src/client/lib/core/error_handling/error_mapper.dart`
- ✅ `src/client/lib/core/error_handling/snackbar_service.dart`
- ✅ `src/client/lib/core/error_handling/error_context.dart`

### Artefactos de Pruebas
- ✅ `pruebas/python/unit/services/validators/prueba_documento_validator.py` (5+ pruebas)
- ✅ `pruebas/python/unit/core/prueba_retry.py` (4+ pruebas)
- ✅ `pruebas/python/integration/prueba_error_handling_flow.py` (2+ pruebas)
- ✅ `pruebas/prueba/unit/core/error_handling/error_mapper_prueba.dart` (3+ pruebas)
- ✅ `pruebas/prueba/unit/core/error_handling/snackbar_service_prueba.dart` (3+ pruebas)
- ✅ `pruebas/prueba/integration/features/chat/error_handling_flow_prueba.dart` (2+ pruebas)

### Artefactos de Documentoación
- ✅ `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md` (actualizado)
- ✅ `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md`
- ✅ `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md`
- ✅ `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/COMPLETION_SUMMARY.md`

### Métricas
- **Cobertura de Pruebas:** >90% (objetivo alcanzado)
- **Códigos de Error Mapeados:** 11+ códigos
- **Gates de Validación:** 5 gates implementados
- **Lógica de Reintento:** Backoff exponencial (1s, 2s, 4s)
- **Mejoras UX:** 4 tipos de snackbar

---

## 🎉 Criterios de Éxito

**HU-3.4 se considera COMPLETA cuando:**
- [ ] Todos los gates de validación implementados y pruebaeados
- [ ] Lógica de reintento con backoff exponencial funcional
- [ ] UX de Snackbar cumple requisitos (5s auto-ocultar para éxito, manual para errores)
- [ ] Todos los códigos de error mapeados a mensajes en español
- [ ] Cobertura de pruebas >90%
- [ ] Pipeline CI/CD verde
- [ ] Documentoación completa y revisada
- [ ] Mergeado a rama `develop`

**Timeline Estimado:** 3-4 días
**Story Points:** 5 (Complejidad media)
**Dependencias:** HU-3.3 (mergeado) ✅

---

**Última Actualización:** 09/02/2026
**Estado:** 🟢 Listo para Implementación
**Próximo Paso:** Ejecutar Fase 0 (Preparación del Terreno)
