import 'package:flutter/material.dart';

/// A small bar chart of counts, one bar per day, oldest first.
class ActivityBars extends StatelessWidget {
  const ActivityBars({required this.counts, this.height = 40, super.key});

  final List<int> counts;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final total = counts.fold(0, (sum, c) => sum + c);
    return Semantics(
      label: '$total added over ${counts.length} days',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _BarsPainter(
            counts: counts,
            color: theme.colorScheme.primary,
            empty: theme.colorScheme.outlineVariant,
          ),
        ),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.counts,
    required this.color,
    required this.empty,
  });

  final List<int> counts;
  final Color color;
  final Color empty;

  @override
  void paint(Canvas canvas, Size size) {
    if (counts.isEmpty) return;
    final highest = counts.reduce((a, b) => a > b ? a : b);
    final slot = size.width / counts.length;
    final width = (slot * 0.7).clamp(1.0, 12.0);
    final bar = Paint()..color = color;
    final baseline = Paint()..color = empty;
    for (var i = 0; i < counts.length; i++) {
      final left = i * slot + (slot - width) / 2;
      final count = counts[i];
      if (count == 0) {
        canvas.drawRect(
          Rect.fromLTWH(left, size.height - 1, width, 1),
          baseline,
        );
        continue;
      }
      // Every day with rows shows at least a sliver.
      final barHeight = (count / highest * size.height).clamp(2.0, size.height);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(left, size.height - barHeight, width, barHeight),
          topLeft: const Radius.circular(1.5),
          topRight: const Radius.circular(1.5),
        ),
        bar,
      );
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.color != color || old.empty != empty || !_same(old.counts, counts);

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
