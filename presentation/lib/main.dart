import 'dart:convert';

import 'package:flutter/material.dart';

import 'character/character_presentation.dart';
import 'presentation/presentation_state.dart';
import 'presentation/runtime_client.dart';

void main() {
  runApp(const CriterivoxApp());
}

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
  State<CriterivoxPresentationScreen> createState() =>
      _CriterivoxPresentationScreenState();
}

class _CriterivoxPresentationScreenState
    extends State<CriterivoxPresentationScreen> {
  final CharacterRuntimeClient _runtime = CharacterRuntimeClient();
  final TextEditingController _dataController = TextEditingController(
    text: '{"views": 1200, "likes": 84, "comments": 17}',
  );
  final TextEditingController _contextController = TextEditingController(
    text: '{"platform": "synthetic", "audience": "students"}',
  );
  final TextEditingController _taskController = TextEditingController(
    text: 'Analyze the supplied data in the provided context.',
  );

  PresentationState? _presentationState;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runtime.states.listen((state) {
      if (!mounted) return;
      setState(() {
        _presentationState = state;
        _error = null;
      });
    });
    _runtime.errors.listen((error) {
      if (!mounted) return;
      setState(() => _error = error);
    });
    _runtime.connect();
  }

  void _requestAnalysis() {
    try {
      final data = _decodeObject(_dataController.text, 'Data');
      final context = _decodeObject(_contextController.text, 'Context');
      final task = _taskController.text.trim();
      if (task.isEmpty) throw const FormatException('Task cannot be empty.');

      setState(() => _error = null);
      _runtime.requestAnalysis(
        data: data,
        context: context,
        task: task,
      );
    } on FormatException catch (error) {
      setState(() => _error = error.message);
    }
  }

  Map<String, dynamic> _decodeObject(String raw, String label) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('$label must be a JSON object.');
    }
    return decoded;
  }

  @override
  void dispose() {
    _dataController.dispose();
    _contextController.dispose();
    _taskController.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Runtime Character Interaction',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Python-originated character state is rendered here. Flutter does not invent the lifecycle.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),
                  if (state == null)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          'Waiting for the Python runtime connection…',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    CharacterPresentation(state: state),
                  if (state?.message != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      label: 'Dharen status',
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(state!.message!),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  _InputField(
                    controller: _dataController,
                    label: 'Synthetic data (JSON object)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _contextController,
                    label: 'Synthetic context (JSON object)',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    controller: _taskController,
                    label: 'Task',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _requestAnalysis,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Send analysis request to Python'),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Semantics(
                      liveRegion: true,
                      label: 'Runtime error',
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;

  const _InputField({
    required this.controller,
    required this.label,
    required this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
