import 'package:flutter/material.dart';
import '../../human/residence/store.dart';
import '../../presentation/shared/criterivox_theme.dart';

class HumanProfilePage extends StatefulWidget {
  final VoidCallback onPrivateRoom;
  final VoidCallback onSignIn;
  const HumanProfilePage({super.key, required this.onPrivateRoom, required this.onSignIn});
  @override
  State<HumanProfilePage> createState() => _HumanProfilePageState();
}

class _HumanProfilePageState extends State<HumanProfilePage> {
  final HumanResidenceStore _store = HumanResidenceStore();
  HumanResidenceRecord? _record;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final record = await _store.load();
    if (!mounted) return;
    setState(() { _record = record; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    final record = _record;
    final signedIn = record != null && record.metadata['authenticated'] == true;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text('HUMAN TERRITORY • ACCOUNT', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6)),
            const SizedBox(height: 8),
            Text('Profile', style: TextStyle(color: t.text, fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Account identity is kept separate from your private workspace and decision context.', style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: t.border)),
              child: _loading
                ? const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                : record == null
                  ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('No local profile found', style: TextStyle(color: t.text, fontSize: 17, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text('Sign in or create an account to establish your Human Territory profile.', style: TextStyle(color: t.mutedText, fontSize: 12)),
                      const SizedBox(height: 14),
                      FilledButton.icon(onPressed: widget.onSignIn, icon: const Icon(Icons.login_rounded), label: const Text('Sign in / Create account')),
                    ])
                  : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 26, backgroundColor: t.primary.withValues(alpha: .14), child: Icon(Icons.person_outline_rounded, color: t.primary, size: 28)),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(record.displayName.isEmpty ? 'Human Territory user' : record.displayName, style: TextStyle(color: t.text, fontSize: 18, fontWeight: FontWeight.w800)),
                          Text(signedIn ? 'Account profile' : 'Guest / local residence', style: TextStyle(color: t.mutedText, fontSize: 11)),
                        ])),
                      ]),
                      const Divider(height: 28),
                      _field(t, 'Email', record.email?.isNotEmpty == true ? record.email! : 'Not provided'),
                      _field(t, 'Residence type', record.residenceType.isEmpty ? 'Private' : record.residenceType),
                      _field(t, 'Residence ID', record.residenceId),
                      _field(t, 'Created', record.createdAt.toLocal().toString().split('.').first),
                      const SizedBox(height: 10),
                      Text('Private goals, working context, and decision materials stay in your Private Room, not on this profile screen.', style: TextStyle(color: t.mutedText, fontSize: 11, height: 1.5)),
                      const SizedBox(height: 14),
                      FilledButton.icon(onPressed: widget.onPrivateRoom, icon: const Icon(Icons.lock_outline_rounded), label: const Text('Open Private Room')),
                    ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _field(CriterivoxTheme t, String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 112, child: Text(label, style: TextStyle(color: t.mutedText, fontSize: 11))),
      Expanded(child: SelectableText(value, style: TextStyle(color: t.text, fontSize: 11, fontWeight: FontWeight.w600))),
    ]),
  );
}
