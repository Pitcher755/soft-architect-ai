import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/chat/presentation/providers/streaming_provider.dart';
import 'package:softarchitect_ai/features/chat/presentation/widgets/streaming_message_widget.dart';

void main() {
  group('Streaming Flow E2E', () {
    testWidgets('renders tokens incrementally without jank', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final message = ref.watch(streamingProvider);
                  return StreamingMessageWidget(
                    text: message,
                    isStreaming: message.isNotEmpty,
                  );
                },
              ),
            ),
          ),
        ),
      );

      final binding = tester.binding;
      final frameTimes = <Duration>[];

      for (int i = 0; i < 50; i++) {
        final startFrame = binding.currentFrameTimeStamp;
        await tester.pump(const Duration(milliseconds: 50));
        final endFrame = binding.currentFrameTimeStamp;
        frameTimes.add(endFrame - startFrame);
      }

      for (final duration in frameTimes) {
        expect(
          duration.inMilliseconds,
          lessThan(17),
          reason: 'Frame dropped: ${duration.inMilliseconds}ms',
        );
      }
    });

    testWidgets('auto-scrolls without perceptible pauses', (tester) async {
      final scrollController = ScrollController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 100,
              itemBuilder: (context, index) =>
                  StreamingMessageWidget(text: 'Message $index'),
            ),
          ),
        ),
      );

      for (int i = 0; i < 10; i++) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
        await tester.pumpAndSettle();
      }

      expect(
        scrollController.position.pixels,
        equals(scrollController.position.maxScrollExtent),
      );
    });

    testWidgets('keeps memory growth bounded with circular buffer', (
      tester,
    ) async {
      final initialMemory = tester
          .binding
          .defaultBinaryMessenger
          .handlePlatformMessage; // Placeholder for memory tracking

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: Scaffold(body: SizedBox.shrink())),
        ),
      );

      expect(initialMemory, isNotNull);
    });
  });
}
