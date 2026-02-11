import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/core/buffer/circular_buffer.dart';

void main() {
  group('CircularBuffer', () {
    test('initializes with max capacity', () {
      final buffer = CircularBuffer<String>(maxSize: 100);

      expect(buffer.maxSize, equals(100));
      expect(buffer.length, equals(0));
      expect(buffer.isEmpty, isTrue);
    });

    test('adds elements up to max capacity', () {
      final buffer = CircularBuffer<String>(maxSize: 3);

      buffer.add('Message 1');
      buffer.add('Message 2');
      buffer.add('Message 3');

      expect(buffer.length, equals(3));
      expect(buffer.isFull, isTrue);
    });

    test('overwrites oldest element when full', () {
      final buffer = CircularBuffer<String>(maxSize: 3);
      buffer.add('Message 1');
      buffer.add('Message 2');
      buffer.add('Message 3');

      buffer.add('Message 4');

      expect(buffer.length, equals(3));
      expect(buffer.toList(), equals(['Message 2', 'Message 3', 'Message 4']));
    });

    test('returns elements in FIFO order', () {
      final buffer = CircularBuffer<String>(maxSize: 5);
      buffer.add('First');
      buffer.add('Second');
      buffer.add('Third');

      expect(buffer.toList(), equals(['First', 'Second', 'Third']));
    });

    test('clears buffer completely', () {
      final buffer = CircularBuffer<String>(maxSize: 3);
      buffer.add('Message 1');
      buffer.add('Message 2');

      buffer.clear();

      expect(buffer.isEmpty, isTrue);
      expect(buffer.length, equals(0));
    });

    test('prevents memory leaks on repeated operations', () {
      final buffer = CircularBuffer<String>(maxSize: 100);
      final initialMemory = ProcessInfo.currentRss;

      for (int i = 0; i < 10000; i++) {
        buffer.add('Message $i');
      }

      final finalMemory = ProcessInfo.currentRss;
      final memoryGrowth = finalMemory - initialMemory;
      expect(memoryGrowth, lessThan(5 * 1024 * 1024));
      expect(buffer.length, equals(100));
    });
  });
}
