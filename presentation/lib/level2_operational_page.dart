import 'package:flutter/material.dart';

import 'foundation/criterivox_responsive_scene.dart';
import 'foundation/criterivox_status.dart';
import 'semantic_visualizations.dart';

class CriterivoxTheme {
  final Color page;
  final Color surface;
  final Color surfaceStrong;
  final Color border;
  final Color primary;
  final Color mutedText;
  final Color text;
  final Color warning;

  const CriterivoxTheme({
    required this.page,
    required this.surface,
    required this.surfaceStrong,
    required this.border,
    required this.primary,
    required this.mutedText,
    required this.text,
    required this.warning,
  });

  factory CriterivoxTheme.of(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return CriterivoxTheme(
      page: colors.surface,
      surface: colors.surfaceContainer,
      surfaceStrong: colors.surfaceContainerHighest,
      border: colors.outline,
      primary: colors.primary,
      mutedText: colors.onSurfaceVariant,
      text: colors.onSurface,
      warning: colors.error,
    );
  }
}

enum Level2Truth {
  live,
  functionallyImplemented,
  simulated,
  staticPresentation,
  planned,
  researchPrototype,
  unavailable,
}

class Level2RoomSpec {
  final String id;
  final String name;
  final String home;
  final String owner;
  final String purpose;
  final String input;
  final String output;
  final String interaction;
  final Level2Truth truth;

  const Level2RoomSpec({
    required this.id,
    required this.name,
    required this.home,
    required this.owner,
    required this.purpose,
    required this.input,
    required this.output,
    required this.interaction,
    required this.truth,
  });
}

class Level2Catalog {
  Level2Catalog._();

  static const rooms = <Level2RoomSpec>[
    // Part II — Gateway.
    Level2RoomSpec(
      id: 'gateway.intent',
      name: 'Intent Dispatcher & Routing Matrix',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Disambiguate intent and expose an explicit routing/read-model path.',
      input: 'Human intent',
      output: 'Task framing / route',
      interaction: 'Inspect route',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'gateway.output',
      name: 'Adaptive Human-Centric Output Renderer',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Present results in a task-appropriate human-facing form.',
      input: 'Result/read model',
      output: 'Summary, detail or structured view',
      interaction: 'Change presentation depth',
      truth: Level2Truth.live,
    ),
    Level2RoomSpec(
      id: 'gateway.steering',
      name: 'Mid-Flight Human-in-the-Loop Steering',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Provide intervention controls only where runtime contracts permit them.',
      input: 'Active task',
      output: 'Authorized intervention',
      interaction: 'Inspect available controls',
      truth: Level2Truth.live,
    ),
    Level2RoomSpec(
      id: 'gateway.telemetry',
      name: 'System Telemetry & Silence Translator',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Translate real execution state into concise progress information.',
      input: 'Runtime events',
      output: 'Human-readable status',
      interaction: 'Inspect state',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'gateway.branches',
      name: 'Dialogue History & Conversation Branch Management',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Preserve conversation context and supported branches.',
      input: 'Conversation state',
      output: 'Inspectable history',
      interaction: 'Review branch',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'gateway.multimodal',
      name: 'Multi-Modal Reception & Payload Ingestion',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Receive supported payload classes through the actual ingestion boundary.',
      input: 'Text / files / supported media',
      output: 'Validated input',
      interaction: 'Inspect intake state',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'gateway.dynamic-ui',
      name: 'Dynamic UI Intent Synthesizer',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Render structured presentation components when task context calls for them.',
      input: 'Task/read model',
      output: 'Presentation surface',
      interaction: 'Inspect generated surface',
      truth: Level2Truth.live,
    ),
    Level2RoomSpec(
      id: 'gateway.guardrails',
      name: 'Systemic Safety & Guardrail Inspector',
      home: 'gateway',
      owner: 'Syvax',
      purpose:
          'Expose interaction-layer safety and boundary decisions without moving enforcement into UI.',
      input: 'Boundary decision',
      output: 'Inspectable safety state',
      interaction: 'Inspect check',
      truth: Level2Truth.planned,
    ),

    // Part II — Data Stewardship.
    Level2RoomSpec(
      id: 'data.readiness',
      name: 'Dynamic Data Readiness Profiling',
      home: 'data',
      owner: 'Sandre',
      purpose:
          'Assess whether supplied data is ready for downstream use.',
      input: 'Data foundation',
      output: 'Readiness profile',
      interaction: 'Inspect readiness',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'data.pipeline',
      name: 'Kaelen’s Pipeline Construction Canvas',
      home: 'data',
      owner: 'Kaelen',
      purpose:
          'Expose data transformation and pipeline construction.',
      input: 'Schema / transformation plan',
      output: 'Pipeline representation',
      interaction: 'Inspect pipeline',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'data.lineage',
      name: 'Epistemic Data Lineage & Provenance Ledger',
      home: 'data',
      owner: 'Sandre',
      purpose:
          'Make data origin and transformation lineage inspectable.',
      input: 'Data events',
      output: 'Lineage record',
      interaction: 'Trace source',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'data.cache',
      name: 'Synthetic Data & Edge Caching',
      home: 'data',
      owner: 'Sandre / Kaelen',
      purpose:
          'Represent synthetic fixtures and bounded caching where supported.',
      input: 'Data/cache state',
      output: 'Cached or synthetic dataset',
      interaction: 'Inspect cache status',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'data.semantic',
      name: 'Context Engineering & Semantic Tagging',
      home: 'data',
      owner: 'Sandre',
      purpose:
          'Attach structured metadata useful to downstream context.',
      input: 'Validated data',
      output: 'Semantic tags',
      interaction: 'Inspect metadata',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'data.drift',
      name: 'Schema Drift Interceptor & Repair',
      home: 'data',
      owner: 'Kaelen',
      purpose:
          'Detect and represent schema drift before downstream use.',
      input: 'Schema changes',
      output: 'Drift state / repair proposal',
      interaction: 'Inspect drift',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'data.multimodal',
      name: 'Multimodal Vector/Lakehouse Ingestion',
      home: 'data',
      owner: 'Sandre',
      purpose:
          'Provide a spatial presentation boundary for supported multimodal ingestion.',
      input: 'Supported source payloads',
      output: 'Ingestion record',
      interaction: 'Inspect ingestion',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'data.quality',
      name: 'Evaluation-Driven Data Quality Gates',
      home: 'data',
      owner: 'Sandre / Kaelen',
      purpose:
          'Expose quality gates and their actual state.',
      input: 'Quality evaluation',
      output: 'Gate state',
      interaction: 'Inspect gate',
      truth: Level2Truth.functionallyImplemented,
    ),

    // Part II — Context.
    Level2RoomSpec(
      id: 'context.pruning',
      name: 'Dynamic Context Pruning & Attentive Compression',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Prepare relevant context without silently discarding important state.',
      input: 'Context candidates',
      output: 'Bounded context',
      interaction: 'Inspect selection',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'context.shift',
      name: 'Adaptive Context Shift Interceptor',
      home: 'context',
      owner: 'Anuka',
      purpose:
          'Represent context changes that alter downstream interpretation.',
      input: 'Runtime context shift',
      output: 'Adaptation state',
      interaction: 'Inspect change',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'context.tree',
      name: 'Hierarchical Context Tree & Scope Boundary Map',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Make scope, constraints and context hierarchy visible.',
      input: 'Context structure',
      output: 'Scope map',
      interaction: 'Expand boundary',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'context.replay',
      name: 'Contextual Replay & Shadow Testing',
      home: 'context',
      owner: 'Dharen / Anuka',
      purpose:
          'Inspect context changes in an isolated replay path.',
      input: 'Context snapshot',
      output: 'Replay result',
      interaction: 'Inspect sandbox',
      truth: Level2Truth.live,
    ),
    Level2RoomSpec(
      id: 'context.firewall',
      name: 'Context Clash & Poisoning Firewall',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Expose conflicting or unsafe context before interpretation.',
      input: 'Context candidates',
      output: 'Conflict / quarantine state',
      interaction: 'Inspect rejection',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'context.sandbox',
      name: 'Isolated Execution Sandboxes',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Provide bounded shadow execution for context changes.',
      input: 'Sandbox request',
      output: 'Isolated state',
      interaction: 'Create / run / inspect',
      truth: Level2Truth.live,
    ),
    Level2RoomSpec(
      id: 'context.scratchpad',
      name: 'Persistent Agent Scratchpad & Checkpointing',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Expose supported scratchpad/checkpoint state without inventing persistence guarantees.',
      input: 'Task state',
      output: 'Checkpoint/scratchpad record',
      interaction: 'Inspect checkpoint',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'context.budget',
      name: 'Priority-Tiered Context Budgeting',
      home: 'context',
      owner: 'Dharen',
      purpose:
          'Represent context prioritization and budget constraints.',
      input: 'Context candidates / budget',
      output: 'Priority tiers',
      interaction: 'Inspect allocation',
      truth: Level2Truth.live,
    ),

    // Part III — Knowledge.
    Level2RoomSpec(
      id: 'knowledge.hall',
      name: 'Knowledge Hall',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Entry/read-model for reusable knowledge.',
      input: 'Knowledge state',
      output: 'Inspectable knowledge map',
      interaction: 'Explore knowledge',
      truth: Level2Truth.staticPresentation,
    ),
    Level2RoomSpec(
      id: 'knowledge.trajectory',
      name: 'Trajectory Distillation Workshop',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Distill reusable trajectories while preserving conditions and limitations.',
      input: 'Historical trajectories',
      output: 'Distilled pattern',
      interaction: 'Inspect derivation',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.ontology',
      name: 'Ontology Weaver',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Represent relationships among concepts without claiming automatic truth.',
      input: 'Concept records',
      output: 'Ontology view',
      interaction: 'Explore relationships',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.transfer',
      name: 'Structural Transfer Chamber',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Inspect bounded transfer of reusable structure between contexts.',
      input: 'Validated pattern',
      output: 'Transfer package',
      interaction: 'Inspect reuse conditions',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.friction',
      name: 'Rule Friction Chamber',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Expose cases where generalized rules meet contradictory evidence.',
      input: 'Rule + evidence',
      output: 'Friction record',
      interaction: 'Inspect conflict',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.skills',
      name: 'Skill Library',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Present reusable skill records and their scope.',
      input: 'Skill metadata',
      output: 'Skill record',
      interaction: 'Inspect scope',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.packaging',
      name: 'Skill Packaging Studio',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Prepare reusable skill artifacts.',
      input: 'Skill definition',
      output: 'Packaged skill',
      interaction: 'Inspect package',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.mutation',
      name: 'Ontology Mutation Observatory',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Track proposed ontology changes with evidence boundaries.',
      input: 'Ontology change',
      output: 'Mutation proposal',
      interaction: 'Inspect change',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.schema',
      name: 'Schema Translation Terminal',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Represent schema translation across knowledge boundaries.',
      input: 'Schema pair',
      output: 'Translation result',
      interaction: 'Inspect mapping',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.utility',
      name: 'Knowledge Utility Observatory',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Expose evidence-backed knowledge utility signals.',
      input: 'Reuse outcomes',
      output: 'Utility view',
      interaction: 'Inspect signal',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.decay',
      name: 'Skill Health & Decay Observatory',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Make aging and scope decay visible.',
      input: 'Skill history',
      output: 'Health/decay state',
      interaction: 'Inspect history',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.memsync',
      name: 'MemSync Persistence Chamber',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Represent cross-session knowledge persistence boundaries.',
      input: 'Knowledge record',
      output: 'Persistence state',
      interaction: 'Inspect retention',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.garden',
      name: 'Hierarchical Skill Garden',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Explore skills by hierarchy and scope.',
      input: 'Skill graph',
      output: 'Hierarchical view',
      interaction: 'Navigate hierarchy',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.policy',
      name: 'Reflection & Policy Evolution Chamber',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Expose reflection-driven policy proposals without treating proposals as authority.',
      input: 'Outcome/reflection records',
      output: 'Policy proposal',
      interaction: 'Inspect proposal',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'knowledge.versioning',
      name: 'Schema Versioning Archive',
      home: 'knowledge',
      owner: 'Viveda',
      purpose:
          'Preserve ontology/schema history.',
      input: 'Schema versions',
      output: 'Version history',
      interaction: 'Compare versions',
      truth: Level2Truth.functionallyImplemented,
    ),

    // Part III — Challenge & Review.
    Level2RoomSpec(
      id: 'challenge.hall',
      name: 'Challenge Hall',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Entry point for structured human challenge.',
      input: 'Decision/reasoning state',
      output: 'Challenge surface',
      interaction: 'Inspect challenge state',
      truth: Level2Truth.staticPresentation,
    ),
    Level2RoomSpec(
      id: 'challenge.assumption',
      name: 'Assumption Stress Chamber',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Stress-test explicit assumptions.',
      input: 'Assumptions',
      output: 'Challenge findings',
      interaction: 'Inspect assumption',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.intent',
      name: 'Intent Realignment Chamber',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Expose divergence between human intent and system framing.',
      input: 'Goal / framing',
      output: 'Realignment proposal',
      interaction: 'Review framing',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.socratic',
      name: 'Socratic Friction Gate',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Turn disagreement into an explicit inspection point.',
      input: 'Claim / decision',
      output: 'Questions / challenge record',
      interaction: 'Challenge premise',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.dogma',
      name: 'Anti-Dogma Knowledge Audit',
      home: 'challenge',
      owner: 'Manis ↔ Viveda',
      purpose:
          'Stress generalized knowledge against evidence and context.',
      input: 'Knowledge rule',
      output: 'Audit finding',
      interaction: 'Inspect audit',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.sycophancy',
      name: 'Anti-Sycophancy Observatory',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Represent disagreement and unsupported agreement risks.',
      input: 'Interaction trace',
      output: 'Oversight signal',
      interaction: 'Inspect signal',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.drift',
      name: 'Multi-Turn Adversarial Drift Chamber',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Expose changes in behavior across turns.',
      input: 'Conversation trace',
      output: 'Drift finding',
      interaction: 'Inspect turns',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.bias',
      name: 'Automation Bias Interrupter',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Create a deliberate pause before human acceptance.',
      input: 'Recommendation',
      output: 'Intervention point',
      interaction: 'Challenge / pause',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.generalization',
      name: 'Rule Generalization Stress-Test Canvas',
      home: 'challenge',
      owner: 'Manis ↔ Viveda',
      purpose:
          'Test whether a rule survives varied contexts.',
      input: 'Rule + scenarios',
      output: 'Stress-test result',
      interaction: 'Inspect scenarios',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.crm',
      name: 'CRM-Style Challenge Protocol',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Structure human oversight records.',
      input: 'Challenge request',
      output: 'Oversight record',
      interaction: 'Create challenge',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.sme',
      name: 'SME Metric Alignment Chamber',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Align system measures with domain-expert concerns.',
      input: 'Expert criteria',
      output: 'Alignment record',
      interaction: 'Inspect criteria',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.tools',
      name: 'Tool Misuse & Scope Observatory',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Expose inappropriate tool or scope use.',
      input: 'Tool trace',
      output: 'Scope finding',
      interaction: 'Inspect trace',
      truth: Level2Truth.functionallyImplemented,
    ),
    Level2RoomSpec(
      id: 'challenge.vigilance',
      name: 'Operator Vigilance Observatory',
      home: 'challenge',
      owner: 'Manis',
      purpose:
          'Support human awareness of system limits and interventions.',
      input: 'Oversight state',
      output: 'Vigilance view',
      interaction: 'Inspect status',
      truth: Level2Truth.functionallyImplemented,
    ),

    // Part IV — Intelligence.
    Level2RoomSpec(
      id: 'reasoning.hypothesis',
      name: 'Hypothesis Workshop',
      home: 'reasoning',
      owner: 'Tarkis',
      purpose:
          'Explore alternative hypotheses from bounded inputs.',
      input: 'Question / context',
      output: 'Hypotheses',
      interaction: 'Inspect alternatives',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.debate',
      name: 'Adversarial Debate Arena',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Expose objections and competing interpretations.',
      input: 'Reasoning state',
      output: 'Evaluation artifacts',
      interaction: 'Inspect objections',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.audit',
      name: 'Epistemic Audit Chamber',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Inspect assumptions, evidence quality and limitations.',
      input: 'Reasoning artifacts',
      output: 'Audit findings',
      interaction: 'Inspect audit',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.search',
      name: 'Reasoning Search Observatory',
      home: 'reasoning',
      owner: 'Vivren / Tarkis',
      purpose:
          'Expose bounded reasoning search and branch selection.',
      input: 'Reasoning graph',
      output: 'Search state',
      interaction: 'Inspect branch',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.counterfactual',
      name: 'Counterfactual Simulation Deck',
      home: 'reasoning',
      owner: 'Tarkis',
      purpose:
          'Explore alternative scenarios without treating simulation as observed reality.',
      input: 'Hypothesis + scenario',
      output: 'Counterfactual result',
      interaction: 'Compare scenario',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.supervision',
      name: 'Process Supervision Gallery',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Present reasoning stage state and permitted trace metadata.',
      input: 'S7 events/artifacts',
      output: 'Process view',
      interaction: 'Inspect stage',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.boundary',
      name: 'Epistemic Boundary Gate',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Mark where evidence is insufficient or interpretation must stop.',
      input: 'Evaluation',
      output: 'Boundary state',
      interaction: 'Inspect limitation',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.reflexion',
      name: 'Reflexion Ledger',
      home: 'reasoning',
      owner: 'Vivren / Tarkis',
      purpose:
          'Preserve bounded reasoning reflections and revisions.',
      input: 'Reasoning result',
      output: 'Reflection record',
      interaction: 'Inspect revision',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.handoff',
      name: 'Handoff Integrity Gate',
      home: 'reasoning',
      owner: 'Vivren / Tarkis',
      purpose:
          'Expose the boundary between reasoning output and downstream use.',
      input: 'Reasoning artifact',
      output: 'Handoff state',
      interaction: 'Inspect lineage',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.goal',
      name: 'Goal Alignment Observatory',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Compare reasoning activity with the stated goal.',
      input: 'Goal + reasoning',
      output: 'Alignment view',
      interaction: 'Inspect alignment',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.logic',
      name: 'Formal Logic Studio',
      home: 'reasoning',
      owner: 'Vivren',
      purpose:
          'Present structured logical checks where implemented.',
      input: 'Claims / structure',
      output: 'Logic findings',
      interaction: 'Inspect check',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'reasoning.conflict',
      name: 'Conflict Resolution Chamber',
      home: 'reasoning',
      owner: 'Vivren / Tarkis',
      purpose:
          'Make unresolved reasoning conflicts explicit.',
      input: 'Competing artifacts',
      output: 'Conflict state',
      interaction: 'Compare alternatives',
      truth: Level2Truth.researchPrototype,
    ),

    // Part IV — Decision & Action.
    Level2RoomSpec(
      id: 'decision.planning',
      name: 'Planning Hall',
      home: 'decision',
      owner: 'Pramon / Bodhex',
      purpose:
          'Transform supported reasoning into inspectable decision options.',
      input: 'Reasoning + evidence',
      output: 'Options / plan',
      interaction: 'Inspect plan',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.tradeoff',
      name: 'Trade-Off Observatory',
      home: 'decision',
      owner: 'Pramon',
      purpose:
          'Expose alternative decisions and their trade-offs.',
      input: 'Options + constraints',
      output: 'Trade-off view',
      interaction: 'Compare options',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.contract',
      name: 'Action Contract Studio',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Represent the explicit boundary before consequential action.',
      input: 'Approved option',
      output: 'Action contract',
      interaction: 'Inspect scope',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.contingency',
      name: 'Contingency Planning Chamber',
      home: 'decision',
      owner: 'Pramon',
      purpose:
          'Represent recovery and alternative action plans.',
      input: 'Plan + risks',
      output: 'Contingency plan',
      interaction: 'Inspect recovery',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.proof',
      name: 'Empirical Proof Desk',
      home: 'decision',
      owner: 'Pramon / Medrus',
      purpose:
          'Connect decision assumptions to empirical evidence.',
      input: 'Assumption + evidence',
      output: 'Proof record',
      interaction: 'Inspect support',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.rationale',
      name: 'Decision Rationale Archive',
      home: 'decision',
      owner: 'Pramon',
      purpose:
          'Preserve the rationale behind a decision.',
      input: 'Decision record',
      output: 'Rationale artifact',
      interaction: 'Inspect rationale',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.peer',
      name: 'Peer Review Gate',
      home: 'decision',
      owner: 'Pramon / Manis',
      purpose:
          'Provide a review checkpoint before consequential action.',
      input: 'Decision option',
      output: 'Review state',
      interaction: 'Inspect review',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.blast',
      name: 'Blast-Radius Control Room',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Expose scope and potential impact before execution.',
      input: 'Action contract',
      output: 'Risk scope',
      interaction: 'Inspect impact',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.isolation',
      name: 'Subagent Isolation Chamber',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Represent isolation boundaries for delegated work.',
      input: 'Delegated task',
      output: 'Isolation state',
      interaction: 'Inspect boundary',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.dag',
      name: 'Execution DAG Observatory',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Present actual execution dependencies where telemetry exists.',
      input: 'Execution trace',
      output: 'DAG view',
      interaction: 'Inspect dependency',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.budget',
      name: 'Resource Budget Observatory',
      home: 'decision',
      owner: 'Pramon / Bodhex',
      purpose:
          'Display actual resource budget state when exposed by runtime.',
      input: 'Budget telemetry',
      output: 'Budget view',
      interaction: 'Inspect usage',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.finops',
      name: 'FinOps Control Desk',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Expose cost/resource policy when implemented.',
      input: 'Resource data',
      output: 'Cost state',
      interaction: 'Inspect policy',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.mcp',
      name: 'MCP Tool Registry',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Present supported tool registrations and scope.',
      input: 'Tool registry',
      output: 'Tool inventory',
      interaction: 'Inspect tool',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.replay',
      name: 'Durable Replay Chamber',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Present replay/checkpoint state only when runtime supplies it.',
      input: 'Checkpoint',
      output: 'Replay view',
      interaction: 'Inspect replay',
      truth: Level2Truth.planned,
    ),
    Level2RoomSpec(
      id: 'decision.circuit',
      name: 'Tool Health & Circuit Breaker Wall',
      home: 'decision',
      owner: 'Bodhex',
      purpose:
          'Expose actual tool health and failure protection.',
      input: 'Tool telemetry',
      output: 'Health state',
      interaction: 'Inspect failure state',
      truth: Level2Truth.planned,
    ),

    // Part V — Evidence & Experiment.
    Level2RoomSpec(
      id: 'evidence.hall',
      name: 'Evidence Hall',
      home: 'evidence',
      owner: 'Medrus',
      purpose:
          'Entry point for claims, observations and evidence artifacts.',
      input: 'Claim / observation',
      output: 'Evidence view',
      interaction: 'Inspect claim',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.grounding',
      name: 'Grounding Matrix Chamber',
      home: 'evidence',
      owner: 'Veridat',
      purpose:
          'Relate claims to available supporting evidence.',
      input: 'Claim + evidence',
      output: 'Grounding state',
      interaction: 'Inspect support',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.provenance',
      name: 'Provenance Workshop',
      home: 'evidence',
      owner: 'Epistre',
      purpose:
          'Trace source, transformation and artifact lineage.',
      input: 'Artifact lineage',
      output: 'Provenance tree',
      interaction: 'Trace lineage',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.temporal',
      name: 'Temporal Memory Vault',
      home: 'evidence',
      owner: 'Medrus',
      purpose:
          'Separate historical/event time from recording/system time.',
      input: 'Historical records',
      output: 'Temporal view',
      interaction: 'Compare history',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.contradiction',
      name: 'Contradiction Reconciliation Chamber',
      home: 'evidence',
      owner: 'Veridat ↔ Medrus',
      purpose:
          'Compare conflicting claims without assuming the newest is true.',
      input: 'Conflicting claims',
      output: 'Reconciliation state',
      interaction: 'Inspect conflict',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.receipt',
      name: 'Receipt & Artifact Vault',
      home: 'evidence',
      owner: 'Medrus / Epistre',
      purpose:
          'Inspect artifact identifiers, receipts and integrity metadata where implemented.',
      input: 'Artifact/receipt',
      output: 'Integrity state',
      interaction: 'Inspect receipt',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.bitemporal',
      name: 'Bi-Temporal Truth Observatory',
      home: 'evidence',
      owner: 'Veridat',
      purpose:
          'Inspect historical and current validity without erasing history.',
      input: 'Temporal records',
      output: 'Truth timeline',
      interaction: 'Compare states',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.retrieval',
      name: 'Retrieval Mode Chamber',
      home: 'evidence',
      owner: 'Veridat / Epistre',
      purpose:
          'Distinguish implemented retrieval modes from deterministic semantic execution.',
      input: 'Retrieval trace',
      output: 'Mode badge',
      interaction: 'Inspect retrieval',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.dossier',
      name: 'Provenance Dossier Desk',
      home: 'evidence',
      owner: 'Epistre',
      purpose:
          'Package inspectable evidence and provenance into a dossier.',
      input: 'Evidence set',
      output: 'Dossier artifact',
      interaction: 'Inspect dossier',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.consolidation',
      name: 'Memory Consolidation Observatory',
      home: 'evidence',
      owner: 'Medrus',
      purpose:
          'Make memory maintenance state visible without cosmetic deletion of facts.',
      input: 'Memory records',
      output: 'Consolidation state',
      interaction: 'Inspect maintenance',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.integrity',
      name: 'Memory Integrity & Isolation Chamber',
      home: 'evidence',
      owner: 'Medrus + Veridat',
      purpose:
          'Represent authorization, contradiction and quarantine state around memory writes.',
      input: 'Memory write',
      output: 'Approval/quarantine state',
      interaction: 'Inspect boundary',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.tenant',
      name: 'Tenant Security Observatory',
      home: 'evidence',
      owner: 'Medrus',
      purpose:
          'Expose retrieval scope and role boundaries when actually enforced.',
      input: 'Authorization scope',
      output: 'Access state',
      interaction: 'Inspect scope',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.entropy',
      name: 'Semantic Entropy & Drift Observatory',
      home: 'evidence',
      owner: 'Veridat',
      purpose:
          'Expose supported uncertainty/drift evaluation without decorative metrics.',
      input: 'Evaluation output',
      output: 'Uncertainty/drift state',
      interaction: 'Inspect metric definition',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.attribution',
      name: 'Line-Level Attribution Studio',
      home: 'evidence',
      owner: 'Epistre',
      purpose:
          'Link claims to the finest available source unit.',
      input: 'Claim + source',
      output: 'Attribution map',
      interaction: 'Inspect source range',
      truth: Level2Truth.researchPrototype,
    ),
    Level2RoomSpec(
      id: 'evidence.transfer',
      name: 'Evidence-to-Knowledge Transfer Gate',
      home: 'evidence',
      owner: 'Medrus / Epistre / Veridat → Viveda',
      purpose:
          'Separate verified evidence from generalized reusable knowledge.',
      input: 'Validated finding',
      output: 'Transfer package',
      interaction: 'Inspect reuse conditions',
      truth: Level2Truth.researchPrototype,
    ),
  ];

  static List<Level2RoomSpec> forHome(String home) {
    return rooms.where((r) => r.home == home).toList(growable: false);
  }

  static const homeNames = <String, String>{
    'gateway': 'Gateway Quarter · Syvax',
    'data': 'Data Stewardship Quarter · Sandre / Kaelen',
    'context': 'Context Quarter · Dharen / Anuka',
    'reasoning': 'Intelligence Quarter · Vivren / Tarkis',
    'decision': 'Decision & Challenge Quarter · Pramon / Bodhex / Manis',
    'evidence': 'Evidence & Experiment Quarter · Medrus / Epistre / Veridat',
    'knowledge': 'Knowledge Quarter · Viveda',
  };
}

class Level2OperationalPage extends StatefulWidget {
  final String homeId;
  final String? initialRoom;
  final VoidCallback onBack;
  final ValueChanged<String>? onEnterRoom;

  const Level2OperationalPage({
    super.key,
    required this.homeId,
    required this.onBack,
    this.initialRoom,
    this.onEnterRoom,
  });

  @override
  State<Level2OperationalPage> createState() =>
      _Level2OperationalPageState();
}

class _Level2OperationalPageState extends State<Level2OperationalPage> {
  String? selectedRoomId;

  @override
  void initState() {
    super.initState();
    selectedRoomId = widget.initialRoom;
  }

  @override
  Widget build(BuildContext context) {
    final rooms = Level2Catalog.forHome(widget.homeId);

    Level2RoomSpec? selected;

    for (final room in rooms) {
      if (room.id == selectedRoomId) {
        selected = room;
        break;
      }
    }

    if (selected == null && selectedRoomId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        if (selectedRoomId != null) {
          setState(() {
            selectedRoomId = null;
          });
        }
      });
    }



    final theme = CriterivoxTheme.of(context);
    final responsive =
        CriterivoxResponsive(MediaQuery.sizeOf(context).width);

    final homeName =
        Level2Catalog.homeNames[widget.homeId] ?? 'Operational Home';

    return Scaffold(
      backgroundColor: theme.page,
      body: SafeArea(
        child: CriterivoxResponsiveScene(
          child: SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Return to Home',
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GATE 1 · LEVEL 2 · OPERATIONAL HOME',
                          style: TextStyle(
                            color: theme.primary,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.3,
                          ),
                        ),
                        Text(
                          homeName,
                          style: TextStyle(
                            color: theme.text,
                            fontSize: responsive.isCompact ? 21 : 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'World → Home → Room → Responsibility → Artifact / inspection',
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  CriterivoxStatusBadge(
                    status: rooms.isEmpty
                        ? CriterivoxStatus.unavailable
                        : CriterivoxStatus.ready,
                    detail: '${rooms.length} documented rooms',
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CriterivoxSemanticVisuals.status(
                context,
                label: 'Operational home state',
                detail: rooms.isEmpty ? 'Unavailable' : 'Documented',
                active: rooms.isNotEmpty,
              ),
              CriterivoxSemanticVisuals.progress(
                context,
                label: 'Documented responsibilities',
                completed: rooms.length,
                total: rooms.length,
              ),
              CriterivoxSemanticVisuals.table(
                context,
                title: 'Room responsibility register',
                columns: const ['Room', 'Owner', 'Input', 'Output'],
                rows: [
                  for (final room in rooms)
                    [room.name, room.owner, room.input, room.output],
                ],
              ),
              if (selected != null) ...[
                CriterivoxSemanticVisuals.cards(
                  context,
                  title: 'Responsibility inspection',
                  items: [
                    MapEntry('Purpose', selected.purpose),
                    MapEntry('Interaction', selected.interaction),
                    MapEntry('Truth boundary', selected.truth.name),
                  ],
                ),
              ],
              if (widget.homeId == 'evidence')
                CriterivoxSemanticVisuals.evidenceChain(context),
              if (widget.homeId == 'decision')
                CriterivoxSemanticVisuals.decisionStructure(context),
              if (widget.homeId == 'knowledge')
                CriterivoxSemanticVisuals.network(
                  context,
                  title: 'Knowledge relationship surface',
                  relationships: const [
                    SemanticRelationship('viveda', 'medrus', 'knowledge ← retained evidence'),
                  ],
                ),
              if (widget.homeId == 'context')
                CriterivoxSemanticVisuals.timeline(
                  context,
                  title: 'Context inspection sequence',
                  items: const [
                    SemanticTimelineItem('Context', 'Current situation and scope.'),
                    SemanticTimelineItem('Adaptation', 'Context shifts are inspected explicitly.'),
                    SemanticTimelineItem('Boundary', 'Conflicts and scope limits remain visible.'),
                  ],
                ),
              if (widget.homeId == 'reasoning')
                CriterivoxSemanticVisuals.network(
                  context,
                  title: 'Reasoning dependency surface',
                  relationships: const [
                    SemanticRelationship('dharen', 'vivren', 'context → reasoning'),
                    SemanticRelationship('tarkis', 'medrus', 'hypothesis → evidence'),
                  ],
                ),
              if (widget.homeId == 'gateway')
                CriterivoxSemanticVisuals.timeline(
                  context,
                  title: 'Interaction flow',
                  items: const [
                    SemanticTimelineItem('Intent', 'Human intent enters the interaction boundary.'),
                    SemanticTimelineItem('Routing', 'Supported routing/read-model state is inspected.'),
                    SemanticTimelineItem('Output', 'The resulting presentation surface is returned.'),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}