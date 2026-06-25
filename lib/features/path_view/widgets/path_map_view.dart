import 'package:flutter/material.dart';

import '../../../data/models/subject_model.dart';
import '../path_view_controller.dart';
import 'path_connection_painter.dart';
import 'path_node_widget.dart';

class PathMapView extends StatelessWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final NodeVisualState Function(Subject) getNodeState;
  final Future<void> Function(Subject) onNodeTap;
  final Future<void> Function(Subject) onNodeLongPress;

  // Center-to-center vertical distance between consecutive nodes
  static const double _verticalStep = 148.0;
  static const double _topPad = 12.0;
  static const double _bottomPad = 20.0;
  static const double _horizontalPad = 20.0;

  const PathMapView({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.getNodeState,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Text(
          'No subjects found.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
      );
    }

    final edges = _buildEdges();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final positions = _computePositions(availableWidth);
          final states = subjects.map(getNodeState).toList();
          final repaintKey = states.map((s) => s.index).join();

          final totalHeight = _topPad +
              PathNodeWidget.nodeHeight / 2 +
              (subjects.length - 1) * _verticalStep +
              PathNodeWidget.nodeHeight / 2 +
              _bottomPad;

          return SizedBox(
            width: availableWidth,
            height: totalHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Connection lines — painted behind all nodes
                Positioned.fill(
                  child: CustomPaint(
                    painter: PathConnectionPainter(
                      nodeCenters: positions,
                      nodeHalfHeight: PathNodeWidget.nodeHeight / 2,
                      nodeStates: states,
                      edges: edges,
                      theme: Theme.of(context),
                      repaintKey: repaintKey,
                    ),
                  ),
                ),
                // Nodes
                for (var i = 0; i < subjects.length; i++)
                  Positioned(
                    left: positions[i].dx - PathNodeWidget.nodeWidth / 2,
                    top: positions[i].dy - PathNodeWidget.nodeHeight / 2,
                    child: PathNodeWidget(
                      subject: subjects[i],
                      state: states[i],
                      isSelected: selectedSubject?.code == subjects[i].code,
                      onTap: () => onNodeTap(subjects[i]),
                      onLongPress: () => onNodeLongPress(subjects[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds edges from prerequisite relationships.
  /// Each edge is (parentIndex, childIndex) where parentIndex is the
  /// position of the prerequisite course and childIndex is the course
  /// that depends on it. Only includes edges where both courses are
  /// present in this phase's subject list.
  List<(int, int)> _buildEdges() {
    final codeToIndex = <String, int>{
      for (var i = 0; i < subjects.length; i++) subjects[i].code: i,
    };

    final edges = <(int, int)>[];
    for (var i = 0; i < subjects.length; i++) {
      for (final prereqCode in subjects[i].prerequisites) {
        final fromIndex = codeToIndex[prereqCode];
        if (fromIndex != null) {
          edges.add((fromIndex, i));
        }
      }
    }
    return edges;
  }

  // Alternating left / right zig-zag positions
  List<Offset> _computePositions(double width) {
    final leftCenterX = _horizontalPad + PathNodeWidget.nodeWidth / 2;
    final rightCenterX = width - _horizontalPad - PathNodeWidget.nodeWidth / 2;

    return List.generate(subjects.length, (i) {
      final y = _topPad + PathNodeWidget.nodeHeight / 2 + i * _verticalStep;
      final x = i.isEven ? leftCenterX : rightCenterX;
      return Offset(x, y);
    });
  }
}
