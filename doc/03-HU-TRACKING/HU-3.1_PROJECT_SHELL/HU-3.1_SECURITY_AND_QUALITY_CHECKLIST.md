# 🔐 HU-3.1: Security & Code Quality Checklist

> **Basado en:** AGENTS.md § 8 (Reglas Estrictas CI/CD)
> **Objetivo:** 0 errores en todos los checks antes del PR

---

## ✅ A. Type Safety (Pyright) - 0 Errors Allowed

### Rules for HU-3.1

```python
# pyrightconfig.json (global, pero aplicar a HU-3.1)

{
  "include": ["src/client"],
  "typeCheckingMode": "strict",
  "reportMissingImports": true,
  "reportMissingTypeStubs": true,
  "reportPrivateImportUsage": true,
  "reportOptionalArgument": "warning",
  "reportOptionalIterable": "warning",
  "reportOptionalCallable": "warning",
  "reportOptionalMemberAccess": "warning"
}
```

### Dart Type Annotations (HU-3.1 specific)

**CADA función DEBE tener return type:**

```dart
// ❌ INCORRECTO
class ProjectShellNotifier {
  selectProject(Project project) {  // Missing return type
    // ...
  }
}

// ✅ CORRECTO
class ProjectShellNotifier {
  Future<void> selectProject(Project project) async {  // Explicit
    // ...
  }
}
```

**NUNCA usar `dynamic` sin justificación:**

```dart
// ❌ INCORRECTO
dynamic node = getNode();  // What type is this?

// ✅ CORRECTO
FileNode node = getNode();  // Clear type

// ✅ ACEPTABLE CON COMENTARIO
final dynamic result = jsonDecode(response);  // JSON parsing requires dynamic
assert(result is Map<String, dynamic>);  // Validate type
```

**Optional values DEBEN validarse explícitamente:**

```dart
// ❌ INCORRECTO
Project? project = getProject();
String name = project.name;  // Dart error: could be null

// ✅ CORRECTO
Project? project = getProject();
if (project != null) {
  String name = project.name;
}

// O con assertion
Project? project = getProject();
assert(project != null, 'Project must not be null');
final name = project!.name;  // Now safe
```

### Validation Command

```bash
cd src/client

# Type check Flutter code
flutter analyze lib/features/project_shell/

# Expected output
# ✓ No issues found! (ran in X.Xs)
```

---

## ✅ B. Security Validation - Path Traversal Prevention

### Path Validation Logic

```dart
// lib/features/project_shell/domain/value_objects/project_path.dart

class ProjectPath {
  final String value;

  const ProjectPath._(this.value);

  /// Factory that validates and normalizes path
  factory ProjectPath.fromUserInput(String projectName) {
    // 1. Validate name format
    if (!RegExp(r'^[a-zA-Z0-9_-]{3,50}$').hasMatch(projectName)) {
      throw InvalidProjectNameException(projectName);
    }

    // 2. Build base path (never use user input directly)
    final baseDir = Directory('/home/user/SoftArchitect/projects');
    final fullPath = p.join(baseDir.path, projectName);

    // 3. Normalize and validate boundary
    final normalized = p.normalize(fullPath);
    final basePath = p.normalize(baseDir.path);

    // 4. CRITICAL: Check that normalized path is INSIDE base directory
    if (!normalized.startsWith('$basePath/') && normalized != basePath) {
      throw PathTraversalException('Attempted path traversal: $normalized');
    }

    return ProjectPath._(normalized);
  }

  /// Verify that file path is inside project directory
  static String validateFilePathInProject(
    String projectPath,
    String filePath,
  ) {
    final normalizedFile = p.normalize(filePath);
    final normalizedProject = p.normalize(projectPath);

    // Never allow absolute paths
    if (p.isAbsolute(normalizedFile)) {
      throw PathTraversalException('Absolute file paths not allowed');
    }

    // Construct full path
    final fullPath = p.normalize(p.join(normalizedProject, normalizedFile));

    // Verify it's inside project
    if (!fullPath.startsWith('$normalizedProject/') && fullPath != normalizedProject) {
      throw PathTraversalException(
        'File path escapes project directory: $fullPath',
      );
    }

    return fullPath;
  }
}

// ✅ USAGE
void example() {
  // ✅ SAFE - Valid project name
  final path1 = ProjectPath.fromUserInput('my-project-2024');

  // ❌ REJECTED - Path traversal attempt
  try {
    final path2 = ProjectPath.fromUserInput('../../../etc/passwd');
  } catch (e) {
    print('Security: $e');  // PathTraversalException
  }

  // ❌ REJECTED - Invalid characters
  try {
    final path3 = ProjectPath.fromUserInput('my project!');
  } catch (e) {
    print('Validation: $e');  // InvalidProjectNameException
  }
}
```

### Checklist Path Security

- [ ] ALL project paths built with `p.join()` + `p.normalize()`
- [ ] Boundary check: `fullPath.startsWith(basePath)`
- [ ] Reject absolute paths: `p.isAbsolute()` check
- [ ] No `..` or `./` in file paths
- [ ] Regex validation for project names: `^[a-zA-Z0-9_-]{3,50}$`
- [ ] SQLite UNIQUE constraint on project names

---

## ✅ C. Logging Security - Never Expose Full Paths

### Logging Rules

```dart
// lib/features/project_shell/core/logging/project_logger.dart

class ProjectLogger {
  static const String _safePathPlaceholder = '...';

  /// Log project event with obfuscated path
  static void logProjectOpened(Project project) {
    logger.info(
      'Project opened: ${project.name}',
      extra: {'projectId': project.id},  // NOT full path
    );
  }

  /// NEVER log like this
  static void logProjectOpenedWrong(Project project) {
    // ❌ WRONG - Exposes filesystem
    logger.info('Project opened: ${project.path}');
  }

  /// Log file operation with safe filename only
  static void logFileSelected(String filename, String projectId) {
    logger.info(
      'File selected: $filename',
      extra: {'projectId': projectId},
    );
  }

  /// In errors, show relative path only
  static void logFileError(String filename, dynamic error) {
    logger.error(
      'File operation failed: $filename',
      error: error,
      extra: {'relativeFile': filename},  // NOT absolute path
    );
  }
}

// ✅ USAGE EXAMPLES
logProjectOpened(project);  // ✅ "Project opened: my-project" + {projectId: ...}
logFileSelected('architecture.md', project.id);  // ✅ Safe
```

### Logging Checklist

- [ ] NO hardcoded paths in logs
- [ ] NO absolute paths (use filenames only)
- [ ] NO sensitive user data (API keys, tokens)
- [ ] ERROR logs show relative paths
- [ ] SENSITIVE operations logged to separate rotation file
- [ ] `context/SECURITY_HARDENING_POLICY.es.md` followed

---

## ✅ D. Error Handling - Standardized Exceptions

### Exception Hierarchy for HU-3.1

```dart
// lib/features/project_shell/core/exceptions/project_shell_exceptions.dart

/// Base exception for all project shell errors
abstract class ProjectShellException implements Exception {
  final String code;  // SYS_001, DB_ERR_001, etc.
  final String message;
  final dynamic originalError;

  ProjectShellException({
    required this.code,
    required this.message,
    this.originalError,
  });

  String get displayMessage => message;

  @override
  String toString() => 'ProjectShellException[$code]: $message';
}

/// Domain layer exceptions
class InvalidProjectNameException extends ProjectShellException {
  InvalidProjectNameException(String name)
      : super(
          code: 'PROJ_001',
          message: 'Invalid project name format: must be 3-50 alphanumeric/dash characters',
        );
}

class DuplicateProjectNameException extends ProjectShellException {
  DuplicateProjectNameException(String name)
      : super(
          code: 'PROJ_002',
          message: 'Project name already exists',
        );
}

class PathTraversalException extends ProjectShellException {
  PathTraversalException(String message)
      : super(
          code: 'SEC_001',
          message: 'Path traversal attempt detected: $message',
        );
}

/// Data layer exceptions
class DatabaseException extends ProjectShellException {
  DatabaseException(String message, {dynamic originalError})
      : super(
          code: 'DB_ERR_001',
          message: 'Database operation failed: $message',
          originalError: originalError,
        );
}

class FileSystemException extends ProjectShellException {
  FileSystemException(String message, {dynamic originalError})
      : super(
          code: 'FS_ERR_001',
          message: 'File system operation failed: $message',
          originalError: originalError,
        );
}

/// Network/Backend exceptions
class BackendException extends ProjectShellException {
  BackendException(String message, {int? statusCode, dynamic originalError})
      : super(
          code: statusCode != null ? 'HTTP_${statusCode}_001' : 'NET_ERR_001',
          message: 'Backend communication failed: $message',
          originalError: originalError,
        );
}
```

### Error Handling Pattern

```dart
// ✅ CORRECT ERROR HANDLING

Future<void> selectProject(Project project) async {
  try {
    // 1. Call repository
    final tree = await repository.getProjectTree(project.id);

    // 2. Update state
    state = AsyncData(...);

  } on DatabaseException catch (e) {
    // Handle specific DB errors
    logger.error('Database error while loading project',
      extra: {'code': e.code, 'projectId': project.id},
    );
    state = AsyncError(e, StackTrace.current);

  } on FileSystemException catch (e) {
    // Handle FS errors
    logger.error('File system error',
      extra: {'code': e.code},
    );
    state = AsyncError(e, StackTrace.current);

  } on Exception catch (e, st) {
    // Catch-all for unexpected errors
    logger.error('Unexpected error in selectProject',
      error: e,
      stackTrace: st,
    );
    state = AsyncError(
      ProjectShellException(
        code: 'SYS_999',
        message: 'Unexpected error occurred',
        originalError: e,
      ),
      st,
    );
  }
}

// ❌ NEVER expose stack traces to UI
// ❌ NEVER log full paths
// ❌ NEVER rethrow without wrapping
```

---

## ✅ E. Code Quality - Dart Linting

### Linting Rules

```yaml
# analysis_options.yaml (aplica a src/client/)

linter:
  rules:
    # Error Rules
    - avoid_empty_else
    - avoid_print
    - avoid_returning_null_for_future
    - avoid_slow_async_io
    - cancel_subscriptions
    - close_sinks
    - comment_references
    - control_flow_in_finally
    - empty_statements
    - hash_and_equals
    - invariant_booleans
    - iterable_contains_unrelated_type
    - list_remove_unrelated_type
    - no_adjacent_strings_in_list
    - no_duplicate_case_values
    - prefer_void_to_null
    - throw_in_finally
    - unnecessary_statements
    - unrelated_type_equality_checks

    # Style Rules
    - always_put_control_body_on_new_line
    - always_put_required_named_parameters_first
    - annotate_overrides
    - avoid_bool_literals_in_conditional_expressions
    - avoid_classes_with_only_static_members
    - avoid_double_and_int_checks
    - avoid_field_initializers_in_const_classes
    - avoid_function_literals_in_foreach_calls
    - avoid_init_to_null
    - avoid_null_checks_in_equality_operators
    - avoid_positional_boolean_parameters
    - avoid_private_typedef_functions
    - avoid_relative_lib_imports
    - avoid_renaming_method_parameters
    - avoid_returning_null
    - avoid_returning_null_for_async
    - avoid_returning_this
    - avoid_setters_without_getters
    - avoid_shadowing_type_parameters
    - avoid_single_cascade_in_expression_statements
    - avoid_types_as_parameter_names
    - avoid_types_in_closure_parameters
    - avoid_unnecessary_containers
    - await_only_futures
    - camel_case_extensions
    - camel_case_types
    - cascade_invocations
    - cast_nullable_to_non_nullable
    - constant_identifier_names
    - curly_braces_in_flow_control_structures
    - directives_ordering
    - empty_catches
    - empty_constructor_bodies
    - eol_at_end_of_file
    - file_names
    - implementation_imports
    - leading_newlines_in_multiline_strings
    - library_names
    - library_prefixes
    - library_private_types_in_public_api
    - lines_longer_than_80_chars
    - no_leading_underscores_for_library_prefixes
    - no_leading_underscores_for_local_variables
    - null_closures
    - omit_local_variable_types
    - one_member_abstracts
    - only_throw_errors
    - overridden_fields
    - package_api_docs
    - package_names
    - package_prefixed_library_names
    - parameter_assignments
    - prefer_adjacent_string_concatenation
    - prefer_asserts_in_initializer_lists
    - prefer_asserts_with_message
    - prefer_collection_literals
    - prefer_conditional_assignment
    - prefer_const_constructors
    - prefer_const_constructors_in_immutables
    - prefer_const_declarations
    - prefer_const_literals_to_create_immutables
    - prefer_constructors_over_static_methods
    - prefer_contains
    - prefer_equal_for_default_values
    - prefer_expression_function_bodies
    - prefer_final_fields
    - prefer_final_in_for_each
    - prefer_final_locals
    - prefer_for_elements_to_map_fromIterable
    - prefer_foreach
    - prefer_function_declarations_over_variables
    - prefer_generic_function_type_aliases
    - prefer_if_elements_to_conditional_expressions
    - prefer_if_null_to_conditional_expressions
    - prefer_if_on_single_line_is_else
    - prefer_initializing_formals
    - prefer_inlined_adds
    - prefer_int_literals
    - prefer_interpolation_to_compose_strings
    - prefer_is_empty
    - prefer_is_not_empty
    - prefer_is_not_operator
    - prefer_iterable_whereType
    - prefer_mixin
    - prefer_null_aware_operators
    - prefer_null_coalescing_operators
    - prefer_relative_imports
    - prefer_single_quotes
    - prefer_spread_collections
    - provide_deprecation_message
    - recursive_getters
    - sized_box_for_whitespace
    - sized_box_shrink
    - sort_child_properties_last
    - sort_constructors_first
    - sort_pub_dependencies
    - sort_unnamed_constructors_first
    - tighten_type_of_initializing_formals
    - type_annotate_public_apis
    - type_init_formals
    - unawaited_futures
    - unnecessary_await_in_return
    - unnecessary_brace_in_string_interps
    - unnecessary_const
    - unnecessary_constructor_name
    - unnecessary_getters_setters
    - unnecessary_lambdas
    - unnecessary_null_aware_operator_on_extension_on_nullable
    - unnecessary_null_in_if_null_operators
    - unnecessary_nullable_for_final_variable_declarations
    - unnecessary_overrides
    - unnecessary_parenthesis
    - unnecessary_string_escapes
    - unnecessary_string_interpolations
    - unnecessary_this
    - unnecessary_to_list_in_spreads
    - use_build_context_synchronously
    - use_full_hex_values_for_flutter_colors
    - use_function_type_syntax_for_parameters
    - use_getters_to_define_fields
    - use_if_null_to_convert_nulls
    - use_is_even_rather_than_modulo
    - use_key_in_widget_constructors
    - use_late_for_private_fields_and_variables
    - use_raw_strings
    - use_setters_to_change_properties
    - use_string_buffers
    - use_test_throws_matchers
    - use_to_close_resource
    - void_checks
```

### Linting Command

```bash
cd src/client

# Run linter
flutter analyze lib/features/project_shell/

# Expected: ✓ No issues found!

# Auto-fix where possible
dart fix --apply lib/features/project_shell/
```

---

## ✅ F. Testing Coverage - Minimum 80%

### Coverage Measurement

```bash
cd src/client

# Run tests with coverage
flutter test --coverage

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open report
open coverage/html/index.html

# Verify threshold
lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}'
# Should output: XX.X% (must be >= 80%)
```

### Coverage Breakdown for HU-3.1

| Component | Type | Target | Status |
|-----------|------|--------|--------|
| ProjectValidationUseCase | Unit | 100% | 🟢 |
| DirectoryTreeUseCase | Unit | 100% | 🟢 |
| FileSearchUseCase | Unit | 95% | 🟡 |
| SQLiteDataSource | Unit | 90% | 🟡 |
| ProjectRepositoryImpl | Unit | 85% | 🟡 |
| DirectoryTree widget | Widget | 75% | 🟡 |
| MarkdownPreview widget | Widget | 70% | 🟡 |
| **TOTAL** | - | **80%+** | 🟢 |

---

## ✅ G. Pre-Commit Checklist

Before committing to feature/pit-62-hu-31-...:

```markdown
## Pre-Commit Checklist (Copy-Paste Before git add)

### Code Quality
- [ ] `flutter analyze lib/features/project_shell/` → 0 errors
- [ ] `dart fix --apply lib/features/project_shell/` ran
- [ ] `flutter format lib/features/project_shell/` ran
- [ ] No `// ignore:` without comment explanation
- [ ] No `dynamic` types (check with grep)

### Type Safety
- [ ] All functions have return types
- [ ] All Optional<T> handled with null checks or assertions
- [ ] No broad `Exception` catches

### Security
- [ ] No hardcoded paths (`grep '/home/' lib/features/project_shell/`)
- [ ] No exposed absolute paths in logs
- [ ] All paths validated with ProjectPath
- [ ] SQLite uses parameterized queries

### Testing
- [ ] `flutter test tests/unit/domain/` → all pass
- [ ] `flutter test tests/unit/data/` → all pass
- [ ] `flutter test tests/unit/presentation/` → all pass
- [ ] `flutter test --coverage` → 80%+ coverage
- [ ] No skipped tests (`skip: true`)

### Documentation
- [ ] Public methods have DartDoc comments
- [ ] Complex logic has inline comments
- [ ] Exception classes documented
- [ ] Riverpod providers have `@riverpod` comment

### Git Hygiene
- [ ] Branch: `feature/pit-62-hu-31-...`
- [ ] Commit message format: `feat(hu-3.1): description`
- [ ] No `.env` or secrets
- [ ] No `print()` statements (use logger)

### Final Check
- [ ] Run: `flutter analyze && flutter test --coverage && git add .`
- [ ] Ready for: `git commit -m "..."`
```

---

## 🎬 Próximos Pasos

**Espero tu confirmación:**

```
✅ ANALIZADO Y CONFORME
❌ CAMBIOS NECESARIOS (especifica cuáles)
🤔 PREGUNTAS (formula tus dudas)
```

Una vez que confirmes, procederé a:
1. Crear la estructura de carpetas
2. Escribir los 6 tests RED
3. Crear los mocks necesarios
4. Preparar para GREEN phase
