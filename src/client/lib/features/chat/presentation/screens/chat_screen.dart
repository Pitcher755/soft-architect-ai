import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../notifiers/chat_notifier.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/proposal_card_widget.dart';
import '../widgets/streaming_indicator_widget.dart';

/// Main chat interface screen.
///
/// Displays conversation history, document proposals, and streaming status.
/// Integrates with ChatNotifier for state management and FileSystemService
/// for persistence.
class ChatScreen extends ConsumerStatefulWidget {
  /// Creates a new ChatScreen.
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  late TextEditingController _messageController;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);
    final chatNotifier = ref.read(chatNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SoftArchitect AI - Chat'),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Conversation and proposals area
          Expanded(
            child: chatState.messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: chatState.messages.length + (chatState.currentProposal != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Show proposal card at the top (reverse order)
                      if (index == chatState.messages.length && chatState.currentProposal != null) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: ProposalCardWidget(
                            proposal: chatState.currentProposal!,
                            onValidate: () {
                              chatNotifier.validateProposal();
                            },
                            onRefine: () {
                              chatNotifier.regenerateProposal();
                            },
                            onReject: () {
                              chatNotifier.rejectProposal();
                            },
                          ),
                        );
                      }

                      // Show messages
                      final message = chatState
                          .messages[chatState.messages.length - 1 - index];
                      final messageUI = ChatMessageUI(
                        id: message.id,
                        role: message.role.name,
                        content: message.content,
                        timestamp: DateTime.parse(message.timestamp),
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: MessageBubbleWidget(message: messageUI),
                      );
                    },
                  ),
          ),

          // Streaming indicator
          if (chatState.isStreaming)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamingIndicatorWidget(
                progress: 0.5,
                documentIndex: 1,
                totalDocuments: 3,
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !chatState.isStreaming,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Ask a question or describe what you need...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: chatState.isStreaming
                          ? const SizedBox(
                              width: 40,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                            )
                          : null,
                    ),
                    onSubmitted: (value) {
                      if (value.isNotEmpty && !chatState.isStreaming) {
                        _sendMessage(chatNotifier);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: chatState.isStreaming
                      ? null
                      : () {
                          if (_messageController.text.isNotEmpty) {
                            _sendMessage(chatNotifier);
                          }
                        },
                  tooltip: 'Send message',
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state when no messages exist.
  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.chat_outlined,
          size: 64,
          color: Theme.of(context).dividerColor,
        ),
        const SizedBox(height: 24),
        Text(
          'Welcome to SoftArchitect AI Chat',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Ask questions or describe what you need.\n'
          'I will generate document proposals for you.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ],
    ),
  );

  /// Sends a message through the ChatNotifier.
  void _sendMessage(ChatNotifier chatNotifier) {
    final message = _messageController.text.trim();
    if (message.isEmpty) {
      return;
    }

    _messageController.clear();
    chatNotifier.sendMessage(message);
  }
}
