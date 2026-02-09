/// Represents a generated document proposal awaiting validation.
class DocumentProposal {
  DocumentProposal({
    required this.id,
    required this.docType,
    required this.content,
    required this.metadata,
    required this.validationState,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  final String id;
  final String docType;
  final String content;
  final Map<String, dynamic> metadata;
  final ValidationState validationState;
  final DateTime createdAt;

  bool get isPending => validationState == ValidationState.pending;
  bool get isValidated => validationState == ValidationState.validated;
  bool get isRejected => validationState == ValidationState.rejected;

  List<String> extractSections() {
    // Simple regex to extract ## headers
    final regex = RegExp(r'^##\s+(.+)$', multiLine: true);
    final matches = regex.allMatches(content);
    return matches.map((m) => m.group(1)!.trim()).toList();
  }

  DocumentProposal copyWith({
    String? id,
    String? docType,
    String? content,
    Map<String, dynamic>? metadata,
    ValidationState? validationState,
    DateTime? createdAt,
  }) => DocumentProposal(
    id: id ?? this.id,
    docType: docType ?? this.docType,
    content: content ?? this.content,
    metadata: metadata ?? this.metadata,
    validationState: validationState ?? this.validationState,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DocumentProposal &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          docType == other.docType &&
          content == other.content;

  @override
  int get hashCode => id.hashCode ^ docType.hashCode ^ content.hashCode;
}

enum ValidationState { pending, validated, rejected }
