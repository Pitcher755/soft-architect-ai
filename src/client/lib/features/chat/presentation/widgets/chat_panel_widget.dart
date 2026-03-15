import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/entities/chat_message.dart';
import '../notifiers/chat_notifier.dart';
import '../widgets/chat_input_widget.dart';
import '../widgets/error_banner_widget.dart';
import '../widgets/message_bubble_widget.dart';

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

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
    _scrollController = ScrollController();
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
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

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatNotifierProvider);

    // Ocultamos los mensajes silenciosos del usuario al cargar de SQLite
    final messages = chatState.messages
        .where(
          (m) =>
              !(m.role == MessageRole.user &&
                  m.content.trim().startsWith('He validado y guardado')),
        )
        .map(_toUIMessage)
        .toList();

    final showError = chatState.hasError;
    final errorMessage = chatState.errorMessage ?? '';
    final userName = ref.watch(userNameProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () async {
                final notifier = ref.read(chatNotifierProvider.notifier);
                final projectPath = chatState.projectPath;
                // Capture messenger before async gap to satisfy
                // use_build_context_synchronously lint rule.
                final messenger = ScaffoldMessenger.of(context);

                if (projectPath != null && projectPath.isNotEmpty) {
                  await notifier.setProjectPath(projectPath);
                } else {
                  notifier.resetForNewProject(totalDocs: chatState.totalDocs);
                }

                if (mounted) {
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('🔄 Workflow reseteado correctamente'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Reset Workflow'),
            ),
          ),
          if (showError)
            ErrorBannerWidget(message: _getReadableErrorMessage(errorMessage)),
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : SelectionArea(
                    child: ListView.builder(
                      controller: _scrollController,
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[messages.length - 1 - index];
                        final chatNotifier = ref.read(
                          chatNotifierProvider.notifier,
                        );

                        final isValidated = chatState.validatedMessageIds
                            .contains(message.id);

                        // Evaluamos la condición para mejorar la legibilidad
                        final isAssistantDoc =
                            message.role == 'assistant' &&
                            message.content.startsWith('#') &&
                            !message.isStreaming;

                        return MessageBubbleWidget(
                          key: ValueKey(message.id),
                          message: message,
                          messageController: _messageController,
                          userName: userName,
                          isValidated: isValidated,
                          onValidate: isAssistantDoc
                              ? () => chatNotifier.validateProposal(message.id)
                              : null,
                        );
                      },
                    ),
                  ),
          ),
          ChatInputWidget(
            controller: _messageController,
            onSend: (text) {
              ref.read(chatNotifierProvider.notifier).sendMessageStream(text);
            },
            hintText: 'Proporciona retroalimentación o contexto...',
          ),
        ],
      ),
    );
  }

  String _getReadableErrorMessage(String rawError) {
    final lowerError = rawError.toLowerCase();

    if (lowerError.contains('connection refused') ||
        lowerError.contains('failed host lookup') ||
        lowerError.contains('network unreachable')) {
      return '⚠️ No se puede conectar con el servidor. '
          '¿Está Docker encendido?';
    }

    if (lowerError.contains('http 400') || lowerError.contains('bad request')) {
      return '⚠️ Error de configuración de IA. '
          'Verifica las variables de entorno.';
    }

    if (lowerError.contains('http 401') ||
        lowerError.contains('unauthorized')) {
      return '⚠️ Error de autenticación. Verifica tu API key.';
    }

    if (lowerError.contains('http 403') || lowerError.contains('forbidden')) {
      return '⚠️ Acceso denegado. Verifica tus permisos.';
    }

    if (lowerError.contains('http 404') || lowerError.contains('not found')) {
      return '⚠️ Servicio no encontrado. '
          'Verifica la configuración del servidor.';
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

    if (rawError.length > 100) {
      return '⚠️ ${rawError.substring(0, 97)}...';
    }

    return rawError;
  }

  /// Builds the empty state widget shown when no messages exist.
  ///
  /// Displays different content based on the `isGuideProject` flag:
  /// - **Guide Project**: Shows help assistant with documentation support
  /// - **Regular Project**: Shows prompting guide with suggested structure
  ///
  /// The prompting guide includes:
  /// - Project name suggestion
  /// - Target audience
  /// - Main concept
  /// - Key functionalities
  /// - Copy-to-clipboard button for quick template use
  Widget _buildEmptyState() {
    // 🎯 Títulos limpios, sin emojis
    final title = widget.isGuideProject
        ? 'Asistente de Documentación'
        : 'SoftArchitect AI Chat';

    final subtitle = widget.isGuideProject
        ? '¡Bienvenido! Este es tu manual de instrucciones de SoftArchitect.\n'
              '¿No encuentras lo que buscas en los documentos? '
              '¡Pregúntame lo que necesites!'
        : 'Dime cuál es tu idea para este proyecto y le daremos forma.\n'
              'Juntos documentaremos todo el proceso.';

    // 🎯 Seleccionamos el path de la imagen correspondiente
    final imagePath = widget.isGuideProject
        ? 'assets/images/Logo1.png'
        : 'assets/images/Logo2.png';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Renderizamos el logo
            Image.asset(imagePath, width: 80, height: 80),
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

            // 💡 Tarjeta de Sugerencia (solo para proyectos normales)
            if (!widget.isGuideProject) ...[
              const SizedBox(height: 32),
              Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header de la tarjeta
                    Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Estructura recomendada para tu Prompt:',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Lista de sugerencias
                    _buildPromptSuggestionItem(
                      '📝',
                      'Nombre del proyecto',
                      'Ej: "Sistema de Gestión de Inventario"',
                    ),
                    const SizedBox(height: 12),
                    _buildPromptSuggestionItem(
                      '👥',
                      'Público objetivo',
                      'Ej: "Pequeñas empresas retail"',
                    ),
                    const SizedBox(height: 12),
                    _buildPromptSuggestionItem(
                      '💡',
                      'Concepto principal',
                      'Ej: "Control de stock en tiempo real"',
                    ),
                    const SizedBox(height: 12),
                    _buildPromptSuggestionItem(
                      '⚡',
                      'Funcionalidades clave',
                      'Ej: "Alertas de stock bajo, reportes automáticos"',
                    ),

                    const SizedBox(height: 16),

                    // Botón para copiar ejemplo completo
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyPromptExample(context),
                        icon: const Icon(Icons.content_copy, size: 16),
                        label: const Text('Copiar ejemplo de prompt'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mensaje final
                    SelectableText(
                      'No es necesario rellenarlo todo, pero cuanto más '
                      'contexto des, mejor será la arquitectura.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Copies a complete prompt example to clipboard.
  Future<void> _copyPromptExample(BuildContext context) async {
    const promptTemplate = '''
📝 Nombre del proyecto: "Sistema de Gestión de Inventario"

👥 Público objetivo: "Pequeñas empresas retail"

💡 Concepto principal: "Control de stock en tiempo real"

⚡ Funcionalidades clave: "Alertas de stock bajo, reportes automáticos"
''';

    await Clipboard.setData(const ClipboardData(text: promptTemplate));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Ejemplo copiado al portapapeles'),
          duration: Duration(seconds: 2),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// Builds a single prompt suggestion item with icon, title, and example.
  Widget _buildPromptSuggestionItem(
    String emoji,
    String title,
    String example,
  ) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textMain,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              example,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}
