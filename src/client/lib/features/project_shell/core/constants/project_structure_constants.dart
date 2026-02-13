class ProjectStructureConstants {
  static const int totalExpectedDocs = 25;

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
    {
      'index': 6,
      'name': 'Meta',
      'folders': ['context/99-META'],
      'mandatoryDocs': ['CONTEXT_GENERATOR_PROMPT.md'],
    },
  ];
}
