import 'package:flutter/material.dart';

import '../path_view_controller.dart';

class PathConnectionPainter extends CustomPainter {
  final List<Offset> nodeCenters;
  final double nodeHalfHeight;
  final List<NodeVisualState> nodeStates;
  // Each record is (fromIndex, toIndex) derived from prerequisite relationships.
  final List<(int, int)> edges;
  final ThemeData theme;
  final String repaintKey;

  const PathConnectionPainter({
    required this.nodeCenters,
    required this.nodeHalfHeight,
    required this.nodeStates,
    required this.edges,
    required this.theme,
    required this.repaintKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCenters.length < 2 || edges.isEmpty) return;

    final isDark = theme.brightness == Brightness.dark;

    final completedPaint = Paint()
      ..color = const Color(0xFFFFD54F).withOpacity(0.72)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final activePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final lockedPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.07)
          : Colors.black.withOpacity(0.07)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final (fromIdx, toIdx) in edges) {
      if (fromIdx >= nodeCenters.length || toIdx >= nodeCenters.length) continue;

      final fromCenter = nodeCenters[fromIdx];
      final toCenter = nodeCenters[toIdx];

      // Exit bottom-center of parent node, enter top-center of child node
      final from = Offset(fromCenter.dx, fromCenter.dy + nodeHalfHeight);
      final to = Offset(toCenter.dx, toCenter.dy - nodeHalfHeight);
      final midY = (from.dy + to.dy) / 2;

      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..cubicTo(from.dx, midY, to.dx, midY, to.dx, to.dy);

      final fromState = fromIdx < nodeStates.length
          ? nodeStates[fromIdx]
          : NodeVisualState.locked;
      final toState = toIdx < nodeStates.length
          ? nodeStates[toIdx]
          : NodeVisualState.locked;

      final Paint paint;
      if (fromState == NodeVisualState.completed &&
          toState == NodeVisualState.completed) {
        paint = completedPaint;
      } else if (fromState != NodeVisualState.locked ||
          toState != NodeVisualState.locked) {
        paint = activePaint;
      } else {
        paint = lockedPaint;
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PathConnectionPainter old) {
    return old.repaintKey != repaintKey ||
        old.theme.brightness != theme.brightness;
  }
}
