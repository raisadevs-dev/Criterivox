import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../presentation/criterivox_theme.dart';

enum BloomCapability { analyze, compare, explore, plan, insights, explain }
enum BloomSuboption { workspace, chat }

class Bloom extends StatefulWidget {
  final ValueChanged<BloomCapability> onSelected;
  final ValueChanged<BloomSuboption>? onSuboption;
  final BloomCapability? selected;
  const Bloom({super.key, required this.onSelected, this.onSuboption, this.selected});

  static const labels = <BloomCapability, String>{BloomCapability.analyze: 'Analyze', BloomCapability.compare: 'Compare', BloomCapability.explore: 'Explore', BloomCapability.plan: 'Plan', BloomCapability.insights: 'Insights', BloomCapability.explain: 'Explain'};
  static const subtitles = <BloomCapability, String>{BloomCapability.analyze: 'Understand your data', BloomCapability.compare: 'Compare across contexts', BloomCapability.explore: 'Discover patterns and insights', BloomCapability.plan: 'Plan strategies and actions', BloomCapability.insights: 'Key takeaways at a glance', BloomCapability.explain: 'Get explanations and reasoning'};
  static const icons = <BloomCapability, IconData>{BloomCapability.analyze: Icons.bar_chart_rounded, BloomCapability.compare: Icons.balance_rounded, BloomCapability.explore: Icons.search_rounded, BloomCapability.plan: Icons.calendar_month_rounded, BloomCapability.insights: Icons.lightbulb_outline_rounded, BloomCapability.explain: Icons.chat_bubble_outline_rounded};
  static const accents = <BloomCapability, Color>{BloomCapability.analyze: Color(0xFF55B8FF), BloomCapability.compare: Color(0xFF40E7D0), BloomCapability.explore: Color(0xFFFFC94A), BloomCapability.plan: Color(0xFFFF9850), BloomCapability.insights: Color(0xFFFF58C7), BloomCapability.explain: Color(0xFFB78BFF)};

  @override State<Bloom> createState() => _BloomState();
}

class _BloomState extends State<Bloom> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  BloomCapability? expanded;
  @override void dispose() { _pulse.dispose(); super.dispose(); }
  void _select(BloomCapability capability) { setState(() => expanded = expanded == capability ? null : capability); widget.onSelected(capability); }

  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final available = math.min(constraints.maxWidth, 820.0);
      final compact = available < 600;
      final size = math.max(280.0, available);
      final height = compact ? size * .98 : size * .82;
      return SizedBox(width: size, height: height, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _pulse, builder: (_, __) => CustomPaint(size: Size(size, height), painter: _BloomPainter(selected: widget.selected, pulse: _pulse.value, accentMap: Bloom.accents))),
        _center(size, compact, t),
        ..._nodes(size, compact),
        if (expanded != null) _suboptions(size, compact),
      ]));
    });
  }

  Widget _center(double size, bool compact, CriterivoxTheme t) => AnimatedBuilder(animation: _pulse, builder: (_, __) => Container(
    width: compact ? size * .34 : size * .27, height: compact ? size * .34 : size * .27,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [t.primary.withValues(alpha: .55), t.surfaceStrong, t.page]), border: Border.all(color: t.primary, width: 2), boxShadow: [BoxShadow(color: t.primary.withValues(alpha: .26), blurRadius: 34 + _pulse.value * 14, spreadRadius: 5 + _pulse.value * 3)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const _BloomMark(size: 38), const SizedBox(height: 8), Text('Criterivox', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: Colors.white)), const SizedBox(height: 5), Text(expanded == null ? 'What would you like\nto do today?' : '${Bloom.labels[expanded!]}\nchoose a path', textAlign: TextAlign.center, style: TextStyle(color: t.text, fontSize: 11.5, height: 1.35))]),
  ));

  List<Widget> _nodes(double size, bool compact) {
    final radius = compact ? size * .34 : size * .32; final cy = compact ? size * .49 : size * .44; final d = compact ? 94.0 : 138.0;
    return [for (var i = 0; i < BloomCapability.values.length; i++) Positioned(left: size / 2 + math.cos(-math.pi / 2 + i * math.pi / 3) * radius - d / 2, top: cy + math.sin(-math.pi / 2 + i * math.pi / 3) * radius - d / 2, child: _Node(capability: BloomCapability.values[i], compact: compact, selected: expanded == BloomCapability.values[i], onTap: () => _select(BloomCapability.values[i])))];
  }

  Widget _suboptions(double size, bool compact) {
    final center = Offset(size / 2, compact ? size * .49 : size * .44); final radius = compact ? size * .21 : size * .22;
    return Stack(children: [
      Positioned(left: center.dx - radius - 70, top: center.dy + (compact ? 2 : 10), child: _Suboption(icon: Icons.dashboard_customize_rounded, title: 'Workspace', subtitle: 'Deep analysis', accent: Bloom.accents[BloomCapability.analyze]!, onTap: () => widget.onSuboption?.call(BloomSuboption.workspace))),
      Positioned(left: center.dx + radius - 70, top: center.dy + (compact ? 2 : 10), child: _Suboption(icon: Icons.forum_rounded, title: 'Chat', subtitle: 'Choose a character', accent: Bloom.accents[BloomCapability.explain]!, onTap: () => widget.onSuboption?.call(BloomSuboption.chat))),
    ]);
  }
}

class _Node extends StatelessWidget {
  final BloomCapability capability; final bool compact; final bool selected; final VoidCallback onTap;
  const _Node({required this.capability, required this.compact, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context); final accent = Bloom.accents[capability]!; final d = compact ? 94.0 : 138.0;
    final reserved = capability != BloomCapability.analyze;
    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        label: '${Bloom.labels[capability]} capability${reserved ? ', reserved' : ''}',
        child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(d), child: AnimatedContainer(duration: const Duration(milliseconds: 240), width: d, height: d, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [accent.withValues(alpha: selected ? .35 : .12), t.surfaceStrong]), border: Border.all(color: accent.withValues(alpha: selected ? 1 : .58), width: selected ? 2.4 : 1.2), boxShadow: [BoxShadow(color: accent.withValues(alpha: selected ? .35 : .10), blurRadius: selected ? 30 : 18, spreadRadius: selected ? 4 : 1)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Bloom.icons[capability], color: accent, size: compact ? 23 : 28), const SizedBox(height: 6), Text(Bloom.labels[capability]!, style: TextStyle(color: t.text, fontSize: compact ? 12 : 15, fontWeight: FontWeight.w700)), if (!compact) ...[const SizedBox(height: 4), SizedBox(width: d - 34, child: Text(Bloom.subtitles[capability]!, textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 9.5, height: 1.25)))]]))));
      ),
    );
  }
}

class _Suboption extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color accent; final VoidCallback onTap;
  const _Suboption({required this.icon, required this.title, required this.subtitle, required this.accent, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Material(color: Colors.transparent, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(17), child: Container(width: 140, height: 68, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: t.surfaceStrong.withValues(alpha: .97), borderRadius: BorderRadius.circular(17), border: Border.all(color: accent.withValues(alpha: .72)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .16), blurRadius: 22)]), child: Row(children: [Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .13)), child: Icon(icon, color: accent, size: 19)), const SizedBox(width: 8), Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: TextStyle(color: t.text, fontSize: 12.5, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text(subtitle, style: TextStyle(color: t.mutedText, fontSize: 8.8))])]))));
  }
}

class _BloomMark extends StatelessWidget {
  final double size; const _BloomMark({required this.size});
  @override
  Widget build(BuildContext context) => SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [for (var i = 0; i < 8; i++) Transform.rotate(angle: i * math.pi / 4, child: Container(width: size * .22, height: size * .48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF9A7BFF), Color(0xFF6654E8)])))), Container(width: size * .24, height: size * .24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7D68F7)))]));
}

class _BloomPainter extends CustomPainter {
  final BloomCapability? selected; final double pulse; final Map<BloomCapability, Color> accentMap;
  _BloomPainter({required this.selected, required this.pulse, required this.accentMap});
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * .44); final radius = size.width * .32;
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x263A4D92));
    for (var i = 0; i < BloomCapability.values.length; i++) {
      final cap = BloomCapability.values[i]; final angle = -math.pi / 2 + i * math.pi / 3; final end = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius); final accent = accentMap[cap]!;
      canvas.drawLine(center, end, Paint()..style = PaintingStyle.stroke..strokeWidth = selected == cap ? 2.2 : 1..color = accent.withValues(alpha: selected == cap ? .88 : .30));
      canvas.drawCircle(end, selected == cap ? 4 + pulse * 2 : 3.2, Paint()..color = accent);
    }
  }
  @override bool shouldRepaint(covariant _BloomPainter old) => old.selected != selected || old.pulse != pulse;
}
