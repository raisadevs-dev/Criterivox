import 'package:flutter/material.dart';

import 'character/character_presentation.dart';
import 'presentation/presentation_adapter.dart';
import 'presentation/presentation_state.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
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
  final PresentationAdapter _adapter = const PresentationAdapter();

  late PresentationState _presentationState;

  @override
  void initState() {
    super.initState();

    _presentationState = _adapter.adapt(
      agentId: 'Dharen',
      characterState: 'IDLE',
      active: true,
    );
  }

  void _setCharacterState(String characterState) {
    setState(() {
      _presentationState = _presentationState.copyWith(
        characterState: characterState,
        active: true,
      );
    });
  }

  void _setQuiet() {
    setState(() {
      _presentationState = _presentationState.copyWith(
        characterState: 'IDLE',
        active: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criterivox'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 48,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Character Interaction',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Criterivox agents respond through presentation state.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    CharacterPresentation(
                      state: _presentationState,
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StateButton(
                          label: 'IDLE',
                          onPressed: () => _setCharacterState('IDLE'),
                        ),
                        _StateButton(
                          label: 'RECEIVE',
                          onPressed: () => _setCharacterState('RECEIVE'),
                        ),
                        _StateButton(
                          label: 'WORK',
                          onPressed: () => _setCharacterState('WORK'),
                        ),
                        _StateButton(
                          label: 'COMMUNICATE',
                          onPressed: () =>
                              _setCharacterState('COMMUNICATE'),
                        ),
                        _StateButton(
                          label: 'HANDOFF',
                          onPressed: () => _setCharacterState('HANDOFF'),
                        ),
                        _StateButton(
                          label: 'COMPLETE',
                          onPressed: () =>
                              _setCharacterState('COMPLETE'),
                        ),
                        _StateButton(
                          label: 'WARNING',
                          onPressed: () =>
                              _setCharacterState('WARNING'),
                        ),
                        _StateButton(
                          label: 'QUIET',
                          onPressed: _setQuiet,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StateButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _StateButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(label),
    );
  }
}