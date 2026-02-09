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
    late ErrorMapper errorMapper;

    setUp(() {
      errorMapper = ErrorMapper();
    });

    test('should map SYS_001 to Spanish message', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('servidor local'));
      expect(message, isNot(contains('ConnectionRefusedError')));
    });

    test('should map SYS_002 to Spanish GPU memory message', () {
      // Arrange
      const errorCode = 'SYS_002';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('memoria'));
      expect(message, contains('gráfica'));
    });

    test('should map VAL_001 to Spanish validation message', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('documento'));
      expect(message, contains('inválido'));
    });

    test('should map VAL_002 to Markdown format error', () {
      // Arrange
      const errorCode = 'VAL_002';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('Markdown'));
    });

    test('should map RAG_001 to empty knowledge base message', () {
      // Arrange
      const errorCode = 'RAG_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('base de conocimiento'));
      expect(message, contains('vacía'));
    });

    test('should provide generic message for unknown error code', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('error'));
      expect(message, contains(errorCode));
    });

    test('should provide actionable suggestion for SYS_001', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final suggestion = errorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Docker'));
    });

    test('should provide actionable suggestion for AUTH_001', () {
      // Arrange
      const errorCode = 'AUTH_001';

      // Act
      final suggestion = errorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Configuración'));
      expect(suggestion, contains('API'));
    });

    test('should provide generic suggestion for unknown error', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final suggestion = errorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, isNotEmpty);
    });

    test('should identify SYS_001 as retryable', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final isRetryable = errorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isTrue);
    });

    test('should identify VAL_001 as retryable', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final isRetryable = errorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isTrue);
    });

    test('should identify AUTH_001 as NOT retryable', () {
      // Arrange
      const errorCode = 'AUTH_001';

      // Act
      final isRetryable = errorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isFalse);
    });

    test('should identify VAL_003 as NOT retryable encoding bug', () {
      // Arrange
      const errorCode = 'VAL_003';

      // Act
      final isRetryable = errorMapper.isRetryable(errorCode);

      // Assert
      expect(isRetryable, isFalse);
    });
  });
}
