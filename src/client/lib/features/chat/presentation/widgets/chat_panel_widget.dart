// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../notifiers/chat_notifier.dart';
import '../widgets/chat_input_widget.dart';
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
    final userName = ref.watch(userNameProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          // Error banner with readable messages
          if (showError)
            ErrorBannerWidget(message: _getReadableErrorMessage(errorMessage)),

          // Chat messages area wrapped in SelectionArea for text selection
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : SelectionArea(
                    child: ListView.builder(
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
                        final chatNotifier = ref.read(
                          chatNotifierProvider.notifier,
                        );
                        final isValidated = chatState.validatedMessageIds
                            .contains(message.id);
                        return MessageBubbleWidget(
                          message: message,
                          messageController: _messageController,
                          userName: userName,
                          isValidated: isValidated,
                          onValidate:
                              message.role == 'assistant' &&
                                  message.content.startsWith('#') &&
                                  !message.isStreaming
                              ? () => chatNotifier.validateProposal(message.id)
                              : null,
                        );
                      },
                    ),
                  ),
          ),

          // Input area using professional chat input widget
          ChatInputWidget(
            controller: _messageController,
            onSend: (text) {
              ref.read(chatNotifierProvider.notifier).sendMessageStream(text);
            },
            hintText: 'Proporciona retroalimentación o contexto adicional...',
          ),
        ],
      ),
    );
  }

  /// Converts raw error messages into user-friendly messages.
  String _getReadableErrorMessage(String rawError) {
    final lowerError = rawError.toLowerCase();

    if (lowerError.contains('connection refused') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network unreachable')) {
      return '⚠️ No se puede conectar con el servidor. ¿Está Docker encendido?';
    }

    if (lowerError.contains('http 400') || lowerError.contains('bad request')) {
      return '⚠️ Error de configuración de IA. Verifica las variables de entorno.';
    }

    if (lowerError.contains('http 401') ||
        lowerError.contains('unauthorized')) {
      return '⚠️ Error de autenticación. Verifica tu API key.';
    }

    if (lowerError.contains('http 403') || lowerError.contains('forbidden')) {
      return '⚠️ Acceso denegado. Verifica tus permisos.';
    }

    if (lowerError.contains('http 404') || lowerError.contains('not found')) {
      return '⚠️ Servicio no encontrado. Verifica la configuración del servidor.';
    }

    if (lowerError.contains('http 500') ||
        lowerError.contains('internal server')) {
      return '⚠️ Error interno del servidor. Revisa los logs del backend.';
    }

    if (lowerError.contains('timeout') || lowerError.contains('timed out')) {
      return '⚠️ El servidor tardó demasiado en responder. Intenta de nuevo.';
    }

    if (lowerError.contains('rate limit') ||
        lowerError.contains('too many requests')) {
      return '⚠️ Has excedido el límite de peticiones. Espera un momento.';
    }

    // Si no coincide con ningún patrón conocido, devolver el mensaje original
    // pero truncado si es muy largo
    if (rawError.length > 100) {
      return '⚠️ ${rawError.substring(0, 97)}...';
    }

    return rawError;
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
          Icon(
            icon,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 24),
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}
