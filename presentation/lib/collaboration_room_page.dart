import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/criterivox_theme.dart';

/// Gate 2 Collaboration Room client.
///
/// The browser remains the Human Residence persistence authority. This page
/// uses the collaboration API as the authoritative collaboration session
/// state, then mirrors residence metadata locally. Guest permissions are
/// enforced again by the Python API; this UI never grants them client-side.
class CollaborationRoomPage extends StatefulWidget {
  const CollaborationRoomPage({super.key});
  @override
  State<CollaborationRoomPage> createState() => _CollaborationRoomPageState();
}

class _CollaborationRoomPageState extends State<CollaborationRoomPage> {
  final store = HumanResidenceStore();
  final memberCtl = TextEditingController();
  final messageCtl = TextEditingController();
  final resultCtl = TextEditingController();
  HumanResidenceRecord? residence;
  String? sessionId;
  String actor = '';
  String role = 'owner';
  String visibility = 'PUBLIC_TO_ROOM';
  String riskLevel = 'moderate';
  String selectedOption = 'Option B';
  int requiredSignatories = 1;
  Map<String, dynamic> session = {};
  Map<String, dynamic> consensus = {};
  Map<String, dynamic> dispatch = {};
  List<dynamic> candidates = [];
  List<dynamic> threads = [];
  List<dynamic> challenges = [];
  List<dynamic> outcomes = [];
  Map<String, dynamic>? lastOutcome;
  Map<String, dynamic>? learningProposal;
  String status = 'Connecting to collaboration runtime…';
  bool busy = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    memberCtl.dispose();
    messageCtl.dispose();
    resultCtl.dispose();
    super.dispose();
  }

  Uri _uri(String path) => Uri.base.resolve(path);
  Future<Map<String, dynamic>?> _request(String method, String path,
      [Map<String, dynamic>? body, Map<String, String>? query]) async {
    try {
      final uri = _uri(path).replace(queryParameters: query);
      final headers = {'content-type': 'application/json'};
      late http.Response response;
      if (method == 'GET') {
        response = await http
            .get(uri, headers: headers)
            .timeout(const Duration(seconds: 6));
      } else if (method == 'POST')
        response = await http
            .post(uri, headers: headers, body: jsonEncode(body ?? {}))
            .timeout(const Duration(seconds: 6));
      else
        throw StateError('Unsupported HTTP method');
      final decoded = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && response.statusCode < 300) {
        return decoded;
      }
      final message = decoded is Map && decoded['error'] != null
          ? '${decoded['error']}'
          : 'HTTP ${response.statusCode}';
      if (mounted) setState(() => status = 'Runtime: $message');
    } catch (e) {
      if (mounted) setState(() => status = 'Runtime unavailable: $e');
    }
    return null;
  }

  Future<void> _restore() async {
    final r = await store.load();
    if (!mounted) return;
    setState(() => residence = r);
    if (r == null) {
      setState(() => status = 'No Human Residence found. Claim a house first.');
      return;
    }
    actor = r.ownerId;
    await _connect();
  }

  Future<void> _connect() async {
    final r = residence;
    if (r == null) return;
    setState(() => busy = true);
    final created = await _request('POST', '/api/collaboration/session', {
      'residence_id': r.residenceId,
      'owner_id': r.ownerId,
      'owner_name': r.displayName,
    });
    if (created != null) {
      sessionId = created['session'] is Map
          ? created['session']['session_id']?.toString()
          : null;
      await _refresh();
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> _refresh() async {
    final sid = sessionId;
    if (sid == null || actor.isEmpty) return;
    final data = await _request(
        'GET', '/api/collaboration/session/$sid', null, {'actor': actor});
    if (data == null) return;
    final s = Map<String, dynamic>.from(data['session'] ?? {});
    final c = Map<String, dynamic>.from(data['consensus'] ?? {});
    final d = Map<String, dynamic>.from(data['dispatch'] ?? {});
    if (!mounted) return;
    setState(() {
      session = s;
      consensus = c;
      dispatch = d;
      candidates = List<dynamic>.from(s['candidate_context'] ?? []);
      threads = List<dynamic>.from(s['threads'] ?? []);
      challenges = List<dynamic>.from(s['challenges'] ?? []);
      outcomes = List<dynamic>.from(s['outcomes'] ?? []);
      visibility = '${s['visibility'] ?? visibility}';
      riskLevel = '${s['risk_level'] ?? riskLevel}';
      requiredSignatories =
          int.tryParse('${s['required_signatories'] ?? requiredSignatories}') ??
              requiredSignatories;
      status = 'Collaboration runtime synchronized • $actor';
    });
  }

  Future<void> _setRole(String newRole) async {
    final r = residence;
    final sid = sessionId;
    if (r == null || sid == null) return;
    if (newRole == 'owner') {
      actor = r.ownerId;
    } else {
      final members = List<dynamic>.from(session['members'] ?? []);
      final wanted = members.firstWhere((m) => '${m['role']}' == newRole,
          orElse: () => null);
      if (wanted == null) {
        setState(() => status = 'No $newRole member exists in this session.');
        return;
      }
      actor = '${wanted['member_id']}';
    }
    setState(() => role = newRole);
    await _refresh();
  }

  Future<void> _configure() async {
    final sid = sessionId;
    if (sid == null) return;
    final data =
        await _request('POST', '/api/collaboration/session/$sid/configure', {
      'actor': actor,
      'risk_level': riskLevel,
      'required_signatories': requiredSignatories,
      'visibility': visibility,
    });
    if (data != null) await _refresh();
  }

  Future<void> _addMember() async {
    final sid = sessionId;
    final name = memberCtl.text.trim();
    if (sid == null || name.isEmpty) return;
    setState(() => busy = true);
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/members',
        {'actor': actor, 'display_name': name, 'role': 'resident'});
    memberCtl.clear();
    if (data != null) {
      status = 'Resident added with backend RBAC scope.';
      await _refresh();
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> _postComment() async {
    final sid = sessionId;
    final text = messageCtl.text.trim();
    if (sid == null || text.isEmpty) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/comment',
        {'actor': actor, 'text': text, 'visibility': visibility});
    if (data != null) {
      messageCtl.clear();
      await _refresh();
    }
  }

  Future<void> _classify() async {
    final sid = sessionId;
    final text = messageCtl.text.trim();
    if (sid == null || text.isEmpty) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/classify',
        {'actor': actor, 'text': text, 'variable_type': 'constraint'});
    if (data != null) {
      messageCtl.clear();
      await _refresh();
    }
  }

  Future<void> _confirmCandidate(String id, bool accepted) async {
    final sid = sessionId;
    if (sid == null) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/context/$id/confirm',
        {'actor': actor, 'accepted': accepted});
    if (data != null) await _refresh();
  }

  Future<void> _vote(String option) async {
    final sid = sessionId;
    if (sid == null) return;
    final data = await _request('POST', '/api/collaboration/session/$sid/vote',
        {'actor': actor, 'option': option});
    if (data != null) {
      setState(() => selectedOption = option);
      await _refresh();
    }
  }

  Future<void> _challenge() async {
    final sid = sessionId;
    if (sid == null) return;
    final prompts = [
      'What assumption changes the recommendation if the constraint moves materially?',
      'Which evidence would make the team reject this option?',
      'What failure mode is least visible in the current consensus?'
    ];
    for (final text in prompts) {
      await _request('POST', '/api/collaboration/session/$sid/challenge',
          {'actor': actor, 'text': text});
    }
    await _refresh();
  }

  Map<String, dynamic> _action() => {
        'selected_option': selectedOption,
        'risk_level': riskLevel,
        'consensus': consensus,
        'source': 'Gate 2 Collaboration Room'
      };

  Future<void> _signOwner() async {
    final sid = sessionId;
    if (sid == null) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/sign/owner',
        {'actor': actor, 'action': _action()});
    if (data != null) await _refresh();
  }

  Future<void> _signResident() async {
    final sid = sessionId;
    if (sid == null) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/sign/resident',
        {'actor': actor, 'action': _action()});
    if (data != null) await _refresh();
  }

  Future<void> _dispatch() async {
    final sid = sessionId;
    if (sid == null) return;
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/dispatch',
        {'actor': actor, 'action': _action()});
    if (data != null) {
      setState(
          () => status = 'Bodhex dispatch accepted by the collaboration gate.');
      await _refresh();
    }
  }

  Future<void> _recordOutcome() async {
    final sid = sessionId;
    final result = resultCtl.text.trim();
    if (sid == null || result.isEmpty) return;
    final members = List<dynamic>.from(session['members'] ?? []);
    final contributors = members
        .where((m) => '${m['role']}' != 'guest')
        .map((m) => '${m['member_id']}')
        .toList();
    final data =
        await _request('POST', '/api/collaboration/session/$sid/outcome', {
      'actor': actor,
      'result': result,
      'selected_option': selectedOption,
      'contributors': contributors,
    });
    if (data != null) {
      resultCtl.clear();
      await _refresh();
    }
  }

  Future<void> _makeLearningProposal() async {
    final sid = sessionId;
    if (sid == null || outcomes.isEmpty) return;
    final outcomeId = '${outcomes.last['outcome_id']}';
    final data = await _request(
        'POST',
        '/api/collaboration/session/$sid/learning-proposal',
        {'actor': actor, 'outcome_id': outcomeId});
    if (data != null) {
      setState(() =>
          learningProposal = Map<String, dynamic>.from(data['proposal'] ?? {}));
    }
  }

  Future<void> _approveLearning() async {
    final proposalId = learningProposal?['proposal_id']?.toString();
    if (proposalId == null) return;
    final data = await _request(
        'POST',
        '/api/collaboration/learning-proposal/$proposalId/approve',
        {'actor': actor});
    if (data != null) {
      setState(() =>
          learningProposal = Map<String, dynamic>.from(data['proposal'] ?? {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return SingleChildScrollView(
        padding: const EdgeInsets.all(26),
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _header(t),
          const SizedBox(height: 14),
          _permissions(t),
          const SizedBox(height: 14),
          _consensus(t),
          const SizedBox(height: 14),
          _context(t),
          const SizedBox(height: 14),
          _dispatchPanel(t),
          const SizedBox(height: 14),
          _outcomesPanel(t),
        ]));
  }

  Widget _header(CriterivoxTheme t) => _panel(
      t,
      'GATE 2 • COLLABORATION ROOM',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(residence?.displayName ?? 'Team War Room',
            style: TextStyle(
                color: t.text, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
            'A-G runtime control surface: RBAC → Syvax/Dharen → consensus → Manis → multi-key Bodhex gate → outcome → governed learning.',
            style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5)),
        const SizedBox(height: 10),
        Text(sessionId == null ? status : '$status • session $sessionId',
            style: TextStyle(
                color: t.success, fontSize: 9, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
            onPressed: busy ? null : _refresh,
            icon: const Icon(Icons.sync_rounded),
            label: const Text('Sync runtime'))
      ]));

  Widget _permissions(CriterivoxTheme t) => _panel(
      t,
      'A+B • SESSION FOUNDATION + RBAC / DIFFERENTIAL DATA SHIELD',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Wrap(
            spacing: 8,
            children: ['owner', 'resident', 'guest']
                .map((r) => ChoiceChip(
                    label: Text(r == 'owner'
                        ? 'House Owner'
                        : '${r[0].toUpperCase()}${r.substring(1)}'),
                    selected: role == r,
                    onSelected: (_) => _setRole(r)))
                .toList()),
        const SizedBox(height: 10),
        Text('Backend actor: ${actor.isEmpty ? 'not connected' : actor}',
            style: TextStyle(color: t.mutedText, fontSize: 9)),
        const SizedBox(height: 8),
        Text('Visibility',
            style: TextStyle(
                color: t.text, fontWeight: FontWeight.w700, fontSize: 10)),
        Wrap(
            spacing: 8,
            children: ['PUBLIC_TO_ROOM', 'RESIDENT_ONLY', 'OWNER_CONFIDENTIAL']
                .map((v) => ChoiceChip(
                    label: Text(v),
                    selected: visibility == v,
                    onSelected: role == 'owner'
                        ? (_) {
                            setState(() => visibility = v);
                            _configure();
                          }
                        : null))
                .toList()),
        const SizedBox(height: 8),
        for (final m in List<dynamic>.from(session['members'] ?? []))
          Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Text(
                  '${m['display_name']} • ${m['role']} • ${m['member_id']}',
                  style: TextStyle(color: t.mutedText, fontSize: 9))),
        if (role == 'owner')
          Row(children: [
            Expanded(
                child: TextField(
                    controller: memberCtl,
                    decoration: const InputDecoration(
                        labelText: 'Add designated Resident'))),
            const SizedBox(width: 8),
            FilledButton(onPressed: _addMember, child: const Text('Add'))
          ]),
        const SizedBox(height: 8),
        if (role == 'guest')
          Text(
              'Guest policy: read shared threads + masked options + comments only. Vote, execution, and authoritative-context mutation are denied by the backend.',
              style: TextStyle(
                  color: t.warning, fontSize: 9, fontWeight: FontWeight.w700)),
        if (role == 'owner')
          Wrap(spacing: 8, children: [
            DropdownButton<String>(
                value: riskLevel,
                items: ['low', 'moderate', 'high', 'critical']
                    .map((x) =>
                        DropdownMenuItem(value: x, child: Text('Risk: $x')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => riskLevel = v);
                    _configure();
                  }
                }),
            DropdownButton<int>(
                value: requiredSignatories,
                items: [1, 2, 3, 4]
                    .map((x) => DropdownMenuItem(
                        value: x, child: Text('Residents required: $x')))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => requiredSignatories = v);
                    _configure();
                  }
                })
          ])
      ]));

  Widget _consensus(CriterivoxTheme t) {
    final counts = Map<String, dynamic>.from(consensus['counts'] ?? {});
    final pct = consensus['consensus_percent'] ?? 0;
    final threshold = consensus['threshold'] ?? 70;
    final friction = consensus['manis_friction'] == true;
    return _panel(
        t,
        'D • ADAPTIVE CONSENSUS + MANIS FRICTION ALIGNMENT',
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
              'Consensus Radar • $pct% on ${consensus['leader'] ?? selectedOption} • threshold $threshold%',
              style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final o in ['Option A', 'Option B', 'Option C'])
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  SizedBox(
                      width: 82,
                      child: Text(o,
                          style: TextStyle(color: t.mutedText, fontSize: 10))),
                  Expanded(
                      child: LinearProgressIndicator(
                          value: (consensus['total'] ?? 0) == 0
                              ? 0
                              : (double.tryParse('${counts[o] ?? 0}') ?? 0) /
                                  (double.tryParse(
                                          '${consensus['total'] ?? 0}') ??
                                      1),
                          minHeight: 8)),
                  const SizedBox(width: 8),
                  Text('${counts[o] ?? 0}',
                      style: TextStyle(color: t.text, fontSize: 9))
                ])),
          Wrap(
              spacing: 8,
              children: ['Option A', 'Option B', 'Option C']
                  .map((o) => OutlinedButton(
                      onPressed: role == 'guest' ? null : () => _vote(o),
                      child: Text('Vote $o')))
                  .toList()),
          if (friction)
            Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('MANIS • TEAM FRICTION ALIGNMENT REQUIRED',
                    style: TextStyle(
                        color: t.warning,
                        fontWeight: FontWeight.w900,
                        fontSize: 10))),
          const SizedBox(height: 6),
          Text(
              'Threshold adapts to configured risk: low 55%, moderate 70%, high 80%, critical 90%.',
              style: TextStyle(color: t.mutedText, fontSize: 9))
        ]));
  }

  Widget _context(CriterivoxTheme t) => _panel(
      t,
      'C • RAW CHAT → SYVAX CLASSIFICATION → HUMAN CONFIRMATION → DHAREN CONTEXT DIFF',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'Raw discussion is not authoritative context. Syvax classifies it into a candidate variable; a human must confirm it before Dharen receives a Context Diff.',
            style: TextStyle(color: t.text, fontSize: 10)),
        const SizedBox(height: 8),
        TextField(
            controller: messageCtl,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Raw team chat / candidate update')),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton.icon(
              onPressed: role == 'guest' ? null : _classify,
              icon: const Icon(Icons.auto_awesome_rounded),
              label: const Text('Send to Syvax classification')),
          OutlinedButton.icon(
              onPressed: role == 'guest' ? null : _postComment,
              icon: const Icon(Icons.forum_rounded),
              label: const Text('Post shared comment')),
          OutlinedButton.icon(
              onPressed: role == 'guest' ? null : _challenge,
              icon: const Icon(Icons.gavel_rounded),
              label: const Text('Ask Manis to challenge'))
        ]),
        const SizedBox(height: 10),
        if (candidates.isEmpty)
          Text('No candidate context variables.',
              style: TextStyle(color: t.mutedText, fontSize: 9)),
        for (final c in candidates)
          if (c is Map) _candidateCard(t, c),
        if (threads.isNotEmpty) ...[
          const Divider(),
          Text('SHARED THREADS',
              style: TextStyle(
                  color: t.primary, fontWeight: FontWeight.w800, fontSize: 9)),
          for (final x in threads)
            Text('• ${x['actor']}: ${x['text']} [${x['visibility']}]',
                style: TextStyle(color: t.mutedText, fontSize: 9))
        ],
        if (challenges.isNotEmpty) ...[
          const Divider(),
          Text('MANIS CHALLENGES',
              style: TextStyle(
                  color: t.primary, fontWeight: FontWeight.w800, fontSize: 9)),
          for (final x in challenges)
            Text('• ${x['text']}',
                style: TextStyle(color: t.mutedText, fontSize: 9))
        ]
      ]));

  Widget _candidateCard(CriterivoxTheme t, Map c) => Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: t.border),
          borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${c['classification']} • ${c['status']}',
            style: TextStyle(
                color: t.primary, fontWeight: FontWeight.w800, fontSize: 9)),
        const SizedBox(height: 4),
        Text('${c['raw_text']}', style: TextStyle(color: t.text, fontSize: 10)),
        if ('${c['status']}' == 'candidate' && role != 'guest')
          Wrap(spacing: 8, children: [
            OutlinedButton(
                onPressed: () => _confirmCandidate('${c['id']}', true),
                child: const Text('Confirm → Dharen Diff')),
            TextButton(
                onPressed: () => _confirmCandidate('${c['id']}', false),
                child: const Text('Reject'))
          ])
      ]));

  Widget _dispatchPanel(CriterivoxTheme t) => _panel(
      t,
      'E • OWNER + N DESIGNATED RESIDENT SIGNATURES → BODHEX',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'Gate: owner=${dispatch['signed']?['owner'] ?? false} • residents=${List<dynamic>.from(dispatch['signed']?['residents'] ?? []).length}/${dispatch['required']?['resident_count'] ?? requiredSignatories}',
            style: TextStyle(
                color: t.text, fontWeight: FontWeight.w800, fontSize: 10)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton.icon(
              onPressed: role == 'owner' ? _signOwner : null,
              icon: const Icon(Icons.verified_user_rounded),
              label: const Text('Owner sign')),
          FilledButton.icon(
              onPressed: role == 'resident' ? _signResident : null,
              icon: const Icon(Icons.person_add_alt_rounded),
              label: const Text('Resident sign'))
        ]),
        const SizedBox(height: 8),
        Text(
            dispatch['unlocked'] == true
                ? 'DISPATCH UNLOCKED • Bodhex boundary ready.'
                : 'DISPATCH LOCKED • required signatures missing.',
            style: TextStyle(
                color: dispatch['unlocked'] == true ? t.success : t.warning,
                fontWeight: FontWeight.w900,
                fontSize: 10)),
        const SizedBox(height: 8),
        FilledButton.icon(
            onPressed: dispatch['unlocked'] == true && role != 'guest'
                ? _dispatch
                : null,
            icon: const Icon(Icons.lock_open_rounded),
            label: const Text('Dispatch approved action to Bodhex')),
        if (dispatch['receipt_type'] != null)
          Text('Receipt: ${dispatch['receipt_type']}',
              style: TextStyle(color: t.mutedText, fontSize: 8))
      ]));

  Widget _outcomesPanel(CriterivoxTheme t) => _panel(
      t,
      'F+G • SHARED OUTCOME JOURNAL → MEDRUS/VIVEDA → HUMAN-APPROVED LEARNING',
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
            'Record the real-world result with attribution. Then create a learning proposal. Model/training updates remain blocked until a human approves the proposal.',
            style: TextStyle(color: t.text, fontSize: 10)),
        const SizedBox(height: 8),
        TextField(
            controller: resultCtl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Real-world result')),
        const SizedBox(height: 8),
        Wrap(spacing: 8, children: [
          FilledButton.icon(
              onPressed: role == 'guest' ? null : _recordOutcome,
              icon: const Icon(Icons.history_rounded),
              label: const Text('Log outcome')),
          OutlinedButton.icon(
              onPressed: role == 'guest' ? null : _makeLearningProposal,
              icon: const Icon(Icons.science_rounded),
              label: const Text('Create learning proposal'))
        ]),
        const SizedBox(height: 8),
        if (outcomes.isNotEmpty)
          Text(
              'Latest outcome: ${outcomes.last['selected_option']} • ${outcomes.last['result']}',
              style: TextStyle(color: t.mutedText, fontSize: 9)),
        if (learningProposal != null) ...[
          const Divider(),
          Text('LEARNING PROPOSAL • ${learningProposal!['status']}',
              style: TextStyle(
                  color: t.primary, fontWeight: FontWeight.w900, fontSize: 9)),
          Text(
              'Analyzers: Medrus + Viveda • Dataset operation: ${learningProposal!['dataset_update']?['operation']}',
              style: TextStyle(color: t.mutedText, fontSize: 9)),
          const SizedBox(height: 6),
          FilledButton.icon(
              onPressed:
                  learningProposal!['status'] == 'PENDING_HUMAN_APPROVAL' &&
                          role == 'owner'
                      ? _approveLearning
                      : null,
              icon: const Icon(Icons.approval_rounded),
              label: const Text('Human approve learning update')),
        ]
      ]));

  Widget _panel(CriterivoxTheme t, String title, Widget child) => Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: TextStyle(
                color: t.primary,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1)),
        const SizedBox(height: 10),
        child
      ]));
}
