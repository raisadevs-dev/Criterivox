import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';

import 'human_residence_store.dart';
import 'interaction/bloom.dart';
import 'presentation/criterivox_theme.dart';

class HumanResidencePage extends StatefulWidget {
  final VoidCallback onGuest;
  final VoidCallback onWorkspace;
  final VoidCallback? onPrivateRoom;
  final VoidCallback? onCollaborationRoom;
  final ValueChanged<BloomActivation>? onBloomCapability;

  const HumanResidencePage({
    super.key,
    required this.onGuest,
    required this.onWorkspace,
    this.onPrivateRoom,
    this.onCollaborationRoom,
    this.onBloomCapability,
  });

  @override
  State<HumanResidencePage> createState() => _HumanResidencePageState();
}

class _HumanResidencePageState extends State<HumanResidencePage> {
  final store = HumanResidenceStore();

  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final clubName = TextEditingController();
  String avatarDataUrl = '';

  String mode = 'house';
  HumanResidenceRecord? residence;
  bool saving = false;
  String status = '';
  bool researchConsent = false;
  bool rawTextConsent = false;
  bool outcomeFollowUpConsent = false;

  @override
  void initState() {
    super.initState();
    _restore();
  }


  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    clubName.dispose();
    super.dispose();
  }

  Future<void> _restore() async {
    final r = await store.load();

    if (!mounted) {
      return;
    }

    if (r != null) {
      setState(() {
        residence = r;
        mode = r.residenceType;
        name.text = r.displayName;
        email.text = r.email ?? '';
        clubName.text = r.residenceType == 'club' ? r.displayName : '';
        researchConsent = r.metadata['research_consent'] == true;
        rawTextConsent = r.metadata['research_raw_text_consent'] == true;
        outcomeFollowUpConsent = r.metadata['research_outcome_follow_up'] == true;
      });
    }
  }

  Future<void> _pickAvatar() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    if (result == null || result.files.single.bytes == null) return;
    final file = result.files.single;
    final ext = (file.extension ?? 'png').toLowerCase();
    setState(() => avatarDataUrl = 'data:image/$ext;base64,${base64Encode(file.bytes!)}');
  }

  Future<void> _create() async {
    if (name.text.trim().isEmpty) {
      return;
    }

    setState(() {
      saving = true;
    });

    final id = 'res-${DateTime.now().millisecondsSinceEpoch}';

    final type = mode == 'club' ? 'club' : 'private';

    final display = type == 'club' && clubName.text.trim().isNotEmpty
        ? clubName.text.trim()
        : name.text.trim();

    if (password.text.length < 8) {
      setState(() { saving = false; status = 'Password must contain at least 8 characters.'; });
      return;
    }

    final record = HumanResidenceRecord(
      residenceId: id,
      ownerId: 'local-${DateTime.now().millisecondsSinceEpoch}',
      displayName: display,
      email: email.text.trim().isEmpty ? null : email.text.trim(),
      residenceType: type,
      createdAt: DateTime.now(),
      members: [
        {
          'role': 'owner',
          'owner_id': 'local',
        },
      ],
      metadata: {
        'rooms':
            type == 'club' ? ['collaboration'] : ['private', 'collaboration'],
        'local_first': true,
        'avatar_data_url': avatarDataUrl,
      },
    );

    await store.save(record);

    try {
      final authResponse = await http.post(
        Uri.base.resolve('/api/human-auth/signup'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'email': email.text.trim(), 'password': password.text, 'display_name': name.text.trim(), 'residence_id': id, 'residence_type': type, 'avatar_data_url': avatarDataUrl}),
      ).timeout(const Duration(seconds: 6));
      if (authResponse.statusCode < 200 || authResponse.statusCode >= 300) throw Exception('Signup rejected');
      final auth = jsonDecode(authResponse.body) as Map<String, dynamic>;
      final token = auth['session_token']?.toString();
      final identity = auth['identity'] is Map ? Map<String,dynamic>.from(auth['identity'] as Map) : <String,dynamic>{};
      String? researchParticipantId;
      if (researchConsent) {
        try {
          final researchResponse = await http.post(
            Uri.base.resolve('/api/research/register'),
            headers: const {'content-type': 'application/json'},
            body: jsonEncode({
              'display_name': name.text.trim(),
              'email': email.text.trim(),
            }),
          ).timeout(const Duration(seconds: 4));
          if (researchResponse.statusCode >= 200 && researchResponse.statusCode < 300) {
            final research = jsonDecode(researchResponse.body) as Map<String, dynamic>;
            researchParticipantId = research['participant_id']?.toString();
            if (researchParticipantId != null) {
              final consentResponse = await http.post(
                Uri.base.resolve('/api/research/consent'),
                headers: const {'content-type': 'application/json'},
                body: jsonEncode({
                  'participant_id': researchParticipantId,
                  'consent_version': 'v1',
                  'research_data': true,
                  'identifiable_data': true,
                  'raw_text': rawTextConsent,
                  'outcome_follow_up': outcomeFollowUpConsent,
                }),
              ).timeout(const Duration(seconds: 4));
              if (consentResponse.statusCode < 200 || consentResponse.statusCode >= 300) {
                researchParticipantId = null;
              }
            }
          }
        } catch (_) {
          researchParticipantId = null;
        }
      }
      if (token != null) {
        final saved = HumanResidenceRecord(
          residenceId: record.residenceId, ownerId: identity['owner_id']?.toString() ?? record.ownerId, displayName: record.displayName,
          email: record.email, residenceType: record.residenceType, createdAt: record.createdAt,
          members: record.members, metadata: {
            ...record.metadata,
            'session_token': token,
            if (researchParticipantId != null) 'research_participant_id': researchParticipantId,
            'research_consent': researchConsent && researchParticipantId != null,
            'research_raw_text_consent': rawTextConsent && researchParticipantId != null,
            'research_outcome_follow_up': outcomeFollowUpConsent && researchParticipantId != null,
          },
        );
        await store.save(saved);
        residence = saved;
      }
    } catch (_) {
      if (mounted) setState(() { saving = false; status = 'Signup could not be completed by the local Python runtime.'; });
      return;
    }

    try {
      final response = await http
          .post(
            Uri.base.resolve('/api/human-residence'),
            headers: {
              'content-type': 'application/json',
            },
            body: jsonEncode(record.toJson()),
          )
          .timeout(
            const Duration(seconds: 4),
          );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        status = 'Saved to browser IndexedDB and Python local mirror.';
      } else {
        status =
            'Saved to browser IndexedDB. Python mirror is currently unavailable.';
      }
    } catch (_) {
      status =
          'Saved to browser IndexedDB. Python mirror will sync when the runtime is available.';
    }

    if (!mounted) {
      return;
    }

    setState(() {
      saving = false;
      residence ??= record;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    final content = residence != null
        ? _home(t)
        : _entry(t);

    return Stack(
      children: [
        Positioned.fill(child: content),
        Positioned(
          right: 22,
          bottom: 22,
          child: _BloomResidenceLauncher(
            onCapability: widget.onBloomCapability,
          ),
        ),
      ],
    );
  }

  Widget _entry(CriterivoxTheme t) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(26, 26, 26, 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'GATE 2',
            style: TextStyle(
              color: t.success,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Human Residence',
            style: TextStyle(
              color: t.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create or restore your human residence. This is your territory, not an AI character home.',
            style: TextStyle(color: t.mutedText, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: t.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LOGIN / SIGN UP',
                  style: TextStyle(
                    color: t.text,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Local-first identity only. Passwords and authentication secrets are never persisted.',
                  style: TextStyle(color: t.mutedText, fontSize: 10),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _mode(
                        t,
                        Icons.person_add_alt_1_rounded,
                        'Sign up',
                        'Create residence',
                        'house',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _mode(
                        t,
                        Icons.login_rounded,
                        'Log in',
                        'Restore local residence',
                        'login',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: saving ? null : _continueWithGoogle,
                    icon: const Icon(Icons.account_circle_rounded),
                    label: const Text('Continue with Google'),
                  ),
                ),
                const SizedBox(height: 18),
                if (mode == 'login') ...[
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _login,
                    icon: const Icon(Icons.login_rounded),
                    label: const Text('Restore residence'),
                  ),
                ] else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _mode(
                          t,
                          Icons.home_rounded,
                          'Private House',
                          'Personal decision space',
                          'house',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _mode(
                          t,
                          Icons.groups_rounded,
                          'Create a Club',
                          'Collaboration building',
                          'club',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: name,
                    decoration: InputDecoration(
                      labelText: mode == 'club' ? 'Your name / owner' : 'Your name',
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: password,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password (8+ characters)', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: email,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  if (mode == 'club') ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: clubName,
                      decoration: const InputDecoration(
                        labelText: 'Club / building name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      border: Border.all(color: t.border),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Optional research participation', style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          'Your Criterivox use can contribute to research. Participation is optional. Passwords and authentication secrets are never collected for research.',
                          style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.4),
                        ),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          value: researchConsent,
                          onChanged: (value) => setState(() {
                            researchConsent = value ?? false;
                            if (!researchConsent) {
                              rawTextConsent = false;
                              outcomeFollowUpConsent = false;
                            }
                          }),
                          title: const Text('Allow my Criterivox sessions to be used for research'),
                          subtitle: const Text('Name and email may identify the research participant.'),
                        ),
                        if (researchConsent) ...[
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: rawTextConsent,
                            onChanged: (value) => setState(() => rawTextConsent = value ?? false),
                            title: const Text('Allow retention of my original messages'),
                            subtitle: const Text('Otherwise research uses structured interpretation/events without raw message text.'),
                          ),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: outcomeFollowUpConsent,
                            onChanged: (value) => setState(() => outcomeFollowUpConsent = value ?? false),
                            title: const Text('Allow outcome follow-up'),
                            subtitle: const Text('You may later report whether Criterivox helped and what should improve.'),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children:[
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: MemoryImage(base64Decode(avatarDataUrl.split(',').last)),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: _pickAvatar,
                      icon: const Icon(Icons.photo_camera_outlined),
                      label: const Text('Add profile photo'),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: [
                      FilledButton.icon(
                        onPressed: saving ? null : _create,
                        icon: const Icon(Icons.home_work_rounded),
                        label: Text(
                          saving
                              ? 'Creating…'
                              : mode == 'club'
                                  ? 'Create club'
                                  : 'Create my house',
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: widget.onGuest,
                        icon: const Icon(Icons.confirmation_number_rounded),
                        label: const Text('Guest Pass'),
                      ),
                    ],
                  ),
                ],
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(status, style: TextStyle(color: t.success, fontSize: 10)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Your Human Residence identity is stored locally in Criterivox SQLite for V1; the browser keeps the active session in IndexedDB.',
            style: TextStyle(color: t.mutedText, fontSize: 10, height: 1.4),
          ),
        ],
      ),
    );
  }
  Future<void> _login() async {
    if (email.text.trim().isEmpty || password.text.length < 8) {
      setState(() => status = 'Enter your email and 8+ character password.');
      return;
    }
    try {
      final response = await http.post(
        Uri.base.resolve('/api/human-auth/login'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'email': email.text.trim(), 'password': password.text}),
      ).timeout(const Duration(seconds: 6));
      if (response.statusCode < 200 || response.statusCode >= 300) throw Exception('Login rejected');
      final payload = jsonDecode(response.body) as Map<String, dynamic>;
      final identity = Map<String, dynamic>.from(payload['identity'] as Map);
      final existing = await store.load();
      if (!mounted) return;
      if (existing == null) {
        setState(() => status = 'Identity authenticated, but no local residence record was found.');
        return;
      }
      setState(() {
        residence = existing;
        mode = existing.residenceType;
        name.text = identity['display_name']?.toString() ?? existing.displayName;
        status = 'Residence restored from authenticated local identity.';
      });
    } catch (_) {
      if (mounted) setState(() => status = 'Login unavailable or credentials rejected.');
    }
  }

  Widget _mode(
    CriterivoxTheme t,
    IconData icon,
    String title,
    String sub,
    String value,
  ) {
    return InkWell(
      onTap: () {
        setState(() {
          mode = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: mode == value ? t.surfaceStrong : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: mode == value ? t.success : t.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: mode == value ? t.success : t.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: t.text,
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              sub,
              style: TextStyle(
                color: t.mutedText,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _home(CriterivoxTheme t) {
    final currentResidence = residence!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'YOUR HUMAN RESIDENCE',
            style: TextStyle(
              color: t.success,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 7),
          Row(children:[
            CircleAvatar(
              radius: 24,
              backgroundImage: currentResidence.metadata['avatar_data_url'] is String
                  ? MemoryImage(base64Decode((currentResidence.metadata['avatar_data_url'] as String).split(',').last))
                  : null,
              child: currentResidence.metadata['avatar_data_url'] is String ? null : const Icon(Icons.person_rounded),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(
              currentResidence.displayName,
              style: TextStyle(color: t.text, fontSize: 28, fontWeight: FontWeight.w800),
            )),
          ]),
          const SizedBox(height: 5),
          Text(
            currentResidence.residenceType == 'club'
                ? 'Collaboration building'
                : 'Private house',
            style: TextStyle(
              color: t.mutedText,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          if (status.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              status,
              style: TextStyle(
                color: t.success,
                fontSize: 10,
              ),
            ),
          ],
          if (currentResidence.metadata['research_consent'] == true &&
              currentResidence.metadata['research_outcome_follow_up'] == true) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.surfaceStrong,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: t.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.science_outlined, color: t.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Research follow-up', style: TextStyle(color: t.text, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                          'Tell Criterivox whether the work helped, what happened in the real world, and what should improve.',
                          style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: _recordResearchOutcome,
                    child: const Text('Record outcome'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _room(
                  t,
                  Icons.bed_rounded,
                  'Private Room',
                  currentResidence.residenceType == 'club'
                      ? 'Personal decision space within your club'
                      : 'Goal → Data + Context → Decisions + Options → Challenge → Act → Result',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _room(
                  t,
                  Icons.groups_rounded,
                  'Collaboration Room',
                  'House Owner • Resident • Guest',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: t.surfaceStrong,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: t.border,
              ),
            ),
            child: Text(
              'RESULTS JOURNAL\n\n'
              'Decisions → actions → real results → future decisions',
              style: TextStyle(
                color: t.text,
                fontSize: 11,
                height: 1.6,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: widget.onPrivateRoom ?? widget.onWorkspace,
                icon: const Icon(Icons.lock_outline_rounded),
                label: const Text('Enter Private Room'),
              ),
              OutlinedButton.icon(
                onPressed: widget.onCollaborationRoom,
                icon: const Icon(Icons.groups_rounded),
                label: const Text('Enter Collaboration Room'),
              ),
              OutlinedButton.icon(
                onPressed: widget.onWorkspace,
                icon: const Icon(Icons.fact_check_outlined),
                label: const Text('Decision Desk'),
              ),
              OutlinedButton.icon(
                onPressed: widget.onPrivateRoom ?? widget.onWorkspace,
                icon: const Icon(Icons.menu_book_outlined),
                label: const Text('Results Journal'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _recordResearchOutcome() async {
    final success = TextEditingController();
    final helpful = TextEditingController();
    final improvement = TextEditingController();
    final summary = TextEditingController();

    final values = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Research outcome'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: 'succeeded',
                items: const [
                  DropdownMenuItem(value: 'succeeded', child: Text('Succeeded')),
                  DropdownMenuItem(value: 'partial', child: Text('Partly succeeded')),
                  DropdownMenuItem(value: 'not_succeeded', child: Text('Did not succeed')),
                  DropdownMenuItem(value: 'unknown', child: Text('Not known yet')),
                ],
                onChanged: (value) => success.text = value ?? 'unknown',
                decoration: const InputDecoration(labelText: 'Outcome'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: helpful,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'How helpful was Criterivox? (0–10)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: summary,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'What happened?'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: improvement,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'What should Criterivox improve?'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogContext).pop(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop({
              'success_state': success.text.isEmpty ? 'unknown' : success.text,
              'helped_score': helpful.text.trim(),
              'outcome_summary': summary.text.trim(),
              'improvement_request': improvement.text.trim(),
            }),
            child: const Text('Save outcome'),
          ),
        ],
      ),
    );

    success.dispose();
    helpful.dispose();
    improvement.dispose();
    summary.dispose();

    if (values == null) return;
    final participantId = residence?.metadata['research_participant_id']?.toString();
    if (participantId == null) return;

    try {
      final response = await http.post(
        Uri.base.resolve('/api/research/outcome'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'participant_id': participantId,
          'success_state': values['success_state'],
          'helped_score': double.tryParse(values['helped_score'] ?? ''),
          'outcome_summary': values['outcome_summary'],
          'improvement_request': values['improvement_request'],
        }),
      ).timeout(const Duration(seconds: 5));

      if (!mounted) return;
      setState(() {
        status = response.statusCode >= 200 && response.statusCode < 300
            ? 'Research outcome recorded.'
            : 'Research outcome could not be recorded.';
      });
    } catch (_) {
      if (mounted) setState(() => status = 'Research outcome could not be recorded.');
    }
  }

  Widget _room(
    CriterivoxTheme t,
    IconData icon,
    String title,
    String body,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: t.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: t.primary,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: t.text,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: TextStyle(
              color: t.mutedText,
              fontSize: 10,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class GuestPassPage extends StatelessWidget {
  final VoidCallback onWorkspace;

  const GuestPassPage({
    super.key,
    required this.onWorkspace,
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(30),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 680),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: t.primary.withValues(alpha: .3),
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.confirmation_number_rounded,
                size: 42,
              ),
              const SizedBox(height: 14),
              Text(
                'GUEST PASS',
                style: TextStyle(
                  color: t.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Experience Criterivox before building a house.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.text,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bring a Goal + Data + Context. Inspect decision support, then leave without a permanent residence.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: t.mutedText,
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onWorkspace,
                icon: const Icon(
                  Icons.play_arrow_rounded,
                ),
                label: const Text(
                  'Start guest workspace',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BloomResidenceLauncher extends StatefulWidget {
  final ValueChanged<BloomActivation>? onCapability;

  const _BloomResidenceLauncher({
    this.onCapability,
  });

  @override
  State<_BloomResidenceLauncher> createState() =>
      _BloomResidenceLauncherState();
}

class _BloomResidenceLauncherState extends State<_BloomResidenceLauncher> {
  bool open = false;
  BloomCapability? selected;

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (open)
            Container(
              width: 380,
              constraints: const BoxConstraints(maxHeight: 540),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: t.page.withValues(alpha: .97),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: t.border),
                boxShadow: const [
                  BoxShadow(blurRadius: 28, spreadRadius: 2),
                ],
              ),
              child: SingleChildScrollView(
                child: Bloom(
                  selected: selected,
                  onSelected: (capability) {
                    setState(() {
                      selected =
                          selected == capability ? null : capability;
                    });
                  },
                  onOpenCapability: widget.onCapability,
                ),
              ),
            ),
          FloatingActionButton(
            heroTag: 'human-residence-bloom',
            tooltip: open ? 'Close Bloom' : 'Open Bloom',
            onPressed: () {
              setState(() {
                open = !open;
                if (!open) selected = null;
              });
            },
            child: Icon(
              open ? Icons.close_rounded : Icons.auto_awesome_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
