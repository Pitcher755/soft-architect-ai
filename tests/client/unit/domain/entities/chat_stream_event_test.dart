import 'package:flutter_test/flutter_test.dart';

import 'package:softarchitect_ai/domain/entities/chat_stream_event.dart';

void main() {
  group('TokenEvent', () {
    test('should create TokenEvent with required fields', () {
      const event = TokenEvent(token: 'Hello', isFinal: false);

      expect(event.token, 'Hello');
      expect(event.isFinal, false);
    });

    test('should parse TokenEvent from JSON', () {
      final json = {'token': 'World', 'is_final': true};

      final event = TokenEvent.fromJson(json);

      expect(event.token, 'World');
      expect(event.isFinal, true);
    });

    test('should handle missing is_final field with default false', () {
      final json = {'token': 'Test'};

      final event = TokenEvent.fromJson(json);

      expect(event.token, 'Test');
      expect(event.isFinal, false);
    });

    test('should display token in toString', () {
      const event = TokenEvent(token: 'Sample token');

      final string = event.toString();

      expect(string, contains('Sample token'));
      expect(string, contains('TokenEvent'));
    });

    test('should support equality comparison', () {
      const event1 = TokenEvent(token: 'Hello', isFinal: false);
      const event2 = TokenEvent(token: 'Hello', isFinal: false);
      const event3 = TokenEvent(token: 'Goodbye', isFinal: false);

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('should have consistent hashCode for equal instances', () {
      const event1 = TokenEvent(token: 'Hello', isFinal: false);
      const event2 = TokenEvent(token: 'Hello', isFinal: false);

      expect(event1.hashCode, equals(event2.hashCode));
    });
  });

  group('DoneEvent', () {
    test('should create DoneEvent with required fullResponse', () {
      const event = DoneEvent(
        fullResponse: 'Complete response text',
        sources: [],
        metadata: {},
      );

      expect(event.fullResponse, 'Complete response text');
      expect(event.sources, isEmpty);
      expect(event.metadata, isEmpty);
    });

    test('should parse DoneEvent from JSON', () {
      final json = {
        'full_response': 'Full text here',
        'sources': ['doc1.md', 'doc2.md'],
        'metadata': {'token_count': 42, 'template_used': 'TECHNICAL'},
      };

      final event = DoneEvent.fromJson(json);

      expect(event.fullResponse, 'Full text here');
      expect(event.sources, ['doc1.md', 'doc2.md']);
      expect(event.metadata['token_count'], 42);
      expect(event.metadata['template_used'], 'TECHNICAL');
    });

    test('should handle missing optional fields with defaults', () {
      final json = {'full_response': 'Text only'};

      final event = DoneEvent.fromJson(json);

      expect(event.fullResponse, 'Text only');
      expect(event.sources, isEmpty);
      expect(event.metadata, isEmpty);
    });

    test('should truncate long fullResponse in toString', () {
      final longText = 'A' * 100; // 100 characters
      final event = DoneEvent(
        fullResponse: longText,
        sources: [],
        metadata: {},
      );

      final string = event.toString();

      expect(string.length, lessThan(longText.length + 50));
      expect(string, contains('...'));
    });

    test('should not truncate short fullResponse in toString', () {
      const shortText = 'Short text';
      const event = DoneEvent(
        fullResponse: shortText,
        sources: [],
        metadata: {},
      );

      final string = event.toString();

      expect(string, contains(shortText));
      expect(string, isNot(contains('...')));
    });

    test('should support equality comparison', () {
      const event1 = DoneEvent(
        fullResponse: 'Same text',
        sources: ['doc1.md'],
        metadata: {},
      );
      const event2 = DoneEvent(
        fullResponse: 'Same text',
        sources: ['doc1.md'],
        metadata: {},
      );
      const event3 = DoneEvent(
        fullResponse: 'Different text',
        sources: ['doc1.md'],
        metadata: {},
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('should have consistent hashCode for equal instances', () {
      const event1 = DoneEvent(
        fullResponse: 'Text',
        sources: ['doc1.md'],
        metadata: {},
      );
      const event2 = DoneEvent(
        fullResponse: 'Text',
        sources: ['doc1.md'],
        metadata: {},
      );

      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should compare sources lists correctly', () {
      const event1 = DoneEvent(
        fullResponse: 'Text',
        sources: ['a.md', 'b.md'],
        metadata: {},
      );
      const event2 = DoneEvent(
        fullResponse: 'Text',
        sources: ['a.md', 'b.md'],
        metadata: {},
      );
      const event3 = DoneEvent(
        fullResponse: 'Text',
        sources: ['a.md', 'c.md'],
        metadata: {},
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });
  });

  group('ErrorEvent', () {
    test('should create ErrorEvent with required fields', () {
      const event = ErrorEvent(
        error: 'Connection timeout',
        code: 'TIMEOUT_ERROR',
        shouldRetry: true,
      );

      expect(event.error, 'Connection timeout');
      expect(event.code, 'TIMEOUT_ERROR');
      expect(event.shouldRetry, true);
    });

    test('should parse ErrorEvent from JSON', () {
      final json = {
        'error': 'Network failure',
        'code': 'NETWORK_ERROR',
        'retry': true,
      };

      final event = ErrorEvent.fromJson(json);

      expect(event.error, 'Network failure');
      expect(event.code, 'NETWORK_ERROR');
      expect(event.shouldRetry, true);
    });

    test('should handle missing retry field with default false', () {
      final json = {'error': 'Server error', 'code': 'SERVER_ERROR'};

      final event = ErrorEvent.fromJson(json);

      expect(event.error, 'Server error');
      expect(event.code, 'SERVER_ERROR');
      expect(event.shouldRetry, false);
    });

    test('should display error details in toString', () {
      const event = ErrorEvent(
        error: 'Test error message',
        code: 'TEST_ERROR',
        shouldRetry: false,
      );

      final string = event.toString();

      expect(string, contains('Test error message'));
      expect(string, contains('TEST_ERROR'));
      expect(string, contains('false'));
    });

    test('should support equality comparison', () {
      const event1 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: true,
      );
      const event2 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: true,
      );
      const event3 = ErrorEvent(
        error: 'Different error',
        code: 'ERR_001',
        shouldRetry: true,
      );

      expect(event1, equals(event2));
      expect(event1, isNot(equals(event3)));
    });

    test('should have consistent hashCode for equal instances', () {
      const event1 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: true,
      );
      const event2 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: true,
      );

      expect(event1.hashCode, equals(event2.hashCode));
    });

    test('should distinguish events with different shouldRetry values', () {
      const event1 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: true,
      );
      const event2 = ErrorEvent(
        error: 'Error',
        code: 'ERR_001',
        shouldRetry: false,
      );

      expect(event1, isNot(equals(event2)));
    });
  });

  group('ChatStreamEvent Polymorphism', () {
    test('should allow mixed event type handling', () {
      final events = <ChatStreamEvent>[
        const TokenEvent(token: 'Token1'),
        const TokenEvent(token: 'Token2'),
        const DoneEvent(fullResponse: 'Complete', sources: [], metadata: {}),
      ];

      expect(events.length, 3);
      expect(events[0], isA<TokenEvent>());
      expect(events[1], isA<TokenEvent>());
      expect(events[2], isA<DoneEvent>());
    });

    test('should support type checking with is operator', () {
      const ChatStreamEvent event1 = TokenEvent(token: 'Test');
      const ChatStreamEvent event2 = DoneEvent(
        fullResponse: 'Done',
        sources: [],
        metadata: {},
      );
      const ChatStreamEvent event3 = ErrorEvent(
        error: 'Error',
        code: 'ERR',
        shouldRetry: false,
      );

      expect(event1 is TokenEvent, true);
      expect(event2 is DoneEvent, true);
      expect(event3 is ErrorEvent, true);

      expect(event1 is DoneEvent, false);
      expect(event2 is ErrorEvent, false);
      expect(event3 is TokenEvent, false);
    });
  });
}
