import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'character/character_identity.dart';
import 'character/session_character_animation.dart';
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

/// Home 05 is one operational chamber.
///
/// The Level-2 catalogue remains a specification/read-model, but its entries
/// are expandable panels inside this chamber. They are not navigation targets
/// and do not become separate rooms.
class DecisionActionQuarterPage extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback? onOpenHumanDecisionWorkspace;

  const DecisionActionQuarterPage({
    super.key,
    required this.onBack,
    this.onOpenHumanDecisionWorkspace,
  });

  @override
  State<DecisionActionQuarterPage> createState() =>
      _DecisionActionQuarterPageState();
}

class _DecisionActionQuarterPageState
    extends State<DecisionActionQuarterPage> {
  final HumanResidenceStore _store = HumanResidenceStore();

  HumanResidenceRecord? _residence;
  bool _loading = true;
  List<Map<String, dynamic>> _decisions = <Map<String, dynamic>>[];
  List<Map<String, dynamic>> _calendarEvents = <Map<String, dynamic>>[];
  final Set<String> _openPanels = <String>{'decision.planning'};

  static const _parts = <_DecisionPanel>[
    _DecisionPanel('decision.planning', 'Planning Hall', 'Pramon / Bodhex',
        'Turn supported reasoning into inspectable decision options.',
        'Reasoning + evidence', 'Options / plan'),
    _DecisionPanel('decision.tradeoff', 'Trade-Off Observatory', 'Pramon',
        'Expose the available alternatives and their trade-offs.',
        'Options + constraints', 'Trade-off view'),
    _DecisionPanel('decision.contract', 'Action Contract Studio', 'Bodhex',
        'Make the boundary explicit before consequential action.',
        'Accepted option', 'Action contract'),
    _DecisionPanel('decision.contingency', 'Contingency Planning Chamber', 'Pramon',
        'Keep recovery and alternative action plans visible.',
        'Plan + risks', 'Recovery plan'),
    _DecisionPanel('decision.proof', 'Empirical Proof Desk', 'Pramon / Medrus',
        'Connect decision assumptions to available empirical evidence.',
        'Assumption + evidence', 'Proof record'),
    _DecisionPanel('decision.rationale', 'Decision Rationale Archive', 'Pramon',
        'Preserve why the decision exists and what supported it.',
        'Decision record', 'Rationale artifact'),
    _DecisionPanel('decision.peer', 'Peer Review Gate', 'Pramon / Manis',
        'Expose the review checkpoint before consequential action.',
        'Decision option', 'Review state'),
    _DecisionPanel('decision.blast', 'Blast-Radius Control Room', 'Bodhex',
        'Expose action scope and potential impact before execution.',
        'Action contract', 'Risk scope'),
    _DecisionPanel('decision.isolation', 'Subagent Isolation Chamber', 'Bodhex',
        'Expose delegated-work boundaries when delegation is present.',
        'Delegated task', 'Isolation state'),
    _DecisionPanel('decision.dag', 'Execution DAG Observatory', 'Bodhex',
        'Show execution dependencies from available runtime telemetry.',
        'Execution trace', 'Dependency view'),
    _DecisionPanel('decision.budget', 'Resource Budget Observatory', 'Pramon / Bodhex',
        'Show the resource budget attached to the current work.',
        'Budget telemetry', 'Budget view'),
    _DecisionPanel('decision.finops', 'FinOps Control Desk', 'Bodhex',
        'Show cost and resource policy for the current work.',
        'Resource data', 'Cost state'),
    _DecisionPanel('decision.mcp', 'MCP Tool Registry', 'Bodhex',
        'Show tool registrations and their declared scope.',
        'Tool registry', 'Tool inventory'),
    _DecisionPanel('decision.replay', 'Durable Replay Chamber', 'Bodhex',
        'Show checkpoint/replay state supplied by the runtime.',
        'Checkpoint', 'Replay view'),
    _DecisionPanel('decision.circuit', 'Tool Health & Circuit Breaker Wall', 'Bodhex',
        'Show tool health and failure-protection state.',
        'Tool telemetry', 'Health state'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final residence = await _store.load();
      if (!mounted) return;
      setState(() {
        _residence = residence;
        _loading = false;
      });
      if (residence != null) {
        await _loadRuntimeState(residence);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _loadRuntimeState(HumanResidenceRecord residence) async {
    final token = residence.metadata['session_token']?.toString();
    if (token == null || token.isEmpty) return;

    try {
      final decisionsResponse = await http.get(
        Uri.base.resolve(
          '/api/human-decisions?session_token=${Uri.encodeQueryComponent(token)}',
        ),
      ).timeout(const Duration(seconds: 8));
      final calendarResponse = await http.get(
        Uri.base.resolve(
          '/api/human-residence/calendar?session_token=${Uri.encodeQueryComponent(token)}',
        ),
      ).timeout(const Duration(seconds: 8));

      if (!mounted) return;

      final nextDecisions = <Map<String, dynamic>>[];
      if (decisionsResponse.statusCode >= 200 &&
          decisionsResponse.statusCode < 300) {
        final body = jsonDecode(decisionsResponse.body);
        if (body is Map && body['decisions'] is List) {
          nextDecisions.addAll(
            (body['decisions'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item)),
          );
        }
      }

      final nextCalendar = <Map<String, dynamic>>[];
      if (calendarResponse.statusCode >= 200 &&
          calendarResponse.statusCode < 300) {
        final body = jsonDecode(calendarResponse.body);
        if (body is Map && body['events'] is List) {
          nextCalendar.addAll(
            (body['events'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item)),
          );
        }
      }

      setState(() {
        _decisions = nextDecisions;
        _calendarEvents = nextCalendar;
      });
    } catch (error) {
      if (!mounted) return;
    }
  }

  void _toggle(String id) {
    setState(() {
      if (_openPanels.contains(id)) {
        _openPanels.remove(id);
      } else {
        _openPanels.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);
    return Scaffold(
      backgroundColor: theme.page,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _header(theme),
                  const SizedBox(height: 14),
                  _liveMembers(theme),
                  const SizedBox(height: 14),
                  _decisionState(theme),
                  const SizedBox(height: 14),
                  _calendar(theme),
                  const SizedBox(height: 14),
                  _partsGrid(theme),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Return to Civilization',
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'HOME 05 • DECISION & ACTION CHAMBER',
                  style: TextStyle(
                    color: theme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pramon + Bodhex',
                  style: TextStyle(
                    color: theme.text,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Planning → review → action contract → calendar → controlled execution',
                  style: TextStyle(color: theme.mutedText, fontSize: 11),
                ),
              ],
            ),
          ),
          _badge(theme, _loading ? 'SYNCING' : 'OPEN'),
        ],
      ),
    );
  }

  Widget _liveMembers(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          Expanded(child: _member(theme, 'pramon', 'PRAMON', 'Planning • decision structure')),
          const SizedBox(width: 12),
          Expanded(child: _member(theme, 'bodhex', 'BODHEX', 'Action • execution boundary')),
        ],
      ),
    );
  }

  Widget _member(CriterivoxTheme theme, String id, String name, String responsibility) {
    final identity = CharacterIdentities.resolve(id);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.border),
      ),
      child: Row(
        children: [
          SessionCharacterAnimationView(
            characterId: id,
            state: 'WORKING',
            width: 72,
            height: 92,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(color: theme.text, fontWeight: FontWeight.w900)),
                Text(identity.role, style: TextStyle(color: theme.primary, fontSize: 9)),
                const SizedBox(height: 5),
                Text(responsibility, style: TextStyle(color: theme.mutedText, fontSize: 10)),
                const SizedBox(height: 7),
                Text(
                  'ACTIVE • responsibility surface',
                  style: TextStyle(color: theme.success, fontSize: 8, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _decisionState(CriterivoxTheme theme) {
    final latest = _decisions.isEmpty ? null : _decisions.first;
    return _panel(
      theme,
      'CURRENT DECISION STATE',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (latest == null)
            Text(
              'No saved decision is currently available from the Human Residence.',
              style: TextStyle(color: theme.mutedText, fontSize: 11),
            )
          else ...[
            Text(
              '${latest['title'] ?? 'Decision'}',
              style: TextStyle(color: theme.text, fontSize: 17, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 5),
            Text(
              'Goal: ${latest['goal'] ?? 'not supplied'}',
              style: TextStyle(color: theme.mutedText, fontSize: 10),
            ),
            const SizedBox(height: 8),
            _stateLine(theme, 'Decision ID', latest['decision_id'] ?? latest['id'] ?? 'recorded'),
            _stateLine(theme, 'Status', latest['status'] ?? latest['state'] ?? 'recorded'),
            _stateLine(theme, 'Updated', latest['updated_at'] ?? latest['created_at'] ?? 'local'),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (widget.onOpenHumanDecisionWorkspace != null)
                OutlinedButton.icon(
                  onPressed: widget.onOpenHumanDecisionWorkspace,
                  icon: const Icon(Icons.home_work_outlined, size: 16),
                  label: const Text('Open Human Decision Workspace'),
                ),
              OutlinedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Refresh state'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _calendar(CriterivoxTheme theme) {
    return _panel(
      theme,
      'CRITERIVOX CALENDAR • ACCEPTED WORK',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The calendar is the execution bridge. Acceptance creates a scheduled event; authorization changes that event to controlled execution.',
            style: TextStyle(color: theme.mutedText, fontSize: 10, height: 1.4),
          ),
          const SizedBox(height: 10),
          if (_calendarEvents.isEmpty)
            Text(
              'No scheduled decision work yet.',
              style: TextStyle(color: theme.mutedText, fontSize: 10),
            )
          else
            ..._calendarEvents.take(8).map(
              (event) => Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.surfaceStrong,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.event_available_rounded, color: theme.primary, size: 18),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        '${event['title'] ?? 'Decision work'} • ${event['starts_at'] ?? ''}',
                        style: TextStyle(color: theme.text, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ),
                    _badge(theme, '${event['status'] ?? 'scheduled'}'),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _partsGrid(CriterivoxTheme theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'CHAMBER PARTS • LEVEL 2 RESPONSIBILITIES',
          style: TextStyle(
            color: theme.primary,
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        ..._parts.map((part) => _part(theme, part)),
      ],
    );
  }

  Widget _part(CriterivoxTheme theme, _DecisionPanel part) {
    final open = _openPanels.contains(part.id);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => _toggle(part.id),
            child: Padding(
              padding: const EdgeInsets.all(13),
              child: Row(
                children: [
                  Icon(
                    open ? Icons.keyboard_arrow_down_rounded : Icons.chevron_right_rounded,
                    color: theme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(part.name, style: TextStyle(color: theme.text, fontWeight: FontWeight.w800)),
                        Text(
                          '${part.owner} • ${part.purpose}',
                          style: TextStyle(color: theme.mutedText, fontSize: 9),
                        ),
                      ],
                    ),
                  ),
                  _badge(theme, 'PART OF CHAMBER'),
                ],
              ),
            ),
          ),
          if (open)
            Padding(
              padding: const EdgeInsets.fromLTRB(46, 0, 13, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.surfaceStrong,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _stateLine(theme, 'Input', part.input),
                    _stateLine(theme, 'Output', part.output),
                    _partEvidence(theme, part.id),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _partEvidence(CriterivoxTheme theme, String id) {
    if (_residence == null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text(
          'This panel is connected to the chamber model and has no Human Residence state yet.',
          style: TextStyle(color: theme.mutedText, fontSize: 9),
        ),
      );
    }

    final metadata = _residence!.metadata;
    String value;
    if (id == 'decision.planning') {
      value = _decisions.isEmpty
          ? 'Planning state: waiting for a decision artifact.'
          : 'Planning state: decision artifact available.';
    } else if (id == 'decision.rationale') {
      value = 'Rationale is retained with the decision record and its event history.';
    } else if (id == 'decision.contract') {
      value = _calendarEvents.isEmpty
          ? 'Action contract: no accepted calendar event yet.'
          : 'Action contract: accepted work is represented by calendar state.';
    } else if (id == 'decision.dag' || id == 'decision.replay' || id == 'decision.circuit') {
      value = 'Runtime telemetry: shown only when the execution runtime supplies it.';
    } else if (id == 'decision.budget' || id == 'decision.finops') {
      value = 'Resource telemetry: no invented values are displayed.';
    } else if (id == 'decision.mcp') {
      value = 'Tool scope: inspected from runtime/tool state when available.';
    } else if (id == 'decision.peer') {
      value = 'Review state: Human challenge is recorded before acceptance.';
    } else if (id == 'decision.tradeoff') {
      final tradeoff = metadata['last_tradeoff'];
      value = tradeoff is Map ? 'Current trade-off: $tradeoff' : 'Trade-off state is retained in the Human Residence.';
    } else if (id == 'decision.blast') {
      value = 'Impact boundary: execution remains gated by accepted calendar state.';
    } else if (id == 'decision.isolation') {
      value = 'Delegation boundary: no delegated execution is claimed unless runtime reports it.';
    } else if (id == 'decision.contingency') {
      value = 'Recovery: accepted strategy retains rollback/checkpoint intent where supplied.';
    } else if (id == 'decision.proof') {
      value = 'Evidence: decision trace may include supplied and externally researched sources.';
    } else {
      value = 'State is represented through the shared decision and calendar records.';
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        value,
        style: TextStyle(color: theme.mutedText, fontSize: 9, height: 1.4),
      ),
    );
  }

  Widget _panel(CriterivoxTheme theme, String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: theme.primary, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1),
          ),
          const SizedBox(height: 9),
          child,
        ],
      ),
    );
  }

  Widget _stateLine(CriterivoxTheme theme, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        '$label: $value',
        style: TextStyle(color: theme.mutedText, fontSize: 9),
      ),
    );
  }

  Widget _badge(CriterivoxTheme theme, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: theme.border),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: theme.mutedText, fontSize: 7, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _DecisionPanel {
  final String id;
  final String name;
  final String owner;
  final String purpose;
  final String input;
  final String output;

  const _DecisionPanel(
    this.id,
    this.name,
    this.owner,
    this.purpose,
    this.input,
    this.output,
  );
}
