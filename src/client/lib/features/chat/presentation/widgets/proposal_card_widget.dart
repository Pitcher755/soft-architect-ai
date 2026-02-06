import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/document_proposal.dart';

/// Widget that displays a generated document proposal with action buttons.
/// Implements GitHub Dark theme design with markdown preview and validation options.
class ProposalCardWidget extends StatelessWidget {
  const ProposalCardWidget({
    required this.proposal,
    required this.onValidate,
    required this.onRefine,
    required this.onReject,
    super.key,
  });
  final DocumentProposal proposal;
  final VoidCallback onValidate;
  final VoidCallback onRefine;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.sidebarBg,
      border: Border.all(color: AppColors.border),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Header with title and copy button
        _buildHeader(context),
        const SizedBox(height: 0),

        // 2. Content (Markdown Preview)
        _buildContent(context),

        // 3. Action Footer
        _buildActionFooter(context),
      ],
    ),
  );

  Widget _buildHeader(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: const BoxDecoration(
      color: Color(0xFF1C2128),
      border: Border(bottom: BorderSide(color: AppColors.border)),
      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 16),
            const SizedBox(width: 8),
            const Text(
              'Propuesta: ',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontFamily: 'Inter',
              ),
            ),
            Text(
              _formatDocType(proposal.docType),
              style: const TextStyle(
                color: AppColors.textMain,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                fontFamily: 'JetBrains Mono',
              ),
            ),
          ],
        ),
        // Copy button
        InkWell(
          onTap: () => Clipboard.setData(ClipboardData(text: proposal.content)),
          child: const Row(
            children: [
              Icon(Icons.copy, size: 14, color: AppColors.textSecondary),
              SizedBox(width: 4),
              Text(
                'Copiar',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _buildContent(BuildContext context) => Container(
    constraints: const BoxConstraints(maxHeight: 300),
    color: AppColors.mainBg,
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: SelectableText(
        proposal.content,
        style: const TextStyle(
          color: Color(0xFFC9D1D9),
          fontSize: 13,
          fontFamily: 'JetBrains Mono',
          height: 1.6,
        ),
      ),
    ),
  );

  Widget _buildActionFooter(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Reject button
        TextButton.icon(
          onPressed: onReject,
          icon: const Icon(Icons.close, size: 16),
          label: const Text('Rechazar'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.error.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        Row(
          children: [
            // Refine button
            OutlinedButton.icon(
              onPressed: onRefine,
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Refinar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textMain,
                side: const BorderSide(color: AppColors.border),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Validate and save button (Primary Action)
            ElevatedButton.icon(
              onPressed: onValidate,
              icon: const Icon(Icons.check_circle, size: 16),
              label: const Text('Validar y Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 4,
                shadowColor: AppColors.success.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  /// Format document type from SCREAMING_SNAKE_CASE to Title Case
  String _formatDocType(String docType) => docType
      .replaceAll('_', ' ')
      .split(' ')
      .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
      .join(' ');
}
