import 'package:flutter/material.dart';

import '../character/live_agent_panel.dart';
import '../presentation/criterivox_theme.dart';
import 'kaelen_presentation.dart';

class KaelenWorkspacePage extends StatelessWidget {
  final String state;

  const KaelenWorkspacePage({
    super.key,
    this.state = 'IDLE',
  });

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kaelen Build & Experimentation',
            style: TextStyle(
              color: t.text,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Build, transformation, streaming and vector preparation',
            style: TextStyle(color: t.mutedText, fontSize: 11),
          ),
          const SizedBox(height: 14),
          LiveAgentPanel(
            characterId: KaelenPresentation.characterId,
            responsibility: KaelenPresentation.role,
            workDescription:
                'Owns transformation engineering, pipeline construction, schema repair, streaming and vector preparation.',
            state: state,
          ),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  MediaQuery.sizeOf(context).width > 1050 ? 3 : 1,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
            ),
            itemCount: KaelenPresentation.capabilities.length,
            itemBuilder: (_, index) {
              final capability = KaelenPresentation.capabilities[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: t.surfaceStrong,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: t.border),
                ),
                child: Row(
                  children: [
                    Icon(capability.icon, color: t.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capability.label,
                            style: TextStyle(
                              color: t.text,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            capability.description,
                            style: TextStyle(
                              color: t.mutedText,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
