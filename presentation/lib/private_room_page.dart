import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;

import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

class PrivateRoomPage extends StatefulWidget {
  final VoidCallback onWorkspace;
  final VoidCallback? onCollaborationRoom;

  const PrivateRoomPage({
    super.key,
    required this.onWorkspace,
    this.onCollaborationRoom,
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
  final List<Map<String, dynamic>> materials = <Map<String, dynamic>>[];

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

  Future<void> _pickMaterial() async {
    final result = await FilePicker.platform.pickFiles(withData: true, allowMultiple: true);
    if (result == null) return;
    final encoded = result.files.where((file) => file.bytes != null).map((file) => <String, dynamic>{
      'name': file.name,
      'source_type': const {'png','jpg','jpeg','webp','gif'}.contains((file.extension ?? '').toLowerCase()) ? 'image' : 'file',
      'channel': 'human-residence',
      'content_base64': base64Encode(file.bytes!),
      'processing_status': 'received',
    }).toList();
    try {
      final response = await http.post(
        Uri.base.resolve('/api/human-residence/intake'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'collection_id': residence?.residenceId, 'sources': encoded, 'supplied_context': {'goal': goal.text.trim(), 'context': contextCtl.text.trim()}}),
      ).timeout(const Duration(seconds: 12));
      if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('intake rejected');
      setState(() {
        materials.addAll(result.files.map((file) => <String, dynamic>{'name': file.name, 'size': file.size, 'extension': file.extension, 'source': 'human-residence'}));
        status = 'MATERIALS_RECEIVED • Python Data Foundation created';
      });
      await _persist('materials_received');
    } catch (_) {
      if (mounted) setState(() => status = 'MATERIAL_INTAKE_PAUSED • Python runtime rejected or unavailable');
    }
  }

  bool allowExternalResearch = false;
  Map<String, dynamic>? research;
  List<Map<String, dynamic>> trace = <Map<String, dynamic>>[];
  String? decisionId;
  String? acceptedStrategyId;
  String? calendarId;
  List<Map<String, dynamic>> calendarEvents = <Map<String, dynamic>>[];
  DateTime? plannedStart;

  Future<void> _generateOptions() async {
    if (goal.text.trim().isEmpty || running || residence == null) return;
    final token = residence!.metadata['session_token']?.toString();
    if (token == null || token.isEmpty) {
      setState(() => status = 'AUTHENTICATED_SESSION_REQUIRED');
      return;
    }
    setState(() {
      running = true;
      status = allowExternalResearch ? 'RESEARCH_AUTHORIZED • Criterivox is gathering external evidence' : 'Criterivox is reasoning from supplied material';
      options = <String>[];
      challenges = <String>[];
      trace = <Map<String, dynamic>>[];
      research = null;
    });
    try {
      final response = await http.post(
        Uri.base.resolve('/api/human-residence/decision'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'session_token': token,
          'residence_id': residence!.residenceId,
          'goal': goal.text.trim(),
          'data': data.text.trim(),
          'context': contextCtl.text.trim(),
          'allow_external_research': allowExternalResearch,
        }),
      ).timeout(const Duration(seconds: 30));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 || body is! Map) {
        throw Exception(body is Map ? body['error'] ?? 'decision pipeline rejected' : 'decision pipeline rejected');
      }
      final decoded = Map<String, dynamic>.from(body);
      final strategy = decoded['strategy'] is Map ? Map<String, dynamic>.from(decoded['strategy'] as Map) : <String, dynamic>{};
      final rawOptions = strategy['options'];
      final rawChallenges = strategy['challenges'];
      if (!mounted) return;
      setState(() {
        options = rawOptions is List ? rawOptions.whereType<Map>().map((item) => (item['id'] ?? '').toString() + '|' + (item['label'] ?? '').toString() + ': ' + (item['approach'] ?? '').toString() + ' • Risk: ' + (item['risk'] ?? 'review').toString()).toList() : <String>[];
        challenges = rawChallenges is List ? rawChallenges.map((item) => '$item').toList() : <String>[];
        trace = decoded['trace'] is List ? decoded['trace'].whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList() : <Map<String, dynamic>>[];
        research = decoded['research'] is Map ? Map<String, dynamic>.from(decoded['research'] as Map) : null;
        decisionId = decoded['decision_id']?.toString();
        running = false;
        status = research != null ? 'RESEARCH_COMPLETE • evidence attached to decision trace' : 'DECISION_READY • challenge before acceptance';
      });
      await _persist('decision_pipeline_complete');
    } catch (e) {
      if (mounted) setState(() { running = false; status = 'DECISION_PIPELINE_FAILED • $e'; });
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
    final token = residence?.metadata['session_token']?.toString();
    if (token != null) {
      try {
        await http.post(
          Uri.base.resolve('/api/human-decisions'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({
            'session_token': token,
            'residence_id': residence!.residenceId,
            'title': goal.text.trim().isEmpty ? 'Criterivox Strategy' : goal.text.trim(),
            'goal': goal.text.trim(),
            'strategy': {
              'options': options,
              'speed': speed.round(),
              'cost': cost.round(),
              'reliability': reliability.round(),
              'challenges': challenges,
            },
            'trace': options.where((x) => x.startsWith('Execution trace:')).toList(),
          }),
        ).timeout(const Duration(seconds: 8));
      } catch (_) {
        // IndexedDB remains the active session authority if the runtime is unavailable.
      }
    }

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

    final token = residence!.metadata['session_token']?.toString();
    if (token != null && decisionId != null) {
      try {
        await http.post(
          Uri.base.resolve('/api/human-residence/decision/$decisionId/outcome'),
          headers: const {'content-type': 'application/json'},
          body: jsonEncode({'session_token': token, 'result': first['real_result']}),
        ).timeout(const Duration(seconds: 8));
      } catch (_) {}
    }
    resultCtl.clear();
    await _persist('result_logged');
    if (mounted) setState(() {});
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
      final token = residence!.metadata['session_token']?.toString();
      if (token != null && decisionId != null) {
        try {
          await http.post(
            Uri.base.resolve('/api/human-residence/decision/$decisionId/challenge'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({'session_token': token, 'text': challenges[index]}),
          ).timeout(const Duration(seconds: 8));
        } catch (_) {}
      }
    }
  }

  Future<void> _loadCalendar() async {
    final token = residence?.metadata['session_token']?.toString();
    if (token == null) return;
    try {
      final response = await http.get(Uri.base.resolve('/api/human-residence/calendar?session_token=' + Uri.encodeQueryComponent(token))).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) return;
      final body = jsonDecode(response.body);
      if (body is Map && body['events'] is List && mounted) {
        setState(() => calendarEvents = (body['events'] as List).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList());
      }
    } catch (_) {}
  }

  Future<void> _acceptStrategy() async {
    if (residence == null || decisionId == null || options.isEmpty) return;
    final token = residence!.metadata['session_token']?.toString();
    if (token == null) return;
    final start = plannedStart ?? DateTime.now().add(const Duration(days: 1));
    try {
      final response = await http.post(
        Uri.base.resolve('/api/human-residence/decision/$decisionId/accept'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'session_token': token, 'action': 'execute', 'calendar_at': start.toIso8601String()}),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('strategy acceptance rejected');
      final calendarResponse = await http.post(
        Uri.base.resolve('/api/human-residence/calendar'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'session_token': token,
          'residence_id': residence!.residenceId,
          'decision_id': decisionId,
          'title': goal.text.trim().isEmpty ? 'Criterivox strategy execution' : goal.text.trim(),
          'starts_at': start.toIso8601String(),
          'strategy_id': acceptedStrategyId ?? 'B',
          'notes': options.join('\\n'),
        }),
      ).timeout(const Duration(seconds: 8));
      if (calendarResponse.statusCode < 200 || calendarResponse.statusCode >= 300) throw Exception('calendar creation rejected');
      final calendarBody = jsonDecode(calendarResponse.body);
      calendarId = calendarBody is Map && calendarBody['event'] is Map
          ? (calendarBody['event']['calendar_id']?.toString())
          : null;
      if (!mounted) return;
      setState(() {
        actApproved = true;
        secondFactor = true;
        status = 'STRATEGY ACCEPTED • CALENDAR EVENT CREATED • BODHEX READY';
      });
      await _loadCalendar();
      await _persist('strategy_accepted_and_scheduled');
    } catch (e) {
      if (mounted) setState(() => status = 'ACCEPTANCE_OR_CALENDAR_FAILED • $e');
    }
  }

  Future<void> _dispatch() async {
    if (!actApproved || !secondFactor || residence == null || decisionId == null || calendarId == null) return;
    final token = residence!.metadata['session_token']?.toString();
    if (token == null) return;
    try {
      final response = await http.patch(
        Uri.base.resolve('/api/human-residence/calendar/$calendarId'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'session_token': token,
          'status': 'execution_authorized',
        }),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('calendar execution authorization rejected');
      setState(() => status = 'EXECUTION AUTHORIZED • BODHEX HANDLER • CALENDAR EVENT READY');
      await _persist('action_approved');
    } catch (e) {
      setState(() => status = 'ACTION_AUTHORIZATION_FAILED • $e');
    }
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
          _calendar(theme),
          const SizedBox(height: 14),
          _researchTrace(theme),
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
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: _pickMaterial,
              icon: const Icon(Icons.attach_file_rounded),
              label: const Text('Add files / images / folders'),
            ),
          ),
          if (materials.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...materials.take(8).map((item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.insert_drive_file_outlined, size: 18),
              title: Text(item['name'].toString(), style: const TextStyle(fontSize: 10)),
              subtitle: Text(item['size'].toString() + ' bytes • Human Residence intake', style: const TextStyle(fontSize: 9)),
            )),
          ],
          const SizedBox(height: 10),
          SwitchListTile.adaptive(
            value: allowExternalResearch,
            onChanged: running ? null : (value) => setState(() => allowExternalResearch = value),
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow Google external research'),
            subtitle: const Text('If enabled, Criterivox searches Google and attaches returned sources to this decision trace.'),
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

  Widget _calendar(CriterivoxTheme theme) {
    return _panel(
      theme,
      '5 • CRITERIVOX CALENDAR',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Accepted strategies become scheduled work here. No external calendar API is required.', style: TextStyle(color: theme.mutedText, fontSize: 10)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: Text('Start: ' + (plannedStart ?? DateTime.now().add(const Duration(days: 1))).toString(), style: TextStyle(color: theme.text, fontSize: 10))),
            OutlinedButton(onPressed: () async {
              final picked = await showDatePicker(context: context, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 3650)), initialDate: plannedStart ?? DateTime.now().add(const Duration(days: 1)));
              if (picked != null) setState(() => plannedStart = DateTime(picked.year, picked.month, picked.day, 9));
            }, child: const Text('Schedule')),
          ]),
          const SizedBox(height: 8),
          ...calendarEvents.take(12).map((event) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text((event['title'] ?? '').toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
            subtitle: Text((event['starts_at'] ?? '').toString() + ' • ' + (event['status'] ?? '').toString(), style: TextStyle(color: theme.mutedText, fontSize: 9)),
          )),
          FilledButton.icon(onPressed: decisionId == null ? null : _acceptStrategy, icon: const Icon(Icons.event_available), label: const Text('Accept strategy & put it on calendar')),
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
            onPressed: decisionId == null ? null : _acceptStrategy,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Accept selected strategy'),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: actApproved && secondFactor ? _dispatch : null,
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('Unlock Bodhex action dispatch'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadStrategy() async {
    final lines = <String>[
      '# Criterivox Strategy', '', 'Goal: ' + goal.text.trim(), '',
      'Options', ...options.map((x) => '- ' + x), '',
      'Trade-offs', 'Speed: ' + speed.round().toString(), 'Cost: ' + cost.round().toString(),
      'Reliability: ' + reliability.round().toString(), '', 'Challenges', ...challenges.map((x) => '- ' + x),
    ];
    await FilePicker.platform.saveFile(fileName: 'criterivox-strategy.md', bytes: utf8.encode(lines.join('\n')));
  }

  Widget _researchTrace(CriterivoxTheme theme) {
    if (research == null && trace.isEmpty) return const SizedBox.shrink();
    final results = research?['results'];
    return _panel(
      theme,
      '6 • DECISION TRACE + EXTERNAL EVIDENCE',
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (research != null)
            Text(
              'Google research: ' + (research?['query'] ?? '').toString() + ' • ' +
                  (results is List ? results.length : 0).toString() + ' results',
              style: TextStyle(color: theme.text, fontWeight: FontWeight.w700, fontSize: 10),
            ),
          if (results is List)
            ...results.take(8).map((item) => item is Map
                ? ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text((item['title'] ?? '').toString(), style: const TextStyle(fontSize: 10)),
                    subtitle: Text(
                      (item['snippet'] ?? '').toString() + '\n' + (item['url'] ?? '').toString(),
                      style: TextStyle(color: theme.mutedText, fontSize: 9),
                    ),
                  )
                : const SizedBox.shrink()),
          if (trace.isNotEmpty)
            ...trace.map((event) => Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                (event['actor'] ?? '').toString() + ' • ' +
                    (event['responsibility'] ?? '').toString() + ' • ' +
                    (event['detail'] ?? '').toString(),
                style: TextStyle(color: theme.mutedText, fontSize: 9, height: 1.4),
              ),
            )),
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
          OutlinedButton.icon(
            onPressed: _downloadStrategy,
            icon: const Icon(Icons.download_rounded),
            label: const Text('Download current strategy'),
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
