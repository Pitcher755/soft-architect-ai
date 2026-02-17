// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/chat_message.dart';
import '../notifiers/chat_notifier.dart';
import '../widgets/error_banner_widget.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/proposal_card_widget.dart';

/// Chat panel widget displaying the chat interface for the project shell.
///
/// Integrates the sequential chat experience within the IDE layout.
/// Uses Riverpod for state management and real-time streaming.
class ChatPanelWidget extends ConsumerStatefulWidget {
  const ChatPanelWidget({
    this.onFileSelected,
    this.isGuideProject = false,
    this.projectId = 'default-project',
    super.key,
  });

  /// Callback when a file is selected from chat context (unused placeholder).
  final Function? onFileSelected;

  /// Whether this is the guide project (shows help assistant message).
  final bool isGuideProject;

  /// Project ID for chat context (used in backend API calls).
  final String projectId;

  @override
  ConsumerState<ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends ConsumerState<ChatPanelWidget> {
  late TextEditingController _messageController;
  late ScrollController _scrollController;

  /// Initializes the chat input controller and scroll controller.
  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

  /// Disposes the chat input and scroll controllers.
  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Auto-scrolls to bottom when new messages arrive.
  @override
  void didUpdateWidget(covariant ChatPanelWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Auto-scroll will be handled by listening to state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0, // reverse: true means 0 is the bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  /// Converts domain ChatMessage to UI ChatMessageUI.
  ChatMessageUI _toUIMessage(ChatMessage message) => ChatMessageUI(
    id: message.id,
    role: message.role == MessageRole.user ? 'user' : 'assistant',
    content: message.content,
    timestamp: DateTime.parse(message.timestamp),
    isStreaming: message.isStreaming,
  );

  /// Builds the chat panel layout including
  /// error banner, messages, and input area.
  @override
  Widget build(BuildContext context) {
    // Watch chat state from Riverpod provider
    final chatState = ref.watch(chatNotifierProvider);
    final messages = chatState.messages.map(_toUIMessage).toList();
    final proposal = chatState.currentProposal;
    final showError = chatState.hasError;
    final errorMessage = chatState.errorMessage ?? '';

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Error banner
          if (showError) ErrorBannerWidget(message: errorMessage),

          // Chat messages area
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length + (proposal != null ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Proposal card at top
                      if (index == messages.length && proposal != null) {
                        return ProposalCardWidget(
                          proposal: proposal,
                          onValidate: () {},
                          onRefine: () {},
                          onReject: () {},
                        );
                      }

                      // Messages
                      final message = messages[messages.length - 1 - index];
                      return MessageBubbleWidget(message: message);
                    },
                  ),
          ),

          // Input area (Fixed overflow issue)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outline)),
            ),
            child: Row(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // Alineado abajo si crece
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: _messageController,
                      maxLines: null,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (text) {
                        if (text.trim().isNotEmpty) {
                          ref
                              .read(chatNotifierProvider.notifier)
                              .sendMessageStream(text.trim());
                          _messageController.clear();
                        }
                      },
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Provide feedback or additional context... (Press Enter to send)',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: AppColors.primary),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Send Button (Replaces FAB for better desktop alignment)
                IconButton(
                  onPressed: () {
                    // Send message via Riverpod notifier
                    final text = _messageController.text.trim();
                    if (text.isNotEmpty) {
                      ref
                          .read(chatNotifierProvider.notifier)
                          .sendMessageStream(text);
                      _messageController.clear();
                    }
                  },
                  icon: const Icon(Icons.send_rounded),
                  color: AppColors.primary,
                  iconSize: 24,
                  padding: const EdgeInsets.all(12),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    hoverColor: AppColors.primary.withValues(alpha: 0.2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state widget for the chat panel.
  Widget _buildEmptyState() {
    final title = widget.isGuideProject
        ? '📚 Asistente de Documentación'
        : '🎯 SoftArchitect AI Chat';
    final subtitle = widget.isGuideProject
        ? '¡Bienvenido! Este es tu manual de instrucciones de SoftArchitect.\n¿No encuentras lo que buscas en los documentos? ¡Pregúntame lo que necesites!'
        : 'Dime cuál es tu idea para este proyecto y le daremos forma.\nJuntos documentaremos todo el proceso.';
    final icon = widget.isGuideProject
        ? Icons.help_outline
        : Icons.chat_outlined;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
