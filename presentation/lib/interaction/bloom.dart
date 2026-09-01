import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BloomCapability { analyze, compare, explore, plan, insights, explain }

class Bloom extends StatelessWidget {
  final ValueChanged<BloomCapability> onSelected;
  final BloomCapability? selected;

  const Bloom({super.key, required this.onSelected, this.selected});

  static const labels = {
    BloomCapability.analyze: 'Analyze',
    BloomCapability.compare: 'Compare',
    BloomCapability.explore: 'Explore',
    BloomCapability.plan: 'Plan',
    BloomCapability.insights: 'Insights',
    BloomCapability.explain: 'Explain',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: 'Bloom capability gateway',
      hint: 'Choose what you want to do in Criterivox.',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, 520.0);
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size * .46,
                  height: size * .46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'BLOOM',
                      style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 2),
                    ),
                  ),
                ),
                ..._nodes(context, size),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _nodes(BuildContext context, double size) {
    final entries = BloomCapability.values;
    final radius = size * .34;
    return [
      for (var i = 0; i < entries.length; i++)
        Positioned(
          left: size / 2 + math.cos(-math.pi / 2 + i * math.pi / 3) * radius - 54,
          top: size / 2 + math.sin(-math.pi / 2 + i * math.pi / 3) * radius - 28,
          child: _CapabilityNode(
            capability: entries[i],
            label: labels[entries[i]]!,
            selected: selected == entries[i],
            enabled: entries[i] == BloomCapability.analyze,
            onTap: () => onSelected(entries[i]),
          ),
        ),
    ];
  }
}

class _CapabilityNode extends StatelessWidget {
  final BloomCapability capability;
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _CapabilityNode({
    required this.capability,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$label capability${enabled ? '' : ', reserved for a future sprint'}',
      hint: enabled ? 'Activate $label' : 'Not implemented yet',
      child: Tooltip(
        message: enabled ? 'Activate $label' : '$label is reserved for a future sprint',
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(18),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 108,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? scheme.primaryContainer : scheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? scheme.primary : scheme.outlineVariant,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: enabled ? null : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
