/// Entity representing project progress status
///
/// This entity encapsulates the state of a project's completion,
/// tracking document creation and phase progression.
class ProjectProgress {
  const ProjectProgress({
    required this.documentosCreados,
    required this.faseActual,
    required this.porcentajeCompletado,
    required this.lastUpdated,
  });

  /// Create ProjectProgress from JSON
  factory ProjectProgress.fromJson(Map<String, dynamic> json) =>
      ProjectProgress(
        documentosCreados: json['documentosCreados'] as int? ?? 0,
        faseActual: json['faseActual'] as String? ?? 'Fase 0: Preparación',
        porcentajeCompletado:
            (json['porcentajeCompletado'] as num?)?.toDouble() ?? 0.0,
        lastUpdated: json['lastUpdated'] != null
            ? DateTime.parse(json['lastUpdated'] as String)
            : DateTime.now(),
      );

  /// Number of markdown documents created in context/ folder
  final int documentosCreados;

  /// Current phase name based on document count
  final String faseActual;

  /// Completion percentage (0-100)
  final double porcentajeCompletado;

  /// Timestamp of last update (ISO 8601 format)
  final DateTime lastUpdated;

  /// Convert ProjectProgress to JSON
  Map<String, dynamic> toJson() => {
    'documentosCreados': documentosCreados,
    'faseActual': faseActual,
    'porcentajeCompletado': porcentajeCompletado,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  /// Create a copy with updated values
  ProjectProgress copyWith({
    int? documentosCreados,
    String? faseActual,
    double? porcentajeCompletado,
    DateTime? lastUpdated,
  }) => ProjectProgress(
    documentosCreados: documentosCreados ?? this.documentosCreados,
    faseActual: faseActual ?? this.faseActual,
    porcentajeCompletado: porcentajeCompletado ?? this.porcentajeCompletado,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  @override
  String toString() =>
      'ProjectProgress('
      'docs: $documentosCreados, '
      'fase: $faseActual, '
      'progreso: ${porcentajeCompletado.toStringAsFixed(1)}%, '
      'updated: ${lastUpdated.toIso8601String()}'
      ')';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectProgress &&
          runtimeType == other.runtimeType &&
          documentosCreados == other.documentosCreados &&
          faseActual == other.faseActual &&
          porcentajeCompletado == other.porcentajeCompletado &&
          lastUpdated == other.lastUpdated;

  @override
  int get hashCode =>
      documentosCreados.hashCode ^
      faseActual.hashCode ^
      porcentajeCompletado.hashCode ^
      lastUpdated.hashCode;
}
