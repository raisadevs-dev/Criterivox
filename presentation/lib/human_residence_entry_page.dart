import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'human_residence_store.dart';
import 'presentation/api_client.dart';
import 'presentation/criterivox_theme.dart';

class HumanResidenceEntryPage extends StatefulWidget {
  final VoidCallback onOpenResidence;
  final VoidCallback onGuest;
  const HumanResidenceEntryPage({super.key, required this.onOpenResidence, required this.onGuest});
  @override State<HumanResidenceEntryPage> createState() => _HumanResidenceEntryPageState();
}

class _HumanResidenceEntryPageState extends State<HumanResidenceEntryPage> {
  final name = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  bool signup = true, busy = false;
  String error = '';

  @override void dispose() { name.dispose(); email.dispose(); password.dispose(); super.dispose(); }

  Future<void> _submit() async {
    final mail = email.text.trim(), pass = password.text;
    if (mail.isEmpty || pass.isEmpty || (signup && name.text.trim().isEmpty)) {
      setState(() => error = signup ? 'Name, email and password are required.' : 'Email and password are required.');
      return;
    }
    setState(() { busy = true; error = ''; });
    try {
      final generatedResidenceId = 'residence-' + DateTime.now().microsecondsSinceEpoch.toString();
      final response = await http.post(
        CriterivoxApi.uri(signup ? '/api/human-auth/signup' : '/api/human-auth/login'),
        headers: const {'content-type': 'application/json'},
        body: jsonEncode({
          'email': mail, 'password': pass,
          if (signup) 'display_name': name.text.trim(),
          if (signup) 'residence_id': generatedResidenceId,
          if (signup) 'residence_type': 'private',
        }),
      ).timeout(const Duration(seconds: 10));
      final body = jsonDecode(response.body);
      if (response.statusCode < 200 || response.statusCode >= 300 || body is! Map || body['accepted'] != true) {
        throw Exception(body is Map ? body['error'] ?? 'Authentication failed' : 'Authentication failed');
      }
      final identity = Map<String, dynamic>.from(body['identity'] as Map);
      final residences = body['residences'] is List ? body['residences'] : const [];
      final first = residences.isNotEmpty && residences.first is Map ? Map<String, dynamic>.from(residences.first as Map) : <String, dynamic>{};
      final id = (first['residence_id'] ?? generatedResidenceId).toString();
      await HumanResidenceStore().save(HumanResidenceRecord(
        residenceId: id,
        ownerId: identity['owner_id']?.toString() ?? '',
        displayName: identity['display_name']?.toString() ?? name.text.trim(),
        email: identity['email']?.toString() ?? mail,
        residenceType: first['residence_type']?.toString() ?? 'private',
        createdAt: DateTime.tryParse(first['created_at']?.toString() ?? '') ?? DateTime.now(),
        metadata: {'session_token': body['session_token']?.toString() ?? '', 'authenticated': true, 'goal': '', 'data': '', 'context': ''},
      ));
      if (mounted) widget.onOpenResidence();
    } catch (e) {
      if (mounted) setState(() => error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 560),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('HUMAN TERRITORY', style: TextStyle(color: t.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
        const SizedBox(height: 8),
        Text(signup ? 'Create your private residence' : 'Sign in to your residence', style: TextStyle(color: t.text, fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text('Your residence holds your context, decisions and results. The system world remains separate.', style: TextStyle(color: t.mutedText, fontSize: 12, height: 1.5)),
        const SizedBox(height: 22),
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: t.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (signup) ...[TextField(controller: name, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Your name')), const SizedBox(height: 12)],
          TextField(controller: email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next, decoration: const InputDecoration(labelText: 'Email')),
          const SizedBox(height: 12),
          TextField(controller: password, obscureText: true, onSubmitted: (_) { if (!busy) _submit(); }, decoration: InputDecoration(labelText: 'Password', helperText: signup ? 'Use at least 8 characters.' : null)),
          if (error.isNotEmpty) ...[const SizedBox(height: 12), Text(error, style: TextStyle(color: t.danger, fontSize: 11))],
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: busy ? null : _submit, icon: Icon(signup ? Icons.person_add_alt_1_rounded : Icons.login_rounded), label: Text(busy ? 'Connecting…' : signup ? 'Create account' : 'Sign in')),
          const SizedBox(height: 8),
          TextButton(onPressed: busy ? null : () => setState(() { signup = !signup; error = ''; }), child: Text(signup ? 'Already have an account? Sign in' : 'Need an account? Create one')),
        ])),
        const SizedBox(height: 14),
        OutlinedButton.icon(onPressed: busy ? null : widget.onGuest, icon: const Icon(Icons.confirmation_number_outlined), label: const Text('Continue as Guest')),
      ]),
    )));
  }
}
