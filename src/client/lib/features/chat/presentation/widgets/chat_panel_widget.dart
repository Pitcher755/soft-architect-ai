import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/document_proposal.dart';
import '../widgets/error_banner_widget.dart';
import '../widgets/message_bubble_widget.dart';
import '../widgets/proposal_card_widget.dart';

/// Chat panel widget displaying chat interface for the project shell.
///
/// This widget integrates the sequential chat experience within the IDE layout.
class ChatPanelWidget extends StatefulWidget {
  const ChatPanelWidget({
    this.onFileSelected,
    this.messages = const [],
    this.proposal,
    this.showError = false,
    this.errorMessage = '',
    super.key,
  });

  /// Callback when a file is selected from chat context (unused placeholder)
  final Function? onFileSelected;

  /// Chat messages to display
  final List<ChatMessageUI> messages;

  /// Current proposal being displayed
  final DocumentProposal? proposal;

  /// Whether to show error banner
  final bool showError;

  /// Error message to display
  final String errorMessage;

  @override
  State<ChatPanelWidget> createState() => _ChatPanelWidgetState();
}

class _ChatPanelWidgetState extends State<ChatPanelWidget> {
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

        // Input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Color(0xFF161B22),
            border: Border(top: BorderSide(color: Color(0xFF30363D))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  maxLines: 8,
                  minLines: 3,
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 48,
                child: FloatingActionButton(
                  onPressed: () {
                    // Send message logic
                    _messageController.clear();
                  },
                  backgroundColor: AppColors.primaryLight,
                  child: const Icon(
                    Icons.send,
                    color: Color(0xFF0D1117),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildEmptyState() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.chat_outlined, size: 64, color: Colors.grey[600]),
        const SizedBox(height: 24),
        Text(
          'Welcome to SoftArchitect AI Chat',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(color: const Color(0xFFC9D1D9)),
        ),
        const SizedBox(height: 8),
        Text(
          'Ask questions or describe what you need.\nI will generate document proposals for you.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ],
    ),
  );
}
