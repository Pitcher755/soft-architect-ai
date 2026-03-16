"""Master Workflow Registry.

Defines the immutable sequence of 24 project steps and their physical file paths.
"""

from dataclasses import dataclass


@dataclass
class WorkflowStep:
    step_number: int
    doc_type: str
    phase_folder: str
    template_path: str
    example_path: str
    output_path: str


# Master Workflow: 24 ordered steps with actual monorepo paths
MASTER_WORKFLOW: list[WorkflowStep] = [
    # Phase 1: Context
    WorkflowStep(
        1,
        "PROJECT_MANIFESTO",
        "10-CONTEXT",
        "packages/knowledge_base/01-TEMPLATES/10-CONTEXT/PROJECT_MANIFESTO.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/PROJECT_MANIFESTO_EXAMPLE.md",
        "context/10-CONTEXT/PROJECT_MANIFESTO.md",
    ),
    WorkflowStep(
        2,
        "DOMAIN_LANGUAGE",
        "10-CONTEXT",
        "packages/knowledge_base/01-TEMPLATES/10-CONTEXT/DOMAIN_LANGUAGE.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/DOMAIN_LANGUAGE_EXAMPLE.md",
        "context/10-CONTEXT/DOMAIN_LANGUAGE.md",
    ),
    WorkflowStep(
        3,
        "USER_JOURNEY_MAP",
        "10-CONTEXT",
        "packages/knowledge_base/01-TEMPLATES/10-CONTEXT/USER_JOURNEY_MAP.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/USER_JOURNEY_MAP_EXAMPLE.md",
        "context/10-CONTEXT/USER_JOURNEY_MAP.md",
    ),
    # Phase 2: Requirements
    WorkflowStep(
        4,
        "REQUIREMENTS_MASTER",
        "20-REQUIREMENTS",
        "packages/knowledge_base/01-TEMPLATES/20-REQUIREMENTS/REQUIREMENTS_MASTER.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/REQUIREMENTS_MASTER_EXAMPLE.md",
        "context/20-REQUIREMENTS/REQUIREMENTS_MASTER.md",
    ),
    WorkflowStep(
        5,
        "USER_STORIES_MASTER",
        "20-REQUIREMENTS",
        "packages/knowledge_base/01-TEMPLATES/20-REQUIREMENTS/USER_STORIES_MASTER.template.json",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/USER_STORIES_MASTER_EXAMPLE.json",
        "context/20-REQUIREMENTS/USER_STORIES_MASTER.json",
    ),
    WorkflowStep(
        6,
        "SECURITY_PRIVACY_POLICY",
        "20-REQUIREMENTS",
        "packages/knowledge_base/01-TEMPLATES/20-REQUIREMENTS/SECURITY_PRIVACY_POLICY.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/SECURITY_PRIVACY_POLICY_EXAMPLE.md",
        "context/20-REQUIREMENTS/SECURITY_PRIVACY_POLICY.md",
    ),
    WorkflowStep(
        7,
        "COMPLIANCE_MATRIX",
        "20-REQUIREMENTS",
        "packages/knowledge_base/01-TEMPLATES/20-REQUIREMENTS/COMPLIANCE_MATRIX.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/COMPLIANCE_MATRIX_EXAMPLE.md",
        "context/20-REQUIREMENTS/COMPLIANCE_MATRIX.md",
    ),
    # Phase 3: Architecture
    WorkflowStep(
        8,
        "TECH_STACK_DECISION",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/TECH_STACK_DECISION.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/TECH_STACK_DECISION_EXAMPLE.md",
        "context/30-ARCHITECTURE/TECH_STACK_DECISION.md",
    ),
    WorkflowStep(
        9,
        "DATA_MODEL_SCHEMA",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/DATA_MODEL_SCHEMA.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/DATA_MODEL_SCHEMA_EXAMPLE.md",
        "context/30-ARCHITECTURE/DATA_MODEL_SCHEMA.md",
    ),
    WorkflowStep(
        10,
        "API_INTERFACE_CONTRACT",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/API_INTERFACE_CONTRACT.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/API_INTERFACE_CONTRACT_EXAMPLE.md",
        "context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.md",
    ),
    WorkflowStep(
        11,
        "PROJECT_STRUCTURE_MAP",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/PROJECT_STRUCTURE_MAP_EXAMPLE.md",
        "context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.md",
    ),
    WorkflowStep(
        12,
        "SECURITY_THREAT_MODEL",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/SECURITY_THREAT_MODEL.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/SECURITY_THREAT_MODEL_EXAMPLE.md",
        "context/30-ARCHITECTURE/SECURITY_THREAT_MODEL.md",
    ),
    WorkflowStep(
        13,
        "ARCH_DECISION_RECORDS",
        "30-ARCHITECTURE",
        "packages/knowledge_base/01-TEMPLATES/30-ARCHITECTURE/ARCH_DECISION_RECORDS.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/ARCH_DECISION_RECORDS_EXAMPLE.md",
        "context/30-ARCHITECTURE/ARCH_DECISION_RECORDS.md",
    ),
    # Phase 4: UX/UI
    WorkflowStep(
        14,
        "DESIGN_SYSTEM",
        "35-UX_UI",
        "packages/knowledge_base/01-TEMPLATES/35-UX_UI/DESIGN_SYSTEM.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/DESIGN_SYSTEM_EXAMPLE.md",
        "context/35-UX_UI/DESIGN_SYSTEM.md",
    ),
    WorkflowStep(
        15,
        "UI_WIREFRAMES_FLOW",
        "35-UX_UI",
        "packages/knowledge_base/01-TEMPLATES/35-UX_UI/UI_WIREFRAMES_FLOW.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/UI_WIREFRAMES_FLOW_EXAMPLE.md",
        "context/35-UX_UI/UI_WIREFRAMES_FLOW.md",
    ),
    WorkflowStep(
        16,
        "ACCESSIBILITY_GUIDE",
        "35-UX_UI",
        "packages/knowledge_base/01-TEMPLATES/35-UX_UI/ACCESSIBILITY_GUIDE.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/ACCESSIBILITY_GUIDE_EXAMPLE.md",
        "context/35-UX_UI/ACCESSIBILITY_GUIDE.md",
    ),
    # Phase 5: Planning
    WorkflowStep(
        17,
        "ROADMAP_PHASES",
        "40-PLANNING",
        "packages/knowledge_base/01-TEMPLATES/40-PLANNING/ROADMAP_PHASES.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/ROADMAP_PHASES_EXAMPLE.md",
        "context/40-PLANNING/ROADMAP_PHASES.md",
    ),
    WorkflowStep(
        18,
        "DEPLOYMENT_INFRASTRUCTURE",
        "40-PLANNING",
        "packages/knowledge_base/01-TEMPLATES/40-PLANNING/DEPLOYMENT_INFRASTRUCTURE.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/DEPLOYMENT_INFRASTRUCTURE_EXAMPLE.md",
        "context/40-PLANNING/DEPLOYMENT_INFRASTRUCTURE.md",
    ),
    WorkflowStep(
        19,
        "CI_CD_PIPELINE",
        "40-PLANNING",
        "packages/knowledge_base/01-TEMPLATES/40-PLANNING/CI_CD_PIPELINE.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/CI_CD_PIPELINE_EXAMPLE.md",
        "context/40-PLANNING/CI_CD_PIPELINE.md",
    ),
    WorkflowStep(
        20,
        "TESTING_STRATEGY",
        "40-PLANNING",
        "packages/knowledge_base/01-TEMPLATES/40-PLANNING/TESTING_STRATEGY.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/TESTING_STRATEGY_EXAMPLE.md",
        "context/40-PLANNING/TESTING_STRATEGY.md",
    ),
    # Phase 6: Root / Meta
    WorkflowStep(
        21,
        "RULES",
        "00-ROOT",
        "packages/knowledge_base/01-TEMPLATES/00-ROOT/RULES.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/RULES_EXAMPLE.md",
        "RULES.md",
    ),
    WorkflowStep(
        22,
        "CONTRIBUTING",
        "00-ROOT",
        "packages/knowledge_base/01-TEMPLATES/00-ROOT/CONTRIBUTING.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/CONTRIBUTING_EXAMPLE.md",
        "CONTRIBUTING.md",
    ),
    WorkflowStep(
        23,
        "AGENTS",
        "00-ROOT",
        "packages/knowledge_base/01-TEMPLATES/00-ROOT/AGENTS.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/AGENTS_EXAMPLE.md",
        "AGENTS.md",
    ),
    WorkflowStep(
        24,
        "README",
        "00-ROOT",
        "packages/knowledge_base/01-TEMPLATES/00-ROOT/README.template.md",
        "packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/README_EXAMPLE.md",
        "README.md",
    ),
]


# ---------------------------------------------------------------------------
# Context Dependency Graph
# ---------------------------------------------------------------------------
# Maps each doc_type to the list of prior doc_types whose content is truly
# needed to generate it.  The orchestrator uses this to filter project_context
# before injecting it into the LLM prompt, avoiding context-window overflow.
#
# Design rationale (Dependency-Graph strategy):
#   • Each entry lists ONLY the direct parents the doc needs to be consistent
#     with — not every preceding document in the sequence.
#   • PROJECT_MANIFESTO (step 1) is always included implicitly for docs that
#     need the project "identity" (name, vision, domain).
#   • Keeping this static means zero latency and no external service required.
#   • Future evolution: replace filtering with semantic retrieval over a
#     per-project ChromaDB collection once the vector-store layer is live.
# ---------------------------------------------------------------------------
CONTEXT_DEPENDENCIES: dict[str, list[str]] = {
    # Phase 1: Context
    "PROJECT_MANIFESTO": [],
    "DOMAIN_LANGUAGE": ["PROJECT_MANIFESTO"],
    "USER_JOURNEY_MAP": ["PROJECT_MANIFESTO", "DOMAIN_LANGUAGE"],
    # Phase 2: Requirements
    "REQUIREMENTS_MASTER": ["PROJECT_MANIFESTO", "USER_JOURNEY_MAP", "DOMAIN_LANGUAGE"],
    "USER_STORIES_MASTER": [
        "PROJECT_MANIFESTO",
        "DOMAIN_LANGUAGE",
        "REQUIREMENTS_MASTER",
    ],
    "SECURITY_PRIVACY_POLICY": ["PROJECT_MANIFESTO", "REQUIREMENTS_MASTER"],
    "COMPLIANCE_MATRIX": ["PROJECT_MANIFESTO", "SECURITY_PRIVACY_POLICY"],
    # Phase 3: Architecture
    "TECH_STACK_DECISION": [
        "PROJECT_MANIFESTO",
        "REQUIREMENTS_MASTER",
        "USER_JOURNEY_MAP",
    ],
    "DATA_MODEL_SCHEMA": [
        "PROJECT_MANIFESTO",
        "REQUIREMENTS_MASTER",
        "TECH_STACK_DECISION",
    ],
    "API_INTERFACE_CONTRACT": [
        "PROJECT_MANIFESTO",
        "REQUIREMENTS_MASTER",
        "DATA_MODEL_SCHEMA",
    ],
    "PROJECT_STRUCTURE_MAP": [
        "TECH_STACK_DECISION",
        "DATA_MODEL_SCHEMA",
        "API_INTERFACE_CONTRACT",
    ],
    "SECURITY_THREAT_MODEL": [
        "PROJECT_MANIFESTO",
        "SECURITY_PRIVACY_POLICY",
        "API_INTERFACE_CONTRACT",
    ],
    "ARCH_DECISION_RECORDS": [
        "PROJECT_MANIFESTO",
        "TECH_STACK_DECISION",
        "DATA_MODEL_SCHEMA",
        "API_INTERFACE_CONTRACT",
    ],
    # Phase 4: UX/UI
    "DESIGN_SYSTEM": ["PROJECT_MANIFESTO", "USER_JOURNEY_MAP", "ARCH_DECISION_RECORDS"],
    "UI_WIREFRAMES_FLOW": ["USER_JOURNEY_MAP", "DESIGN_SYSTEM"],
    "ACCESSIBILITY_GUIDE": ["DESIGN_SYSTEM", "UI_WIREFRAMES_FLOW"],
    # Phase 5: Planning
    "ROADMAP_PHASES": [
        "PROJECT_MANIFESTO",
        "REQUIREMENTS_MASTER",
        "ARCH_DECISION_RECORDS",
    ],
    "DEPLOYMENT_INFRASTRUCTURE": [
        "PROJECT_MANIFESTO",
        "TECH_STACK_DECISION",
        "PROJECT_STRUCTURE_MAP",
    ],
    "CI_CD_PIPELINE": [
        "TECH_STACK_DECISION",
        "PROJECT_STRUCTURE_MAP",
        "DEPLOYMENT_INFRASTRUCTURE",
    ],
    "TESTING_STRATEGY": [
        "PROJECT_MANIFESTO",
        "REQUIREMENTS_MASTER",
        "CI_CD_PIPELINE",
    ],
    # Phase 6: Root / Meta  (synthesise the entire project)
    "RULES": ["PROJECT_MANIFESTO", "TECH_STACK_DECISION", "ARCH_DECISION_RECORDS"],
    "CONTRIBUTING": ["PROJECT_MANIFESTO", "PROJECT_STRUCTURE_MAP", "RULES"],
    "AGENTS": ["PROJECT_MANIFESTO", "TECH_STACK_DECISION", "PROJECT_STRUCTURE_MAP"],
    "README": [
        "PROJECT_MANIFESTO",
        "DOMAIN_LANGUAGE",
        "REQUIREMENTS_MASTER",
        "ARCH_DECISION_RECORDS",
    ],
}


def get_context_dependencies(doc_type: str) -> list[str]:
    """Return the list of prior doc_types needed to generate ``doc_type``.

    Returns an empty list when the doc_type is not registered in the
    dependency graph (e.g. PROJECT_MANIFESTO or an unknown type).
    """
    return CONTEXT_DEPENDENCIES.get(doc_type, [])


def get_step_by_type(doc_type: str) -> WorkflowStep | None:
    """Return the workflow step matching the given doc_type, or None if not found."""
    return next((step for step in MASTER_WORKFLOW if step.doc_type == doc_type), None)


def get_next_step(current_doc_type: str) -> WorkflowStep | None:
    """Return the next sequential workflow step after the given doc_type, or None.

    Returns None when current_doc_type is not found or the last step is reached.
    """
    current_step = get_step_by_type(current_doc_type)
    if not current_step:
        return None

    next_number = current_step.step_number + 1
    return next(
        (step for step in MASTER_WORKFLOW if step.step_number == next_number), None
    )
