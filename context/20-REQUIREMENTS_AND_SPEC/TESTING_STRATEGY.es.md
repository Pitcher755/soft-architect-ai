# 🧪 Estrategia de Testing y QA

> **Filosofía:** "Si no está probado, está roto".
> **Metodología:** TDD (Test Driven Development) obligatorio para lógica crítica del Backend.

---

## 1. Niveles de Testing (The Pyramid)

### Nivel 1: Unit Tests (70%)
* **Objetivo:** Verificar la lógica de negocio aislada.
* **Backend (Python/Pytest):**
    * Parsers de Markdown.
    * Funciones de utilidad de LangChain (sin llamar al LLM real, usando Mocks).
* **Frontend (Flutter Test):**
    * Parsers de JSON.
    * Validadores de formularios.

### Nivel 2: Integration Tests (20%)
* **Objetivo:** Verificar que los componentes hablan entre sí.
* **Backend:**
    * Testear que el endpoint `/chat` recibe un JSON y devuelve un Stream (usando `TestClient` de FastAPI).
    * Verificar la conexión con ChromaDB (usando DB en memoria o container efímero).
* **Frontend:**
    * Verificar que el repositorio llama al Datasource correctamente.

### Nivel 3: Widget/UI Tests (10%)
* **Objetivo:** Verificar que la interfaz no explota.
* **Flutter:**
    * Verificar que al pulsar "Enviar", aparece el mensaje en la lista.
    * Verificar que el selector de modelo cambia el estado visual.

---

## 2. Reglas de TDD (El Ciclo)

Para cualquier lógica crítica (especialmente en `src/server`), se sigue el ciclo:

1.  🔴 **RED:** Escribir un test que falle (ej: `test_should_sanitize_api_keys`).
2.  🟢 **GREEN:** Escribir el código mínimo para que pase.
3.  🔵 **REFACTOR:** Limpiar y optimizar sin romper el test.

---

## 3. Herramientas y Comandos

| Capa | Tipo | Herramienta | Comando |
| :--- | :--- | :--- | :--- |
| **Backend** | Unit/Int | `pytest` | `docker compose exec api-server pytest` |
| **Backend** | Async | `pytest-asyncio` | (Incluido en suite anterior) |
| **Frontend** | Unit/Widget | `flutter_test` | `cd src/client && flutter test` |
| **E2E** | Full | `flutter_driver` | `cd src/client && flutter drive --target=test_driver/app.dart` |

---

## 4. Datos de Test y Mocks

* **Backend:** Usar `pytest-mock` para respuestas LLM. Simular que el LLM devuelve "Hola mundo" instantáneamente para probar que la UI lo pinta bien.
* **Frontend:** Usar `mockito` para repositorios. Mockear respuestas API para testear estados de error.

---

## 5. Integración CI/CD

* **GitHub Actions:** Ejecutar tests en cada PR a `develop`.
* **Coverage:** Forzar >80% cobertura con `coverage.py` (Python) y `flutter_test --coverage` (Dart).
* **Mutation Testing:** Usar `mutmut` para Python para asegurar que los tests son robustos.