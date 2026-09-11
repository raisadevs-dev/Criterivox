import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../presentation/criterivox_theme.dart';

enum BloomCapability { analyze, stewardship, compare, explore, plan, insights, explain }
enum BloomSuboption { workspace, chat, stewardshipHome, stewardshipChat }

class BloomOwner {
  final String id;
  final String name;
  final String responsibility;
  final IconData icon;
  const BloomOwner(this.id, this.name, this.responsibility, this.icon);
}

class Bloom extends StatefulWidget {
  final ValueChanged<BloomCapability> onSelected;
  final ValueChanged<BloomSuboption>? onSuboption;
  final ValueChanged<BloomCapability>? onOwnerChat;
  final BloomCapability? selected;

  const Bloom({super.key, required this.onSelected, this.onSuboption, this.onOwnerChat, this.selected});

  static const labels = <BloomCapability, String>{
    BloomCapability.analyze: 'Analyze', BloomCapability.stewardship: 'Data Stewardship',
    BloomCapability.compare: 'Compare', BloomCapability.explore: 'Explore', BloomCapability.plan: 'Plan',
    BloomCapability.insights: 'Insights', BloomCapability.explain: 'Explain',
  };
  static const subtitles = <BloomCapability, String>{
    BloomCapability.analyze: 'Understand your data', BloomCapability.stewardship: 'Protect the data foundation',
    BloomCapability.compare: 'Compare across contexts', BloomCapability.explore: 'Discover patterns',
    BloomCapability.plan: 'Deliberate on next steps', BloomCapability.insights: 'Surface useful insight',
    BloomCapability.explain: 'Show evidence and reasoning',
  };
  static const icons = <BloomCapability, IconData>{
    BloomCapability.analyze: Icons.bar_chart_rounded, BloomCapability.stewardship: Icons.inventory_2_rounded,
    BloomCapability.compare: Icons.balance_rounded, BloomCapability.explore: Icons.search_rounded,
    BloomCapability.plan: Icons.calendar_month_rounded, BloomCapability.insights: Icons.lightbulb_outline_rounded,
    BloomCapability.explain: Icons.chat_bubble_outline_rounded,
  };
  static const accents = <BloomCapability, Color>{
    BloomCapability.analyze: Color(0xFF55B8FF), BloomCapability.stewardship: Color(0xFF40E7D0),
    BloomCapability.compare: Color(0xFF40E7D0), BloomCapability.explore: Color(0xFFFFC94A),
    BloomCapability.plan: Color(0xFFFF9850), BloomCapability.insights: Color(0xFFFF58C7),
    BloomCapability.explain: Color(0xFFB78BFF),
  };

  // Dharen owns context structure, not every Criterivox capability.
  static const owners = <BloomCapability, BloomOwner>{
    BloomCapability.analyze: BloomOwner('vivren', 'Vivren', 'Discernment', Icons.visibility_rounded),
    BloomCapability.stewardship: BloomOwner('sandre', 'Sandre', 'Data Stewardship', Icons.inventory_2_rounded),
    BloomCapability.compare: BloomOwner('dharen', 'Dharen', 'Context structure', Icons.account_tree_rounded),
    BloomCapability.explore: BloomOwner('vivren', 'Vivren', 'Discernment', Icons.visibility_rounded),
    BloomCapability.plan: BloomOwner('manis', 'Manis', 'Deliberation', Icons.balance_rounded),
    BloomCapability.insights: BloomOwner('bodhex', 'Bodhex', 'Insight', Icons.lightbulb_outline_rounded),
    BloomCapability.explain: BloomOwner('pramon', 'Pramon', 'Proof', Icons.fact_check_rounded),
  };

  @override State<Bloom> createState() => _BloomState();
}

class _BloomState extends State<Bloom> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);
  BloomCapability? expanded;
  @override void dispose() { _pulse.dispose(); super.dispose(); }
  void _select(BloomCapability capability) {
    setState(() => expanded = expanded == capability ? null : capability);
    widget.onSelected(capability);
  }
  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final availableWidth = math.min(constraints.maxWidth, 820.0);
      final compact = availableWidth < 600;
      final ratio = compact ? .98 : .82;
      final heightLimitedSize = constraints.hasBoundedHeight ? constraints.maxHeight / ratio : double.infinity;
      final size = math.max(240.0, math.min(availableWidth, heightLimitedSize));
      final height = size * ratio;
      return SizedBox(width: size, height: height, child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
        AnimatedBuilder(animation: _pulse, builder: (context, child) => CustomPaint(size: Size(size, height), painter: _BloomPainter(selected: widget.selected ?? expanded, pulse: _pulse.value, accentMap: Bloom.accents))),
        _center(size, compact, t),
        ..._nodes(size, compact),
        if (expanded != null) _suboptions(size, compact, expanded!),
      ]));
    });
  }

  Widget _center(double size, bool compact, CriterivoxTheme t) => AnimatedBuilder(animation: _pulse, builder: (context, child) => Container(
    width: compact ? size * .34 : size * .27, height: compact ? size * .34 : size * .27,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [t.primary.withValues(alpha: .55), t.surfaceStrong, t.page]), border: Border.all(color: t.primary, width: 2), boxShadow: [BoxShadow(color: t.primary.withValues(alpha: .26), blurRadius: 34 + _pulse.value * 14, spreadRadius: 5 + _pulse.value * 3)]),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const _BloomMark(size: 38), const SizedBox(height: 8), Text('Criterivox', style: TextStyle(fontSize: 21, fontWeight: FontWeight.w600, color: t.text)), const SizedBox(height: 5), Text(expanded == null ? 'What would you like\nto do today?' : '${Bloom.labels[expanded!]}\n${Bloom.owners[expanded!]!.name} leads this path', textAlign: TextAlign.center, style: TextStyle(color: t.text, fontSize: 11.5, height: 1.35))])
  ));

  List<Widget> _nodes(double size, bool compact) {
    final radius = compact ? size * .34 : size * .32;
    final cy = compact ? size * .49 : size * .44;
    final d = compact ? 94.0 : 138.0;
    final count = BloomCapability.values.length;
    return [for (var i = 0; i < count; i++) Positioned(
      left: size / 2 + math.cos(-math.pi / 2 + i * 2 * math.pi / count) * radius - d / 2,
      top: cy + math.sin(-math.pi / 2 + i * 2 * math.pi / count) * radius - d / 2,
      child: _Node(capability: BloomCapability.values[i], compact: compact, selected: expanded == BloomCapability.values[i], onTap: () => _select(BloomCapability.values[i]))
    )];
  }

  Widget _suboptions(double size, bool compact, BloomCapability capability) {
    final radius = compact ? size * .34 : size * .32;
    final cy = compact ? size * .49 : size * .44;
    final d = compact ? 94.0 : 138.0;
    final count = BloomCapability.values.length;
    final index = BloomCapability.values.indexOf(capability);
    final angle = -math.pi / 2 + index * 2 * math.pi / count;
    final nodeCenter = Offset(size / 2 + math.cos(angle) * radius, cy + math.sin(angle) * radius);
    final owner = Bloom.owners[capability]!;
    final workspaceAction = capability == BloomCapability.stewardship ? BloomSuboption.stewardshipHome : BloomSuboption.workspace;
    final chatAction = capability == BloomCapability.stewardship ? BloomSuboption.stewardshipChat : BloomSuboption.chat;
    final chipY = math.max(4.0, nodeCenter.dy - d / 2 - (compact ? 44.0 : 50.0));
    return Positioned(left: math.max(4.0, nodeCenter.dx - (compact ? 126.0 : 148.0)), top: chipY, child: Row(mainAxisSize: MainAxisSize.min, children: [
      _ActionChip(icon: Icons.dashboard_customize_rounded, label: 'Workspace', accent: Bloom.accents[capability]!, onTap: () => widget.onSuboption?.call(workspaceAction)),
      const SizedBox(width: 7),
      _ActionChip(icon: owner.icon, label: owner.name, accent: Bloom.accents[capability]!, onTap: () => widget.onOwnerChat?.call(capability), avatar: true),
    ]));
  }
}

class _Node extends StatelessWidget {
  final BloomCapability capability; final bool compact; final bool selected; final VoidCallback onTap;
  const _Node({required this.capability, required this.compact, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context); final accent = Bloom.accents[capability]!; final owner = Bloom.owners[capability]!;
    final reserved = capability != BloomCapability.analyze && capability != BloomCapability.stewardship;
    return Material(color: Colors.transparent, child: Semantics(button: true, label: '${Bloom.labels[capability]} capability, ${owner.name} responsible for ${owner.responsibility}${reserved ? ', reserved' : ''}', child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(compact ? 94 : 138), child: AnimatedContainer(duration: const Duration(milliseconds: 240), width: compact ? 94 : 138, height: compact ? 94 : 138, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [accent.withValues(alpha: selected ? .35 : .12), t.surfaceStrong]), border: Border.all(color: accent.withValues(alpha: selected ? 1 : .58), width: selected ? 2.4 : 1.2), boxShadow: [BoxShadow(color: accent.withValues(alpha: selected ? .35 : .10), blurRadius: selected ? 30 : 18, spreadRadius: selected ? 4 : 1)]), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Bloom.icons[capability], color: accent, size: compact ? 23 : 28), const SizedBox(height: 5), Text(Bloom.labels[capability]!, textAlign: TextAlign.center, style: TextStyle(color: t.text, fontSize: compact ? 11.5 : 14, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Row(mainAxisSize: MainAxisSize.min, children: [Icon(owner.icon, color: accent, size: 11), const SizedBox(width: 4), Text(owner.name, style: TextStyle(color: t.mutedText, fontSize: 8.5, fontWeight: FontWeight.w600))]), if (!compact) ...[const SizedBox(height: 3), SizedBox(width: 105, child: Text(Bloom.subtitles[capability]!, textAlign: TextAlign.center, style: TextStyle(color: t.mutedText, fontSize: 8.5, height: 1.2))])]))))));
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon; final String label; final Color accent; final VoidCallback onTap; final bool avatar;
  const _ActionChip({required this.icon, required this.label, required this.accent, required this.onTap, this.avatar = false});
  @override Widget build(BuildContext context) {
    final t = CriterivoxTheme.of(context);
    return Material(color: Colors.transparent, child: Tooltip(message: label, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(20), child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: t.surfaceStrong.withValues(alpha: .96), borderRadius: BorderRadius.circular(20), border: Border.all(color: accent.withValues(alpha: .72)), boxShadow: [BoxShadow(color: accent.withValues(alpha: .15), blurRadius: 14)]), child: Row(mainAxisSize: MainAxisSize.min, children: [Container(width: 25, height: 25, decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: .12)), child: Icon(icon, color: accent, size: avatar ? 15 : 16)), const SizedBox(width: 5), Text(label, style: TextStyle(color: t.text, fontSize: 9.5, fontWeight: FontWeight.w700))])))));
  }
}

class _BloomMark extends StatelessWidget { final double size; const _BloomMark({required this.size}); @override Widget build(BuildContext context) => SizedBox(width: size, height: size, child: Stack(alignment: Alignment.center, children: [for (var i = 0; i < 8; i++) Transform.rotate(angle: i * math.pi / 4, child: Container(width: size * .22, height: size * .48, decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: const LinearGradient(colors: [Color(0xFF9A7BFF), Color(0xFF6654E8)])))), Container(width: size * .24, height: size * .24, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF7D68F7))) ])); }

class _BloomPainter extends CustomPainter {
  final BloomCapability? selected; final double pulse; final Map<BloomCapability, Color> accentMap;
  _BloomPainter({required this.selected, required this.pulse, required this.accentMap});
  @override void paint(Canvas canvas, Size size) { final center = Offset(size.width / 2, size.height * .44); final radius = size.width * .32; canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1..color = const Color(0x263A4D92)); final count = BloomCapability.values.length; for (var i = 0; i < count; i++) { final cap = BloomCapability.values[i]; final angle = -math.pi / 2 + i * 2 * math.pi / count; final end = center + Offset(math.cos(angle) * radius, math.sin(angle) * radius); final accent = accentMap[cap]!; canvas.drawLine(center, end, Paint()..style = PaintingStyle.stroke..strokeWidth = selected == cap ? 2.2 : 1..color = accent.withValues(alpha: selected == cap ? .88 : .30)); canvas.drawCircle(end, selected == cap ? 4 + pulse * 2 : 3.2, Paint()..color = accent); } }
  @override bool shouldRepaint(covariant _BloomPainter old) => old.selected != selected || old.pulse != pulse;
}
