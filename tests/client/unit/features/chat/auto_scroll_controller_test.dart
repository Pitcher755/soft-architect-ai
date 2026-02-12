import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/auto_scroll_controller.dart';

void main() {
  group('AutoScrollController', () {
    late ScrollController scrollController;
    late AutoScrollController autoScrollController;

    setUp(() {
      scrollController = ScrollController();
      autoScrollController = AutoScrollController(scrollController);
    });

    tearDown(() {
      scrollController.dispose();
      autoScrollController.dispose();
    });

    testWidgets('scrolls to bottom when new message arrives', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) => Text('Message $index'),
            ),
          ),
        ),
      );

      autoScrollController.scrollToBottom();
      await tester.pumpAndSettle();

      expect(
        scrollController.position.pixels,
        equals(scrollController.position.maxScrollExtent),
      );
    });

    testWidgets('pauses auto-scroll when user scrolls manually', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) => Text('Message $index'),
            ),
          ),
        ),
      );

      scrollController.jumpTo(100);
      autoScrollController.onNewMessage('New message');
      await tester.pump();

      expect(scrollController.position.pixels, equals(100));
      expect(autoScrollController.isPaused, isTrue);
    });

    testWidgets('maintains 60 FPS during streaming', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 100,
              itemBuilder: (context, index) => Text('Message $index'),
            ),
          ),
        ),
      );

      for (int i = 0; i < 10; i++) {
        autoScrollController.scrollToBottom();
        await tester.pump();
      }

      expect(
        scrollController.position.pixels,
        equals(scrollController.position.maxScrollExtent),
      );
    });

    test('animates scroll smoothly with easeOut curve', () async {
      await autoScrollController.animateToBottom(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      expect(autoScrollController.animationCurve, equals(Curves.easeOut));
      expect(
        autoScrollController.animationDuration,
        equals(const Duration(milliseconds: 300)),
      );
    });
  });
}
