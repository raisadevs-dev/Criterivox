import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class PrivateRoomPage extends StatefulWidget {
  final VoidCallback onWorkspace;

  const PrivateRoomPage({
    super.key,
    required this.onWorkspace,
  });

  @override
  State<PrivateRoomPage> createState() => _PrivateRoomPageState();
}

class _PrivateRoomPageState extends State<PrivateRoomPage> {
  final HumanResidenceStore store = HumanResidenceStore();

  final TextEditingController goal = TextEditingController();
  final TextEditingController data = TextEditingController();
  final TextEditingController contextCtl = TextEditingController();
  final TextEditingController resultCtl = TextEditingController();

  HumanResidenceRecord? residence;

  bool running = false;
  bool actApproved = false;
  bool secondFactor = false;

  String status = 'PRIVATE_ROOM_READY';

  List<String> options = const [];
  List<String> challenges = const [];
  List<Map<String, dynamic>> journal = [];

  final Set<int> challengedIndexes = <int>{};

  double speed = 50;
  double cost = 50;
  double reliability = 50;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    goal.dispose();
    data.dispose();
    contextCtl.dispose();
    resultCtl.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    try {
      final restored = await store.load();

      if (!mounted) {
        return;
      }

      if (restored == null) {
        setState(() {
          status = 'NO_HOUSE_FOUND';
        });
        return;
      }

      final metadata = restored.metadata;
      final rawJournal = metadata['results_journal'];

      final restoredJournal = rawJournal is List
          ? rawJournal
              .whereType<Map>()
              .map(
                (entry) => Map<String, dynamic>.from(entry),
              )
              .toList()
          : <Map<String, dynamic>>[];

      final rawTradeoff = metadata['last_tradeoff'];

      var restoredSpeed = 50.0;
      var restoredCost = 50.0;
      var restoredReliability = 50.0;

      if (rawTradeoff is Map) {
        restoredSpeed = _numberValue(rawTradeoff['speed'], fallback: 50);
        restoredCost = _numberValue(rawTradeoff['cost'], fallback: 50);
        restoredReliability =
            _numberValue(rawTradeoff['reliability'], fallback: 50);
      }

      setState(() {
        residence = restored;

        goal.text = '${metadata['goal'] ?? ''}';
        data.text = '${metadata['data'] ?? ''}';
        contextCtl.text = '${metadata['context'] ?? ''}';

        journal = restoredJournal;

        speed = restoredSpeed.clamp(0, 100).toDouble();
        cost = restoredCost.clamp(0, 100).toDouble();
        reliability = restoredReliability.clamp(0, 100).toDouble();
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        status = 'RESTORE_FAILED • $e';
      });
    }
  }

  double _numberValue(
    dynamic value, {
    required double fallback,
  }) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse('$value') ?? fallback;
  }

  Map<String, dynamic> _metadata({
    required String event,
  }) {
    final currentResidence = residence;

    if (currentResidence == null) {
      return <String, dynamic>{};
    }

    final base = Map<String, dynamic>.from(
      currentResidence.metadata,
    );

    base['rooms'] = <String>[
      'private',
      'collaboration',
    ];

    base['private_room_event'] = event;
    base['goal'] = goal.text.trim();
    base['data'] = data.text.trim();
    base['context'] = contextCtl.text.trim();

    base['last_tradeoff'] = <String, int>{
      'speed': speed.round(),
      'cost': cost.round(),
      'reliability': reliability.round(),
    };

    base['results_journal'] = journal;

    return base;
  }

  Future<void> _persist(String event) async {
    final currentResidence = residence;

    if (currentResidence == null) {
      return;
    }

    final updated = HumanResidenceRecord(
      residenceId: currentResidence.residenceId,
      ownerId: currentResidence.ownerId,
      displayName: currentResidence.displayName,
      email: currentResidence.email,
      residenceType: currentResidence.residenceType,
      createdAt: currentResidence.createdAt,
      members: currentResidence.members,
      metadata: _metadata(event: event),
    );

    await store.save(updated);

    if (!mounted) {
      return;
    }

    setState(() {
      residence = updated;
    });

    try {
      final response = await http
          .post(
            Uri.base.resolve('/api/human-residence'),
            headers: const <String, String>{
              'content-type': 'application/json',
            },
            body: jsonEncode(updated.toJson()),
          )
          .timeout(
            const Duration(seconds: 4),
          );

      if (!mounted) {
        return;
      }

      if (response.statusCode >= 400) {
        setState(() {
          status = 'SAVED LOCALLY • IndexedDB authoritative • '
              'Python mirror rejected update';
        });
        return;
      }

      setState(() {
        status = 'SAVED • IndexedDB authoritative • Python mirror updated';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        status = 'SAVED LOCALLY • IndexedDB authoritative • '
            'Python mirror unavailable';
      });
    }
  }

  Future<void> _generateOptions() async {
    if (goal.text.trim().isEmpty || running) {
      return;
    }

    final currentResidence = residence;

    if (currentResidence == null) {
      if (mounted) {
        setState(() {
          status = 'NO_HOUSE_FOUND';
        });
      }

      return;
    }

    setState(() {
      running = true;
      status = 'DHAREN + TARKIS + PRAMON • framing and option sparring';
      options = <String>[];
      challenges = <String>[];
      challengedIndexes.clear();
    });

    try {
      final response = await http
          .post(
            Uri.base.resolve('/api/syvax/plan'),
            headers: const <String, String>{
              'content-type': 'application/json',
            },
            body: jsonEncode(
              <String, dynamic>{
                'message': goal.text.trim(),
                'task_id': 'private-${currentResidence.residenceId}',
              },
            ),
          )
          .timeout(
            const Duration(seconds: 6),
          );

      if (response.statusCode >= 400) {
        throw Exception(
          'planning request rejected (${response.statusCode})',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map) {
        throw Exception(
          'planning response was not a JSON object',
        );
      }

      final json = Map<String, dynamic>.from(
        decoded.map(
          (key, value) => MapEntry(
            key.toString(),
            value,
          ),
        ),
      );

      final plan = json['plan'];

      final steps = plan is Map && plan['steps'] is List
          ? plan['steps'] as List
          : const <dynamic>[];

      final executionTrace = steps.take(6).map(
        (step) {
          if (step is Map) {
            final character =
                step['character_id'] ?? step['agent_id'] ?? 'Agent';

            final action =
                step['action'] ?? step['purpose'] ?? 'inspectable contribution';

            return '$character: $action';
          }

          return '$step';
        },
      ).toList();

      final generated = <String>[
        'Option A • High Speed / Higher Risk • '
            'prioritize rapid execution and accept tighter rollback margin.',
        'Option B • Balanced • '
            'trade speed, cost and reliability around your current preference vector.',
        'Option C • Maximum Rigor / Slower Execution • '
            'add validation, evidence checks and larger rollback margin.',
      ];

      if (!mounted) {
        return;
      }

      setState(() {
        options = <String>[
          ...generated,
          if (executionTrace.isNotEmpty)
            'Execution trace: ${executionTrace.join(' → ')}',
        ];

        challenges = <String>[
          'What assumption would break this option first?',
          'What happens if a key constraint changes after execution?',
          'Which evidence would make you reject this path?',
        ];

        running = false;
        status = 'PARETO_READY • challenge before acceptance';
      });

      await _persist('options_generated');
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        running = false;
        status = 'OPTION_GENERATION_PAUSED • $e';
      });
    }
  }

  Future<void> _saveDecision() async {
    if (residence == null) {
      return;
    }

    journal.insert(
      0,
      <String, dynamic>{
        'at': DateTime.now().toIso8601String(),
        'goal': goal.text.trim(),
        'prediction': 'Selected trade-off: '
            'speed ${speed.round()} • '
            'cost ${cost.round()} • '
            'reliability ${reliability.round()}',
        'real_result': null,
        'variance': null,
        'learning': 'Pending real-world outcome.',
      },
    );

    await _persist('decision_saved');

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _logResult() async {
    if (residence == null || resultCtl.text.trim().isEmpty) {
      return;
    }

    if (journal.isEmpty) {
      await _saveDecision();
    }

    if (journal.isEmpty) {
      return;
    }

    final first = journal.first;

    first['real_result'] = resultCtl.text.trim();
    first['variance'] = 'QUALITATIVE_REVIEW_REQUIRED';
    first['learning'] = 'Outcome recorded for Medrus + Viveda review; '
        'no unsupported numeric calibration is invented.';

    resultCtl.clear();

    await _persist('result_logged');

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _challenge(int index) async {
    if (index < 0 || index >= challenges.length) {
      return;
    }

    setState(() {
      if (challengedIndexes.contains(index)) {
        challengedIndexes.remove(index);
      } else {
        challengedIndexes.add(index);
      }

      status = challengedIndexes.isEmpty
          ? 'MANIS • stress-test bench ready'
          : 'MANIS • stress-test bench active';
    });

    if (residence != null) {
      await _persist('challenge_recorded');
    }
  }

  Future<void> _dispatch() async {
    if (!actApproved || !secondFactor) {
      return;
    }

    setState(() {
      status = 'BODHEX DISPATCH GATE UNLOCKED • '
          'awaiting explicit tool execution boundary';
    });

    await _persist('action_approved');
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);

    if (residence == null) {
      return Center(
        child: Text(
          'Create or claim a Human Residence first.',
          style: TextStyle(
            color: theme.mutedText,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(theme),
          const SizedBox(height: 14),
          _inputBay(theme),
          const SizedBox(height: 14),
          _pareto(theme),
          const SizedBox(height: 14),
          _challengeBench(theme),
          const SizedBox(height: 14),
          _actGate(theme),
          const SizedBox(height: 14),
          _journal(theme),
        ],
      ),
    );
  }

  Widget _header(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.success.withValues(alpha: .35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🏠 PRIVATE ROOM • PERSONAL EXECUTIVE COMMAND CENTER',
            style: TextStyle(
              color: theme.success,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            residence!.displayName,
            style: TextStyle(
              color: theme.text,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            status,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your residence is the authority boundary. '
            'Criterivox proposes, challenges and explains. '
            'You retain decision authority.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 11,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBay(CriterivoxTheme theme) {
    return _panel(
      theme,
      '1 • STRUCTURED INGESTION MATRIX',
      Column(
        children: [
          _field(
            goal,
            'Goal',
            'Incomplete goals stay explicit. '
                'Dharen must not silently invent constraints.',
          ),
          const SizedBox(height: 10),
          _field(
            data,
            'Static Data',
            'Facts, files, measurements or supplied records.',
          ),
          const SizedBox(height: 10),
          _field(
            contextCtl,
            'Dynamic Context',
            'Timing, constraints, stakeholders, assumptions '
                'and changing conditions.',
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _tag(
                theme,
                goal.text.trim().isEmpty ? 'GOAL_MISSING' : 'GOAL_PRESENT',
              ),
              _tag(
                theme,
                data.text.trim().isEmpty ? 'DATA_MISSING' : 'DATA_COMPLETE',
              ),
              _tag(
                theme,
                contextCtl.text.trim().isEmpty
                    ? 'CONTEXT_SLOT_MISSING'
                    : 'CONTEXT_PRESENT',
              ),
              _tag(
                theme,
                goal.text.trim().isEmpty || contextCtl.text.trim().isEmpty
                    ? 'BOUNDS_REVIEW'
                    : 'BOUNDS_SUPPLIED',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: running ? null : _generateOptions,
              icon: const Icon(
                Icons.auto_awesome_rounded,
              ),
              label: Text(
                running ? 'Sparring…' : 'Generate decision vectors',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint,
  ) {
    return TextField(
      controller: controller,
      maxLines: 3,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _tag(
    CriterivoxTheme theme,
    String text,
  ) {
    return Chip(
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 8,
          fontWeight: FontWeight.w800,
        ),
      ),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _pareto(CriterivoxTheme theme) {
    return _panel(
      theme,
      '2 • PARETO DECISION FRONTIER',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (options.isEmpty)
            Text(
              'Generate options to populate three distinct '
              'decision vectors.',
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 10,
              ),
            )
          else
            ...options.take(3).toList().asMap().entries.map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surfaceStrong,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.border,
                      ),
                    ),
                    child: Text(
                      entry.value,
                      style: TextStyle(
                        color: theme.text,
                        fontSize: 10,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
          _slider(
            theme,
            'Speed',
            speed,
            (value) {
              setState(() {
                speed = value;
              });
            },
          ),
          _slider(
            theme,
            'Cost',
            cost,
            (value) {
              setState(() {
                cost = value;
              });
            },
          ),
          _slider(
            theme,
            'Reliability',
            reliability,
            (value) {
              setState(() {
                reliability = value;
              });
            },
          ),
          Text(
            'The sliders define preference, not an unsupported '
            'claim of mathematical optimality.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    CriterivoxTheme theme,
    String label,
    double value,
    ValueChanged<double> callback,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0,
            max: 100,
            onChanged: callback,
          ),
        ),
        SizedBox(
          width: 32,
          child: Text(
            '${value.round()}',
            style: TextStyle(
              color: theme.text,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _challengeBench(CriterivoxTheme theme) {
    return _panel(
      theme,
      '3 • MANIS STRESS-TEST BENCH',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Socratic friction before commitment',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (challenges.isEmpty)
            Text(
              'Choose a decision vector, then run the challenge phase.',
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 10,
              ),
            )
          else
            ...challenges.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final challenge = entry.value;

                return CheckboxListTile(
                  value: challengedIndexes.contains(index),
                  onChanged: (_) {
                    _challenge(index);
                  },
                  title: Text(
                    challenge,
                    style: TextStyle(
                      color: theme.text,
                      fontSize: 10,
                    ),
                  ),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),
          const SizedBox(height: 6),
          Text(
            'Modify assumptions or reject premises here. '
            'A challenge is recorded as a governance event, '
            'not a decorative warning.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actGate(CriterivoxTheme theme) {
    return _panel(
      theme,
      '4 • TWO-FACTOR JUDGMENT + ACTION SAFETY GATE',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cockpit Approval Briefing',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Action Scope: decision-derived tool action\n'
            'Blast Radius: user-controlled and explicitly reviewed\n'
            'Rollback Plan: must be defined before dispatch\n'
            'Resource Cost: governed by the selected preference vector',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 10,
              height: 1.55,
            ),
          ),
          CheckboxListTile(
            value: actApproved,
            onChanged: (value) {
              setState(() {
                actApproved = value ?? false;
              });
            },
            title: const Text(
              'I reviewed scope, blast radius and rollback boundary.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          CheckboxListTile(
            value: secondFactor,
            onChanged: (value) {
              setState(() {
                secondFactor = value ?? false;
              });
            },
            title: const Text(
              'Second judgment factor confirmed.',
            ),
            contentPadding: EdgeInsets.zero,
          ),
          FilledButton.icon(
            onPressed: actApproved && secondFactor ? _dispatch : null,
            icon: const Icon(
              Icons.lock_open_rounded,
            ),
            label: const Text(
              'Unlock Bodhex action dispatch',
            ),
          ),
        ],
      ),
    );
  }

  Widget _journal(CriterivoxTheme theme) {
    return _panel(
      theme,
      '5 • BI-TEMPORAL RESULTS JOURNAL',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction → real result → variance → learning',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (journal.isEmpty)
            Text(
              'No decision has been saved yet.',
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 10,
              ),
            )
          else
            ...journal.take(8).map(
                  (entry) => Container(
                    margin: const EdgeInsets.only(
                      bottom: 8,
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.surfaceStrong,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'Goal: ${entry['goal']}\n'
                      'Prediction: ${entry['prediction']}\n'
                      'Real result: '
                      '${entry['real_result'] ?? 'pending'}\n'
                      'Variance: '
                      '${entry['variance'] ?? 'pending'}\n'
                      'Learning: ${entry['learning']}',
                      style: TextStyle(
                        color: theme.mutedText,
                        fontSize: 9,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
          const SizedBox(height: 8),
          TextField(
            controller: resultCtl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Log real-world result',
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _saveDecision,
                icon: const Icon(
                  Icons.bookmark_add_rounded,
                ),
                label: const Text(
                  'Save Decision',
                ),
              ),
              OutlinedButton.icon(
                onPressed: _logResult,
                icon: const Icon(
                  Icons.fact_check_rounded,
                ),
                label: const Text(
                  'Log Result',
                ),
              ),
              OutlinedButton.icon(
                onPressed: widget.onWorkspace,
                icon: const Icon(
                  Icons.account_tree_rounded,
                ),
                label: const Text(
                  'Open full workspace',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _panel(
    CriterivoxTheme theme,
    String title,
    Widget child,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: theme.primary,
              fontSize: 9,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
