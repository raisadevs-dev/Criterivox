import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class GuestPassExperiencePage extends StatefulWidget {
  final VoidCallback onWorkspace;

  const GuestPassExperiencePage({
    super.key,
    required this.onWorkspace,
  });

  @override
  State<GuestPassExperiencePage> createState() =>
      _GuestPassExperiencePageState();
}

class _GuestPassExperiencePageState extends State<GuestPassExperiencePage> {
  String? sessionId;
  DateTime? expiresAt;
  Timer? timer;

  Duration remaining = const Duration(minutes: 15);

  bool loading = true;
  bool running = false;
  bool claiming = false;

  String status = 'Starting isolated guest session…';
  String goal = '';
  String data = '';
  String contextText = '';

  final TextEditingController goalCtl = TextEditingController();
  final TextEditingController dataCtl = TextEditingController();
  final TextEditingController contextCtl = TextEditingController();

  double budget = 50;
  double speed = 50;
  double risk = 50;

  final List<Map<String, String>> trace = [];
  final List<String> decisions = [];

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    timer?.cancel();
    goalCtl.dispose();
    dataCtl.dispose();
    contextCtl.dispose();
    _leave(silent: true);
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final response = await http
          .post(
            Uri.base.resolve('/api/guest-pass/session'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;

        sessionId = '${decoded['session_id']}';
        expiresAt = DateTime.parse('${decoded['expires_at']}');

        _clock();

        if (mounted) {
          setState(() {
            loading = false;
            status = 'ISOLATED_EPHEMERAL_STATE';
          });
        }

        return;
      }

      throw Exception(
        'guest session endpoint returned ${response.statusCode}',
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          status = 'Guest sandbox could not be started: $e';
        });
      }
    }
  }

  void _clock() {
    timer?.cancel();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final expiry = expiresAt;

        if (expiry == null || !mounted) {
          return;
        }

        final duration = expiry.difference(DateTime.now());

        if (duration.isNegative || duration == Duration.zero) {
          timer?.cancel();

          setState(() {
            remaining = Duration.zero;
            status = 'SESSION_VAPORIZED';
          });
        } else {
          setState(() {
            remaining = duration;
          });
        }
      },
    );
  }

  Future<void> _run() async {
    final id = sessionId;
    final goalText = goalCtl.text.trim();

    if (id == null || goalText.isEmpty) {
      return;
    }

    setState(() {
      running = true;
      status =
          'Anukor routing • Dharen framing • Pramon comparing • Manis challenging';
      trace.clear();
      decisions.clear();
    });

    final payload = <String, dynamic>{
      'goal': goalText,
      'data': dataCtl.text.trim(),
      'context': <String, dynamic>{
        'description': contextCtl.text.trim(),
        'budget': budget.round(),
        'speed': speed.round(),
        'risk': risk.round(),
      },
    };

    try {
      final inputResponse = await http.post(
        Uri.base.resolve('/api/guest-pass/session/$id/input'),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (inputResponse.statusCode >= 400) {
        throw Exception('guest input rejected');
      }

      final planResponse = await http.post(
        Uri.base.resolve('/api/syvax/plan'),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'message': goalText,
          'task_id': 'guest-$id',
        }),
      );

      if (planResponse.statusCode >= 400) {
        throw Exception('routing rejected');
      }

      final decoded = jsonDecode(planResponse.body) as Map<String, dynamic>;

      _addTrace(
        'Anukor',
        'Routes the guest goal into an inspectable execution plan.',
      );

      _addTrace(
        'Dharen',
        'Frames supplied context and identifies missing dimensions.',
      );

      _addTrace(
        'Pramon',
        'Evaluates options against budget, speed and risk constraints.',
      );

      _addTrace(
        'Manis',
        'Challenges assumptions and records adversarial questions.',
      );

      final plan = decoded['plan'];
      final rawSteps = plan is Map ? plan['steps'] : null;

      final steps = rawSteps is List ? rawSteps : const [];

      for (final step in steps.take(4)) {
        if (step is Map) {
          final character = step['character_id'] ?? step['agent_id'] ?? 'Agent';

          final action =
              step['action'] ?? step['purpose'] ?? 'inspectable contribution';

          decisions.add('$character: $action');
        } else {
          decisions.add('Agent: $step');
        }
      }

      if (decisions.isEmpty) {
        decisions.add(
          'No downstream option was produced yet. '
          'Inspect the trace and adjust constraints.',
        );
      }

      if (mounted) {
        setState(() {
          running = false;
          status = 'TRACE_READY • trade-off canvas remains ephemeral';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          running = false;
          status = 'Guest evaluation paused: $e';
        });
      }
    }
  }

  void _addTrace(String character, String reason) {
    trace.add({
      'character': character,
      'reason': reason,
    });

    final id = sessionId;

    if (id != null) {
      http.post(
        Uri.base.resolve('/api/guest-pass/session/$id/trace'),
        headers: {
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'character': character,
          'reason': reason,
          'at': DateTime.now().toIso8601String(),
        }),
      );
    }
  }

  Future<void> _leave({
    bool silent = false,
  }) async {
    final id = sessionId;

    if (id == null) {
      return;
    }

    sessionId = null;
    timer?.cancel();

    try {
      await http
          .delete(
            Uri.base.resolve('/api/guest-pass/session/$id'),
          )
          .timeout(const Duration(seconds: 2));
    } catch (_) {}

    if (!silent && mounted) {
      setState(() {
        status = 'SESSION_VAPORIZED • no guest residence was created';
      });
    }
  }

  Future<void> _claim() async {
    final id = sessionId;

    if (id == null || claiming) {
      return;
    }

    setState(() {
      claiming = true;
      status =
          'Migrating the ephemeral decision thread into a Human Residence…';
    });

    try {
      final response = await http
          .post(
            Uri.base.resolve('/api/guest-pass/session/$id/claim'),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode >= 400) {
        throw Exception('claim rejected');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      final migratable = Map<String, dynamic>.from(
        decoded['migratable'] as Map,
      );

      final now = DateTime.now();
      final residenceId = 'res-guest-${now.millisecondsSinceEpoch}';
      final ownerId = 'local-${now.millisecondsSinceEpoch}';

      final record = HumanResidenceRecord(
        residenceId: residenceId,
        ownerId: ownerId,
        displayName: 'My Criterivox House',
        email: null,
        residenceType: 'private',
        createdAt: now,
        members: [
          {
            'role': 'owner',
            'owner_id': 'local',
          },
        ],
        metadata: {
          'rooms': [
            'private',
            'collaboration',
          ],
          'claimed_from_guest': migratable['claimed_from_guest'],
          'guest_decisions': migratable['decisions'],
          'guest_trace': migratable['trace'],
          'goal': migratable['goal'],
          'data': migratable['data'],
          'context': migratable['context'],
        },
      );

      await HumanResidenceStore().save(record);

      try {
        await http
            .post(
              Uri.base.resolve('/api/human-residence'),
              headers: {
                'content-type': 'application/json',
              },
              body: jsonEncode(record.toJson()),
            )
            .timeout(const Duration(seconds: 4));
      } catch (_) {}

      sessionId = null;
      timer?.cancel();

      if (mounted) {
        setState(() {
          claiming = false;
          status = 'CLAIMED • decision migrated to your Human Residence';
        });
      }

      if (mounted) {
        widget.onWorkspace();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          claiming = false;
          status = 'Claim failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = CriterivoxTheme.of(context);

    if (loading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.primary,
        ),
      );
    }

    final minutes = remaining.inMinutes.toString().padLeft(2, '0');

    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hud(theme, minutes, seconds),
          const SizedBox(height: 14),
          _hero(theme),
          const SizedBox(height: 14),
          _inputs(theme),
          const SizedBox(height: 14),
          _trace(theme),
          const SizedBox(height: 14),
          _tradeoffs(theme),
          const SizedBox(height: 14),
          _exit(theme),
        ],
      ),
    );
  }

  Widget _hud(
    CriterivoxTheme theme,
    String minutes,
    String seconds,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: theme.surfaceStrong,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.success.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.shield_rounded,
            color: theme.success,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    color: theme.success,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  'Guest memory is session-scoped and excluded from '
                  'Human Residence persistence.',
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '$minutes:$seconds',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'TTL',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _hero(CriterivoxTheme theme) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎟️ GUEST PASS ROOM',
            style: TextStyle(
              color: theme.primary,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Prove the value before you build a house.',
            style: TextStyle(
              color: theme.text,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'A temporary evaluation room for Goal + Data + Context. '
            'Inspect the reasoning, challenge trade-offs, then leave '
            'or claim the work.',
            style: TextStyle(
              color: theme.mutedText,
              fontSize: 11,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputs(CriterivoxTheme theme) {
    return _panel(
      theme,
      '1 • GOAL + DATA + CONTEXT',
      Column(
        children: [
          TextField(
            controller: goalCtl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Goal',
              hintText: 'What decision are you evaluating?',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: dataCtl,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Data',
              hintText: 'Paste trial data or describe the dataset',
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: contextCtl,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Context',
              hintText: 'Constraints, assumptions, timing, stakeholders',
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: running ? null : _run,
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(
                running ? 'Running…' : 'Run isolated evaluation',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trace(CriterivoxTheme theme) {
    return _panel(
      theme,
      '2 • DECISION LOGIC X-RAY',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Civilization Reasoning Trace',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          if (trace.isEmpty)
            Text(
              'Run the evaluation to inspect which characters '
              'contributed and why.',
              style: TextStyle(
                color: theme.mutedText,
                fontSize: 10,
              ),
            )
          else
            ...trace.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: theme.mutedText,
                            fontSize: 10,
                            height: 1.4,
                          ),
                          children: [
                            TextSpan(
                              text: '${entry['character']}  ',
                              style: TextStyle(
                                color: theme.text,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: entry['reason'] ?? '',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (decisions.isNotEmpty) ...[
            const Divider(),
            Text(
              'DECISIONS + OPTIONS',
              style: TextStyle(
                color: theme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 9,
              ),
            ),
            const SizedBox(height: 6),
            ...decisions.map(
              (decision) => Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  '• $decision',
                  style: TextStyle(
                    color: theme.mutedText,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tradeoffs(CriterivoxTheme theme) {
    return _panel(
      theme,
      '3 • EPHEMERAL TRADE-OFF SPARRING DECK',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Experience how Criterivox adapts options as you '
            'challenge its assumptions!',
            style: TextStyle(
              color: theme.text,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 10),
          _slider(
            theme,
            'Budget',
            budget,
            (value) {
              setState(() {
                budget = value;
              });
            },
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
            'Risk tolerance',
            risk,
            (value) {
              setState(() {
                risk = value;
              });
            },
          ),
          Text(
            'These values live only in the guest session until '
            'you explicitly claim it.',
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
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 100,
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
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 34,
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

  Widget _exit(CriterivoxTheme theme) {
    return _panel(
      theme,
      '4 • EXIT OPTIONS',
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          OutlinedButton.icon(
            onPressed: claiming ? null : _leave,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Leave & Vaporize'),
          ),
          FilledButton.icon(
            onPressed: claiming ? null : _claim,
            icon: const Icon(Icons.home_work_rounded),
            label: Text(
              claiming ? 'Claiming…' : 'Claim House & Save Decision',
            ),
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
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
/*

### What this fixes

* **`Expected ']'` around line 124**: rebuilt the `_trace()` widget tree explicitly.
* Removes the parser ambiguity caused by huge one-line widget expressions.
* Keeps `Slider` values as proper `double`s.
* Makes the `/api/syvax/plan` response parsing safer when `plan` or `steps` is absent.
* Keeps the existing guest-session → trace → claim → Human Residence flow intact.
* Keeps `withValues(alpha: ...)`, so it does not reintroduce the deprecated `Color.value` problem.
* No new backend behavior or invented persistence semantics were added.

One small cleanup is also deliberate: `goal`, `data`, and `contextText` remain declared because they are part of the existing state contract, but the actual payload continues to use the controllers, exactly as the current implementation does.
*/
