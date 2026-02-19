# 🟢 NEXT: PHASE 3 GREEN - Implementation Instructions

> **Start Date:** Jan 29, 2025
> **Duration:** ~1 week
> **Objective:** Implement streaming logic to pass all 14 tests
> **Success Criteria:** `flutter test test/unit/features/chat/` → 14/14 PASSING ✅

---

## 🎯 WHAT YOU NEED TO DO

### Step 1: Create ChatRepositoryImpl (Data Layer)

**File:** `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`

```dart
import 'package:http/http.dart' as http;
import '../../domain/entities/chat_message.dart';
import '../../domain/entities/document_proposal.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final String baseUrl;
  final http.Client httpClient;

  ChatRepositoryImpl({
    required this.baseUrl,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  @override
  Stream<String> generateDocument(
    String docType,
    String userInput,
    Map<String, dynamic> context,
  ) async* {
    try {
      final response = await httpClient.post(
        Uri.parse('$baseUrl/api/v1/chat/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'doc_type': docType,
          'user_input': userInput,
          'context': context,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      // Parse streaming response
      final lines = response.body.split('\n');
      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final token = line.substring(6);
          if (token.isNotEmpty) {
            yield token;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to generate document: $e');
    }
  }

  @override
  Future<void> saveProposal(DocumentProposal proposal) async {
    // TODO: Implement persistence (SQLite, local storage, etc.)
    // For now, no-op
  }

  @override
  Future<List<ChatMessage>> getChatHistory(String projectId) async {
    // TODO: Implement retrieval from local storage
    return [];
  }

  @override
  Future<void> clearChatHistory(String projectId) async {
    // TODO: Implement clearing chat history
  }
}
```

---

### Step 2: Complete ChatNotifier Streaming Logic

**File:** `src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart`

**Current state:** Has skeleton, needs implementation

**What to implement:**

```dart
// Inside ChatNotifier class

Future<void> sendMessage(String message) async {
  // 1. Validate input
  if (message.trim().isEmpty) return;

  // 2. Add user message
  final userMessage = ChatMessage(
    id: generateId(),
    role: MessageRole.user,
    content: message,
    createdAt: DateTime.now(),
    isStreaming: false,
  );

  state = state.copyWith(
    messages: [...state.messages, userMessage],
    isStreaming: true,
    hasError: false,
    errorMessage: null,
  );

  // 3. Create assistant message (will accumulate tokens)
  final assistantMessage = ChatMessage(
    id: generateId(),
    role: MessageRole.assistant,
    content: '',
    createdAt: DateTime.now(),
    isStreaming: true,
  );

  state = state.copyWith(
    messages: [...state.messages, assistantMessage],
  );

  // 4. Call repository to get stream
  try {
    await for (final token in _repository.generateDocument(
      'doc_${state.currentDocIndex}',
      message,
      {}, // context
    )) {
      // 5. Accumulate tokens into assistant message
      final updatedAssistant = assistantMessage.copyWith(
        content: assistantMessage.content + token,
      );

      // 6. Update messages list with new content
      final updatedMessages = [
        ...state.messages.take(state.messages.length - 1),
        updatedAssistant,
      ];

      state = state.copyWith(messages: updatedMessages);
    }

    // 7. Create proposal after streaming complete
    final proposal = DocumentProposal(
      id: generateId(),
      docType: 'doc_${state.currentDocIndex}',
      content: assistantMessage.content,
      metadata: {'docIndex': state.currentDocIndex},
      validationState: ValidationState.pending,
      createdAt: DateTime.now(),
    );

    state = state.copyWith(
      currentProposal: proposal,
      isStreaming: false,
    );
  } catch (e) {
    state = state.copyWith(
      isStreaming: false,
      hasError: true,
      errorMessage: e.toString(),
    );
  }
}

Future<void> validateProposal() async {
  if (state.currentProposal == null) return;

  try {
    // 1. Mark as validated
    final validatedProposal = state.currentProposal!.copyWith(
      validationState: ValidationState.validated,
    );

    // 2. Save to repository
    await _repository.saveProposal(validatedProposal);

    // 3. Advance document index
    final newIndex = state.currentDocIndex + 1;

    // 4. Update state
    state = state.copyWith(
      currentProposal: null,
      currentDocIndex: newIndex,
    );
  } catch (e) {
    state = state.copyWith(
      hasError: true,
      errorMessage: 'Failed to validate: $e',
    );
  }
}

void rejectProposal() {
  state = state.copyWith(
    currentProposal: null,
  );
}

Future<void> regenerateProposal() async {
  if (state.messages.isEmpty) return;

  // Get last user message
  final lastUserMessage = state.messages
      .lastWhere(
        (m) => m.isUser,
        orElse: () => ChatMessage.empty(),
      );

  if (lastUserMessage.id.isEmpty) return;

  // Clear current proposal and retry
  state = state.copyWith(currentProposal: null);

  await sendMessage(lastUserMessage.content);
}

Future<void> retryLastMessage() async {
  if (state.messages.isEmpty) return;

  state = state.copyWith(hasError: false, errorMessage: null);

  final lastUserMessage = state.messages
      .lastWhere(
        (m) => m.isUser,
        orElse: () => ChatMessage.empty(),
      );

  if (lastUserMessage.id.isNotEmpty) {
    await sendMessage(lastUserMessage.content);
  }
}
```

---

### Step 3: Update pubspec.yaml Dependencies

**Add to Flutter pubspec.yaml:**

```yaml
dependencies:
  http: ^1.1.0
```

**Then run:**

```bash
cd src/client && flutter pub get
```

---

### Step 4: Run Tests

**Command:**

```bash
cd tests && flutter test test/unit/features/chat/ --coverage
```

**Expected Output:**

```
✅ All tests passed!
14/14 tests PASSING
```

---

## 📋 TESTING CHECKLIST

### Pre-Test Verification
- [ ] ChatRepositoryImpl created and imported
- [ ] ChatNotifier async logic implemented
- [ ] All TODO comments addressed
- [ ] Type safety verified (no analyzer warnings)

### Test Execution
- [ ] Remove `skip: true` from all 6 ChatNotifier tests
- [ ] Run: `flutter test test/unit/features/chat/ --coverage`
- [ ] Verify: 14/14 PASSING

### Post-Test Validation
- [ ] Coverage >80% for presentation layer
- [ ] All error paths tested
- [ ] Streaming behavior verified

---

## 🐛 DEBUGGING TIPS

### If Tests Fail

#### Issue: "ChatRepositoryImpl not found"
- ✅ Solution: Create file with correct import path
- Ensure: `import` statement matches file location

#### Issue: "Stream returned 0 tokens"
- ✅ Solution: Verify Backend is running on correct port
- Check: `http://localhost:8000/api/v1/chat/generate`

#### Issue: "Type mismatch in copyWith()"
- ✅ Solution: Ensure all fields in state copy
- Check: ChatState constructor signature

#### Issue: "Future never completes"
- ✅ Solution: Check for missing `await` statements
- Verify: All async methods properly awaited

---

## 🎓 KEY CONCEPTS TO VERIFY

### Streaming Pattern
```dart
// Correct: Accumulate tokens into assistant message
await for (final token in stream) {
  message.content += token;  // Build complete response
  state = state.copyWith(messages: updated);  // Immutable update
}
```

### State Machine Transitions
```
User Message → Assistant Streaming → Proposal → Validated → Next Doc
     ↓              ↓                   ↓
  Add msg     Accumulate tokens    Create proposal
                                   + Calculate index
```

### Repository Pattern
```dart
ChatRepository (interface) ← ChatRepositoryImpl (implementation)
                                    ↓
                         HTTP Client (external)
                                    ↓
                         Backend /api/v1/chat/generate
```

---

## 📊 PHASE 3 GREEN TIMELINE

| Day | Task | Expected Result |
|-----|------|-----------------|
| Day 1 | Create ChatRepositoryImpl | File created, imports resolved |
| Day 2 | Complete ChatNotifier logic | Async methods implemented |
| Day 3 | Update dependencies | `flutter pub get` succeeds |
| Day 4 | Remove test skips | Tests unskipped |
| Day 5 | Run tests | All 14 passing ✅ |
| Day 6 | Validation & docs | Coverage >80%, PR ready |
| Day 7 | Code review & merge | PR merged to develop |

---

## 🚀 SUCCESS CRITERIA

### GREEN Phase Success
```
✅ ChatRepositoryImpl implements all methods
✅ ChatNotifier handles streaming correctly
✅ All 14 tests PASSING (8 entity + 6 notifier)
✅ Coverage >80% for presentation layer
✅ 0 compilation errors
✅ Streaming behavior verified with Backend
✅ PR merged to develop
```

---

## 📚 REFERENCES

### Code to Review
- [ChatRepositoryImpl template](#step-1-create-chatrepositoryimpl-data-layer)
- [ChatNotifier implementation](#step-2-complete-chatnotifier-streaming-logic)
- [Existing ChatState](./streaming_state.dart) - Study copyWith pattern

### Tests to Inspect
- [chat_notifier_test.dart](../tests/test/unit/features/chat/presentation/notifiers/chat_notifier_test.dart)
- FakeChatRepository in test file (shows expected behavior)

### Backend Reference
- Endpoint: POST `/api/v1/chat/generate`
- Response: Server-Sent Events (SSE) stream
- Format: `data: {token}\n\n`

---

## 🎯 NEXT AFTER GREEN

Once all 14 tests PASSING:

1. **Create UI Widgets** (Phase 3 continuation)
   - ProposalCard (display proposal)
   - StreamingIndicator (real-time feedback)
   - MessageBubble (chat display)

2. **Integration Testing** (Phase 4)
   - E2E workflow: User input → 1 complete document
   - Error scenarios: Connection failure, timeout
   - Local caching for offline support

3. **Production Ready** (Phases 5-6)
   - Load testing (concurrent users)
   - Performance optimization (token buffering)
   - Docker & deployment

---

**Status:** Ready to START GREEN Phase
**Confidence:** 95% (All architecture verified)
**Timeline:** 1 week to completion

Good luck! 🚀
