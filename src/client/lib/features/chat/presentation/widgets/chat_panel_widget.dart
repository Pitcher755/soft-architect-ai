// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/document_proposal.dart';
import '../widgets/error_banner_widget.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/proposal_card_widget.dart';

/// Chat panel widget displaying the chat interface for the project shell.
///
/// Integrates the sequential chat experience within the IDE layout.
class ChatPanelWidget extends StatefulWidget {
  const ChatPanelWidget({
    this.onFileSelected,
    this.messages = const [],
    this.proposal,
    this.showError = false,
    this.errorMessage = '',
    this.isGuideProject = false,
    super.key,
  });

  /// Callback when a file is selected from chat context (unused placeholder).
  final Function? onFileSelected;

  /// List of chat messages to display.
  final List<ChatMessageUI> messages;

  /// Current document proposal being displayed.
  final DocumentProposal? proposal;

  /// Whether to show the error banner.
  final bool showError;

  /// Error message to display in the error banner.
  final String errorMessage;

  /// Whether this is the guide project (shows help assistant message).
  final bool isGuideProject;

  @override
  State<ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends State<ChatPanelWidget> {
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

    // Auto-scroll when messages change (new tokens or messages)
    if (widget.messages.length != oldWidget.messages.length ||
        _hasStreamingContentChanged(oldWidget)) {
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
  }

  /// Checks if streaming content has changed (tokens added).
  bool _hasStreamingContentChanged(ChatPanelWidget oldWidget) {
    if (widget.messages.length != oldWidget.messages.length) {
      return false; // Already handled by length check
    }

    for (var i = 0; i < widget.messages.length; i++) {
      final newMsg = widget.messages[i];
      final oldMsg = oldWidget.messages[i];
      if (newMsg.isStreaming && newMsg.content != oldMsg.content) {
        return true;
      }
    }
    return false;
  }

  /// Builds the chat panel layout including
  /// error banner, messages, and input area.
  @override
  Widget build(BuildContext context) => Container(
    color: const Color(0xFF0D1117),
    child: Column(
      children: [
        // Error banner
        if (widget.showError) ErrorBannerWidget(message: widget.errorMessage),

        // Chat messages area
        Expanded(
          child: widget.messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount:
                      widget.messages.length +
                      (widget.proposal != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Proposal card at top
                    if (index == widget.messages.length &&
                        widget.proposal != null) {
                      return ProposalCardWidget(
                        proposal: widget.proposal!,
                        onValidate: () {},
                        onRefine: () {},
                        onReject: () {},
                      );
                    }

                    // Messages
                    final message =
                        widget.messages[widget.messages.length - 1 - index];
                    return MessageBubbleWidget(message: message);
                  },
                ),
        ),

        // Input area (Fixed overflow issue)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(top: BorderSide(color: Color(0xFF30363D))),
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.end, // Alineado abajo si crece
            children: [
              Expanded(
                child: ConstrainedBox(
                  // Limitar altura máxima
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _messageController,
                    maxLines: null, // Auto-grow
                    minLines: 1, // Start small
                    style: const TextStyle(
                      color: Color(0xFFC9D1D9),
                      fontSize: 13,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Provide feedback or additional context...',
                      hintStyle: const TextStyle(color: Color(0xFF8B949E)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        // Consistent border color
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        // Highlight on focus
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
                  // Send message logic
                  if (_messageController.text.trim().isNotEmpty) {
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
          Icon(icon, size: 64, color: Colors.grey[600]),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: const Color(0xFFC9D1D9)),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }
}
