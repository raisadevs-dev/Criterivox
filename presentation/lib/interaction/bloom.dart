import 'dart:math' as math;

import 'package:flutter/material.dart';

enum BloomCapability { analyze, compare, explore, plan, insights, explain }

class Bloom extends StatelessWidget {
  final ValueChanged<BloomCapability> onSelected;
  final BloomCapability? selected;
  const Bloom({super.key, required this.onSelected, this.selected});

  static const labels = {
    BloomCapability.analyze: 'Analyze', BloomCapability.compare: 'Compare', BloomCapability.explore: 'Explore',
    BloomCapability.plan: 'Plan', BloomCapability.insights: 'Insights', BloomCapability.explain: 'Explain',
  };
  static const subtitles = {
    BloomCapability.analyze: 'Understand your data', BloomCapability.compare: 'Compare across contexts',
    BloomCapability.explore: 'Discover patterns and insights', BloomCapability.plan: 'Plan strategies and actions',
    BloomCapability.insights: 'Key takeaways at a glance', BloomCapability.explain: 'Get explanations and reasoning',
  };
  static const icons = {
    BloomCapability.analyze: Icons.bar_chart_rounded, BloomCapability.compare: Icons.balance_rounded,
    BloomCapability.explore: Icons.search_rounded, BloomCapability.plan: Icons.calendar_month_rounded,
    BloomCapability.insights: Icons.lightbulb_outline_rounded, BloomCapability.explain: Icons.chat_bubble_outline_rounded,
  };
  static const accents = <BloomCapability, Color>{
    BloomCapability.analyze: Color(0xFF55B8FF), BloomCapability.compare: Color(0xFF40E7D0),
    BloomCapability.explore: Color(0xFFFFC94A), BloomCapability.plan: Color(0xFFFF9850),
    BloomCapability.insights: Color(0xFFFF58C7), BloomCapability.explain: Color(0xFFB78BFF),
  };

  @override
  Widget build(BuildContext context) => Semantics(
        container: true, label: 'Bloom capability gateway', hint: 'Choose what you want to do in Criterivox.',
        child: LayoutBuilder(builder: (context, constraints) {
          final size = math.min(constraints.maxWidth, 760.0);
          final compact = size < 610;
          final height = compact ? size * .94 : size * .88;
          return SizedBox(width: size, height: height, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            CustomPaint(size: Size(size, height), painter: _BloomConnections(selected: selected)),
            _BloomCenter(size: compact ? size * .34 : size * .30),
            ..._nodes(size, compact),
            Positioned(top: 2, child: _BloomHint(compact: compact)),
          ]));
        }),
      );

  List<Widget> _nodes(double size, bool compact) {
    final radius = compact ? size * .33 : size * .32;
    final centerY = compact ? size * .48 : size * .44;
    final diameter = compact ? 112.0 : 146.0;
    return [for (var i = 0; i < BloomCapability.values.length; i++)
      Positioned(
        left: size / 2 + math.cos(-math.pi / 2 + i * math.pi / 3) * radius - diameter / 2,
        top: centerY + math.sin(-math.pi / 2 + i * math.pi / 3) * radius - diameter / 2,
        child: _CapabilityNode(
          label: labels[BloomCapability.values[i]]!, subtitle: subtitles[BloomCapability.values[i]]!,
          icon: icons[BloomCapability.values[i]]!, accent: accents[BloomCapability.values[i]]!,
          selected: selected == BloomCapability.values[i], enabled: BloomCapability.values[i] == BloomCapability.analyze,
          compact: compact, onTap: () => onSelected(BloomCapability.values[i]),
        ),
      )];
  }
}

class _BloomHint extends StatelessWidget {
  final bool compact;
  const _BloomHint({required this.compact});
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 13 : 19, vertical: compact ? 8 : 11),
        decoration: BoxDecoration(color: const Color(0xD911142F), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0x332E4A9B)), boxShadow: const [BoxShadow(color: Color(0x331A3DFF), blurRadius: 24, spreadRadius: 2)]),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF8E7CFF), size: 17), const SizedBox(width: 9),
          Text('Click a primary option to explore capabilities', style: TextStyle(color: Colors.white.withOpacity(.82), fontSize: compact ? 10.5 : 12.5)),
        ]),
      );
}

class _BloomCenter extends StatelessWidget {
  final double size;
  const _BloomCenter({required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(colors: [Color(0xFF352675), Color(0xFF18163E), Color(0xFF0A0C23)], stops: [0, .58, 1]),
          border: Border.all(color: const Color(0xFFB69AFF), width: 2),
          boxShadow: const [BoxShadow(color: Color(0x775B4CFF), blurRadius: 44, spreadRadius: 10), BoxShadow(color: Color(0x3387CFFF), blurRadius: 90, spreadRadius: 18)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const _BloomMark(size: 39), const SizedBox(height: 9),
          const Text('Criterivox', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)), const SizedBox(height: 7),
          Text('What would you like\nto do today?', textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(.86), fontSize: 12, height: 1.4)),
        ]),
      );
}

class _BloomMark extends StatelessWidget {
  final double size;
  const _BloomMark({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [
        for (var i = 0; i < 8; i++) Transform.rotate(angle: i * math.pi / 4, child: Container(width: size * .22, height: size * .48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF9A7BFF), Color(0xFF6654E8)])))),
        Container(width: size * .24, height: size * .24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7D68F7))),
      ]));
}

class _BloomConnections extends CustomPainter {
  final BloomCapability? selected;
  _BloomConnections({required this.selected});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .44);
    final radius = size.width * .32;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x263A4D92);
    canvas.drawCircle(center, radius, orbitPaint);
    for (var i = 0; i < BloomCapability.values.length; i++) {
      final capability = BloomCapability.values[i];
      final angle = -math.pi / 2 + i * math.pi / 3;
      final end = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      final accent = Bloom.accents[capability]!;
      final linePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = selected == capability ? 2 : 1
        ..color = accent.withOpacity(selected == capability ? .85 : .38);
      canvas.drawLine(center, end, linePaint);
      canvas.drawCircle(end, 3.5, Paint()..color = accent);
    }
  }
  @override bool shouldRepaint(covariant _BloomConnections oldDelegate) => oldDelegate.selected != selected;
}

class _CapabilityNode extends StatelessWidget {
  final String label, subtitle; final IconData icon; final Color accent; final bool selected, enabled, compact; final VoidCallback onTap;
  const _CapabilityNode({required this.label, required this.subtitle, required this.icon, required this.accent, required this.selected, required this.enabled, required this.compact, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final diameter = compact ? 112.0 : 146.0;
    return Semantics(button: true, enabled: enabled, label: '$label capability${enabled ? '' : ', reserved for a future sprint'}', hint: enabled ? 'Activate $label' : 'Not implemented yet', child: Tooltip(
      message: enabled ? 'Activate $label' : '$label is reserved for a future sprint',
      child: InkWell(onTap: enabled ? onTap : null, borderRadius: BorderRadius.circular(diameter), child: AnimatedContainer(
        duration: const Duration(milliseconds: 220), width: diameter, height: diameter, padding: EdgeInsets.all(compact ? 14 : 18),
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [accent.withOpacity(selected ? .34 : .18), const Color(0xFF10132E)]), border: Border.all(color: accent.withOpacity(selected ? .98 : .70), width: selected ? 2.2 : 1.3), boxShadow: [BoxShadow(color: accent.withOpacity(selected ? .46 : .19), blurRadius: selected ? 36 : 25, spreadRadius: selected ? 5 : 1)]),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: enabled ? accent : accent.withOpacity(.55), size: compact ? 25 : 30), SizedBox(height: compact ? 5 : 8), Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(enabled ? 1 : .72), fontSize: compact ? 13 : 16, fontWeight: FontWeight.w600)), if (!compact) ...[const SizedBox(height: 5), Text(subtitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(.66), fontSize: 10.5, height: 1.25))]],
        ),
      )),
    ));
  }
}