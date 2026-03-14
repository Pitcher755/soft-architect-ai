/// Constants defining the project structure and phase definitions.
///
/// This class contains the expected document count and phase definitions
/// for the project workflow. Each phase has an index, name, folders,
/// and mandatory/optional documents.
///
/// Total workflow: 6 phases, 24 documents.
class ProjectStructureConstants {
  /// Total number of expected documents across all phases (24 docs).
  static const int totalExpectedDocs = 24;

  /// Phase definitions in generation order.
  ///
  /// Each phase contains:
  /// - index: Phase order (0-5)
  /// - name: Display name
  /// - folders: Directory paths where documents are located
  /// - mandatoryDocs: Required documents for phase completion
  /// - optionalDocs: Optional documents that count toward progress
  ///
  /// Phases:
  /// - Phase 0 (Root): 4 docs in project root
  /// - Phase 1 (Context): 3 docs in context/10-CONTEXT/
  /// - Phase 2 (Requirements): 4 docs in context/20-REQUIREMENTS/
  /// - Phase 3 (Architecture): 6 docs in context/30-ARCHITECTURE/
  /// - Phase 4 (UI/UX): 3 docs in context/35-UX_UI/
  /// - Phase 5 (Planning): 4 docs in context/40-PLANNING/
  static const List<Map<String, Object>> phaseDefinitions = [
    {
      'index': 0,
      'name': 'Raíz',
      'folders': [''],
      'mandatoryDocs': ['AGENTS.md', 'README.md'],
      'optionalDocs': ['RULES.md', 'CONTRIBUTING.md'],
    },
    {
      'index': 1,
      'name': 'Contexto',
      'folders': ['context/10-CONTEXT'],
      'mandatoryDocs': [
        'DOMAIN_LANGUAGE.md',
        'PROJECT_MANIFESTO.md',
        'USER_JOURNEY_MAP.md',
      ],
    },
    {
      'index': 2,
      'name': 'Requisitos',
      'folders': [
        'context/20-REQUIREMENTS',
        'context/20-REQUIREMENTS_AND_SPEC',
      ],
      'mandatoryDocs': [
        'COMPLIANCE_MATRIX.md',
        'REQUIREMENTS_MASTER.md',
        'SECURITY_PRIVACY_POLICY.md',
        'USER_STORIES_MASTER.json',
      ],
    },
    {
      'index': 3,
      'name': 'Arquitectura',
      'folders': ['context/30-ARCHITECTURE'],
      'mandatoryDocs': [
        'API_INTERFACE_CONTRACT.md',
        'ARCH_DECISION_RECORDS.md',
        'DATA_MODEL_SCHEMA.md',
        'PROJECT_STRUCTURE_MAP.md',
        'SECURITY_THREAT_MODEL.md',
        'TECH_STACK_DECISION.md',
      ],
    },
    {
      'index': 4,
      'name': 'UI/UX',
      'folders': ['context/35-UX_UI'],
      'mandatoryDocs': [
        'ACCESSIBILITY_GUIDE.md',
        'DESIGN_SYSTEM.md',
        'UI_WIREFRAMES_FLOW.md',
      ],
    },
    {
      'index': 5,
      'name': 'Planificación',
      'folders': ['context/40-PLANNING'],
      'mandatoryDocs': [
        'CI_CD_PIPELINE.md',
        'DEPLOYMENT_INFRASTRUCTURE.md',
        'ROADMAP_PHASES.md',
        'TESTING_STRATEGY.md',
      ],
    },
  ];
}
