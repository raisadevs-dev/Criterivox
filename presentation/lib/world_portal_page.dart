import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
  final clubName = TextEditingController();

  String mode = 'house';
  HumanResidenceRecord? residence;
  bool saving = false;
  String status = '';

  @override
  void initState() {
    super.initState();
    _restore();
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    clubName.dispose();
    password.dispose();
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
      });
    }
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
      },
    );

    await store.save(record);

    try {
      final authResponse = await http.post(
        Uri.base.resolve('/api/human-auth/signup'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({'email': email.text.trim(), 'password': password.text, 'display_name': name.text.trim(), 'residence_id': id, 'residence_type': type}),
      ).timeout(const Duration(seconds: 6));
      if (authResponse.statusCode < 200 || authResponse.statusCode >= 300) throw Exception('Signup rejected');
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
      residence = record;
      saving = false;
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
            'The local Login / Sign up flow provisions an application identity and workspace record. It is not production authentication.',
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
          Text(
            currentResidence.displayName,
            style: TextStyle(
              color: t.text,
              fontSize: 28,
              fontWeight: FontWeight.w800,
            ),
          ),
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
            border: Border.all(color: t.primary.withValues(alpha: .3)),
          ),
          child: Column(
            children: [
              const Icon(Icons.confirmation_number_rounded, size: 42),
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
                'Bring a Goal + Data + Context. The Guest Pass starts an isolated workspace session without creating a permanent residence.',
                textAlign: TextAlign.center,
                style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onWorkspace,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start guest workspace'),
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
