import 'package:flutter/material.dart';

import 'character/character_presentation.dart';
import 'interaction/bloom.dart';
import 'interaction/syvax.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

void main() => runApp(const CriterivoxApp());

class CriterivoxApp extends StatelessWidget {
  const CriterivoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Criterivox',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const CriterivoxPresentationScreen(),
    );
  }
}

class CriterivoxPresentationScreen extends StatefulWidget {
  const CriterivoxPresentationScreen({super.key});

  @override
  State<CriterivoxPresentationScreen> createState() => _CriterivoxPresentationScreenState();
}

class _CriterivoxPresentationScreenState extends State<CriterivoxPresentationScreen> {
  final CharacterRuntimeClient _runtime = CharacterRuntimeClient();
  PresentationState? _presentationState;
  String? _error;
  String _systemMessage = 'Syvax is ready. Choose a capability or describe what you want to do.';
  BloomCapability? _selectedCapability;
  bool _busy = false;

  static const _data = <String, dynamic>{
    'views': 1200,
    'likes': 84,
    'comments': 17,
  };

  static const _context = <String, dynamic>{
    'platform': 'synthetic',
    'audience': 'students',
  };

  @override
  void initState() {
    super.initState();
    _runtime.states.listen((state) {
      if (!mounted) return;
      setState(() {
        _presentationState = state;
        _busy = state.characterState != 'IDLE';
        _error = null;
        if (state.message != null) _systemMessage = state.message!;
      });
    });
    _runtime.errors.listen((error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _busy = false;
        _systemMessage = 'Syvax could not complete that request.';
      });
    });
    _runtime.connect();
  }

  void _submitSyvax(String task) {
    _submitApplication(task: task, source: 'syvax');
  }

  void _selectBloom(BloomCapability capability) {
    setState(() => _selectedCapability = capability);
    if (capability != BloomCapability.analyze) {
      setState(() => _systemMessage = '${Bloom.labels[capability]} is reserved for a future sprint.');
      return;
    }
    _submitApplication(
      task: 'Analyze the supplied data in the provided context.',
      source: 'bloom',
    );
  }

  void _submitApplication({required String task, required String source}) {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _systemMessage = 'Syvax is sending your intent into the application system.';
    });
    _runtime.requestApplication(
      intent: 'analyze',
      task: task,
      data: _data,
      context: _context,
      source: source,
    );
  }

  @override
  void dispose() {
    _runtime.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _presentationState;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criterivox'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1000;
            final content = [
              Syvax(onSubmit: _submitSyvax, busy: _busy),
              const SizedBox(height: 20),
              Text('What do you want to do now?', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Center(child: Bloom(onSelected: _selectBloom, selected: _selectedCapability)),
              const SizedBox(height: 12),
              Semantics(
                liveRegion: true,
                label: 'Syvax system status',
                child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_systemMessage))),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Semantics(
                  liveRegion: true,
                  label: 'Runtime error',
                  child: Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              ],
              const SizedBox(height: 20),
              if (state != null) CharacterPresentation(state: state),
            ];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: wide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content.sublist(0, 5))),
                          const SizedBox(width: 32),
                          Expanded(child: Column(children: [if (state != null) CharacterPresentation(state: state)])),
                        ])
                      : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: content),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
