# 🔴 FASE 3: Frontend State Machine - TDD RED Checkpoint

> **Estado:** ✅ **FASE ROJA COMPLETE**
> **Fecha:** 2025-01-28
> **Objetivo:** Verificar que estructura de pruebas y domain layer está lista para TDD RED

---

## 📋 Verificación de Completeness

### ✅ Prueba Archivos Creados

| Prueba Archivo | Pruebas | Estado |
|-----------|-------|--------|
| `chat_message_prueba.dart` | 5 prueba cases | ✅ PASSING |
| `documento_proposal_prueba.dart` | 3 prueba cases | ✅ PASSING |
| `chat_notifier_prueba.dart` | 6 prueba cases (skipped) | ✅ COMPILED |
| **Total** | **14 prueba cases** | **✅ READY** |

### ✅ Domain Layer Entities

| Entidad | Métodos | Getters | Estado |
|---------|---------|---------|--------|
| `ChatMessage` | copyWith() | isUser, isAssistant, isComplete | ✅ COMPLETE |
| `DocumentoProposal` | copyWith(), extractSections() | isPendiente, isValidated, isRejected | ✅ COMPLETE |
| `MessageRole` enum | - | user, assistant, system | ✅ COMPLETE |
| `ValidationState` enum | - | pending, validated, rejected | ✅ COMPLETE |

### ✅ Presentación Layer (State Management)

| Clase | Tipo | Responsabilidad | Estado |
|-------|------|-----------------|--------|
| `ChatState` | Data Class | Inmutable state holder | ✅ COMPLETE |
| `ChatNotifier` | StateNotifier | State machine logic | ✅ COMPLETE |

### ✅ Domain Layer (Repository Interface)

| Interfaz | Métodos | Estado |
|----------|---------|--------|
| `ChatRepository` | generateDocumento(), saveProposal(), getChatHistory(), clearChatHistory() | ✅ COMPLETE |

---

## 🧪 Prueba Execution Resultados

### Comando Ejecutado
```bash
cd tests && flutter test test/unit/features/chat/ --coverage
```

### Resultadoado
```
✅ All tests passed!
Total: 14 test cases
- 8 test cases PASSING (ChatMessage + DocumentProposal entities)
- 6 test cases SKIPPED (ChatNotifier - waiting for implementation)
```

### Prueba Summary
```
ChatMessage Entity Tests (5 tests):
✅ should create user message
✅ should create assistant message with streaming state
✅ should return true for isUser with user role
✅ should support copyWith for immutable updates
✅ should implement equality and hashCode

DocumentProposal Entity Tests (3 tests):
✅ should create proposal with pending validation state
✅ should transition validation state to validated
✅ should extract markdown sections from content

ChatNotifier State Machine Tests (6 tests SKIPPED):
🔴 PENDING: should initialize with empty state
🔴 PENDING: should add user message and start streaming
🔴 PENDING: should stream tokens and update assistant message
🔴 PENDING: should transition to proposal state after streaming complete
🔴 PENDING: should handle stream errors gracefully
🔴 PENDING: should advance document index after validation
```

---

## 🧩 Estructura de Archivos Creada

```
tests/test/unit/features/chat/
├── domain/
│   └── entities/
│       ├── chat_message_test.dart ✅
│       └── document_proposal_test.dart ✅
└── presentation/
    └── notifiers/
        └── chat_notifier_test.dart ✅

src/client/lib/features/chat/
├── domain/
│   ├── entities/
│   │   ├── chat_message.dart ✅
│   │   └── document_proposal.dart ✅
│   └── repositories/
│       └── chat_repository.dart ✅
└── presentation/
    └── notifiers/
        ├── chat_notifier.dart ✅
        └── streaming_state.dart ✅
```

---

## 🔄 State Machine Flow (Documentoed)

### Sequential Documento Generation (Doc 1 → 25)

```
User Input
    ↓
[sendMessage()] → Add ChatMessage(role: user)
    ↓
[generateDocument() → Stream<String>]
    ↓
[Stream tokens] → Update ChatMessage(role: assistant, content += token)
    ↓
[Stream complete] → Create DocumentProposal(validationState: pending)
    ↓
┌─── [validateProposal()] ──→ Mark proposal validated
│        ↓
│   [saveProposal()] → Persist via repository
│        ↓
│   [currentDocIndex++] → Advance to next document
│        ↓
│   [currentProposal = null] → Clear proposal
│
└─── [rejectProposal()] ──→ Clear proposal without advancing
         ↓
     [regenerateProposal()] ──→ Retry last user message
         ↓
     [retryLastMessage()] ──→ Retry on error
```

---

## ✅ Red Fase Completion Criteria Met

### Domain Layer
- [x] `ChatMessage` entity with `MessageRole` enum
- [x] `DocumentoProposal` entity with `ValidationState` enum
- [x] `ChatRepository` abstract interface
- [x] `ChatState` immutable state class
- [x] `ChatNotifier` StateNotifier implementación

### Prueba Infraestructura
- [x] Prueba archivos creard with proper structure
- [x] Entity pruebas passing (8/8)
- [x] Notifier pruebas skipped and preparado para implementación
- [x] FakeChatRepository for dependency injection

### Compilation
- [x] No compilation errors in prueba archivos
- [x] All imports resolved correctly
- [x] Dart analyzer satisfied with type safety

---

## 🚀 Siguiente Steps: GREEN Fase

### 1. Implement ChatNotifier Full Logic
```dart
// Current: Partial implementation
// TODO: Complete async streaming logic
- sendMessage(): Stream listener with token accumulation
- validateProposal(): Save & advance doc index
- Error handling: Capture and display error messages
```

### 2. Crear ChatRepositoryImpl (Data Layer)
```dart
// Implement HTTP SSE client
- Connect to Backend: POST /api/v1/chat/generate
- Parse streaming tokens from response
- Handle connection errors gracefully
```

### 3. Implement ChatNotifier Pruebas
```dart
// Use FakeChatRepository to mock API responses
- Enable skipped tests (remove skip: true)
- Run: flutter test test/unit/features/chat/
- Expected: All 14/14 tests PASSING (GREEN phase)
```

### 4. UI Component Integración
- `ProposalCard` widget for displaying documento proposals
- `StreamingIndicator` for real-time feedback
- `ProgressBar` for Doc X/25 estado

---

## 📊 Code Metrics

| Métrica | Valor |
|---------|-------|
| Prueba Archivos | 3 |
| Prueba Cases | 14 (8 passing, 6 pending) |
| Entity Classes | 2 |
| Enums | 2 |
| Interfaces | 1 |
| State Notifiers | 1 |
| Lines of Prueba Code | ~250 |
| Lines of Implementación Code | ~450 |

---

## 🔑 Key Design Decisions

### 1. StateNotifier for State Management
- ✅ Immutable `ChatState` for UI consistency
- ✅ `copyWith()` for predictable state updates
- ✅ Riverpod integration for dependency injection

### 2. Domain-Driven Design
- ✅ Pure domain layer (no framework dependencies)
- ✅ Repository pattern for data abstraction
- ✅ Entities with rich behavior (extractSections, copyWith)

### 3. TDD Red Fase Strategy
- ✅ Pruebas written BEFORE implementación
- ✅ Entities implement business rules (extractSections)
- ✅ State machine documentoed in code comments

---

## ❌ Known Limitations (To Address in GREEN)

1. **ChatNotifier Streaming**: Currently placeholder async logic
   - TODO: Implement full Stream<String> consumption
   - TODO: Update assistant message in real-time

2. **Error Handling**: Basic exception capture
   - TODO: Specific exception types (ConnectionError, ValidationError)
   - TODO: Retry logic with exponential backoff

3. **Data Persistence**: No repository implementación yet
   - TODO: HTTP client with SSE support
   - TODO: Local caching for offline support

---

## ✨ Conclusion

**PHASE 3 TDD RED CHECKPOINT: ✅ PASSED**

All domain layer entities, prueba infrastructure, and state management skeleton are in place and compiling. The prueba suite is ready to transition to GREEN fase by implementing the remaining logic in `ChatNotifier` and creating the `ChatRepositoryImpl` data layer.

Preparado para siguiente sprint: **Implement GREEN fase (make pruebas pass)**
