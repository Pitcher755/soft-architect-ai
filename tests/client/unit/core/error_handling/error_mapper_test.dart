// Unit tests for ErrorMapper (TDD RED Phase).
//
// This module tests error code to Spanish message mapping for UX.
// All tests are expected to FAIL until implementation is complete (Phase 2).
//
// Test Coverage:
// - System error codes (SYS_*)
// - Validation error codes (VAL_*)
// - RAG error codes (RAG_*)
// - Unknown error codes (fallback)
// - Actionable suggestions
// - Retryable error detection

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/error_handling/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    setUp(() {
      // Force Spanish locale for consistent testing
      ErrorMapper.setLocale('es');
    });

    test('should map SYS_001 to Spanish message', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('servidor local'));
      expect(message, isNot(contains('ConnectionRefusedError')));
    });

    test('should map SYS_002 to Spanish GPU memory message', () {
      // Arrange
      const errorCode = 'SYS_002';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('memoria'));
      expect(message, contains('gráfica'));
    });

    test('should map VAL_001 to Spanish validation message', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('documento'));
      expect(message, contains('inválido'));
    });

    test('should map VAL_002 to Markdown format error', () {
      // Arrange
      const errorCode = 'VAL_002';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('Markdown'));
    });

    test('should map RAG_001 to empty knowledge base message', () {
      // Arrange
      const errorCode = 'RAG_001';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('base de conocimiento'));
      expect(message, contains('vacía'));
    });

    test('should provide generic message for unknown error code', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final message = ErrorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('error'));
      expect(message, contains(errorCode));
    });

    test('should provide actionable suggestion for SYS_001', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final suggestion = ErrorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Docker'));
    });

    test('should provide actionable suggestion for AUTH_001', () {
      // Arrange
      const errorCode = 'AUTH_001';

      // Act
      final suggestion = ErrorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Configuración'));
      expect(suggestion, contains('API'));
    });

    test('should provide generic suggestion for unknown error', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final suggestion = ErrorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, isNotEmpty);
    });

    test('should identify SYS_001 as retryable', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isTrue);
    });

    test('should identify VAL_001 as retryable', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isTrue);
    });

    test('should identify AUTH_001 as NOT retryable', () {
      // Arrange
      const errorCode = 'AUTH_001';

      // Act
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isFalse);
    });

    test('should identify VAL_003 as NOT retryable encoding bug', () {
      // Arrange
      const errorCode = 'VAL_003';

      // Act
      final isRetryable = ErrorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isFalse);
    });

    // HU-4.4 GAP 4: RAG/LLM Error Codes
    group('HU-4.4 GAP 4: RAG/LLM Error Codes', () {
      test('should map DB_ERR_001 to Spanish message', () {
        // Arrange
        const errorCode = 'DB_ERR_001';

        // Act
        final result = ErrorMapper.getUserMessage(errorCode);

        // Assert
        expect(result, contains('Base de datos'));
        expect(result, contains('no disponible'));
        expect(result, contains('conocimiento general'));
      });

      test('should map RAG_ERR_001 to Spanish message', () {
        // Arrange
        const errorCode = 'RAG_ERR_001';

        // Act
        final result = ErrorMapper.getUserMessage(errorCode);

        // Assert
        expect(result, contains('contexto'));
        expect(result, contains('falló'));
        expect(result, contains('respuesta general'));
      });

      test('DB_ERR_001 message should indicate graceful degradation', () {
        // Arrange
        const errorCode = 'DB_ERR_001';

        // Act
        final result = ErrorMapper.getUserMessage(errorCode);

        // Assert
        // Should indicate system continues working
        expect(result.toLowerCase(), contains('continuando'));
      });

      test('RAG_ERR_001 message should indicate fallback behavior', () {
        // Arrange
        const errorCode = 'RAG_ERR_001';

        // Act
        final result = ErrorMapper.getUserMessage(errorCode);

        // Assert
        // Should indicate fallback to general LLM
        expect(result.toLowerCase(), anyOf([
          contains('general'),
          contains('fallback'),
        ]));
      });
    });
  });
}
