import 'package:flutter/material.dart';

import '../../../data/models/subject_model.dart';
import '../path_view_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SKILL TREE SECTION — StatefulWidget to cache row computation
// ─────────────────────────────────────────────────────────────────────────────
class SkillTreeSection extends StatefulWidget {
  final List<Subject> subjects;
  final Subject? selectedSubject;
  final NodeVisualState Function(Subject) getNodeState;
  final Future<void> Function(Subject) onNodeTap;
  final Future<void> Function(Subject) onNodeLongPress;

  const SkillTreeSection({
    super.key,
    required this.subjects,
    required this.selectedSubject,
    required this.getNodeState,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  @override
  State<SkillTreeSection> createState() => _SkillTreeSectionState();
}

class _SkillTreeSectionState extends State<SkillTreeSection> {
  late List<List<Subject>> _rows;
  late double _contentWidth;

  @override
  void initState() {
    super.initState();
    _rows = _buildRows(widget.subjects);
    _contentWidth = _computeTreeWidth(_rows);
  }

  @override
  void didUpdateWidget(SkillTreeSection old) {
    super.didUpdateWidget(old);
    if (old.subjects != widget.subjects) {
      _rows = _buildRows(widget.subjects);
      _contentWidth = _computeTreeWidth(_rows);
    }
  }

  List<List<Subject>> _buildRows(List<Subject> items) {
    const pattern = [1, 2, 3, 2, 1];
    final rows = <List<Subject>>[];
    var index = 0;
    var patternIndex = 0;
    while (index < items.length) {
      final rowSize = pattern[patternIndex % pattern.length];
      final end = (index + rowSize).clamp(0, items.length);
      rows.add(items.sublist(index, end));
      index = end;
      patternIndex++;
    }
    return rows;
  }

  double _computeTreeWidth(List<List<Subject>> rows) {
    const horizontalPadding = 12.0;
    var widest = 0.0;
    for (final row in rows) {
      final itemWidth = row.length == 1 ? 240.0 : 168.0;
      final width = (row.length * itemWidth) + ((row.length - 1) * 14.0);
      if (width > widest) widest = width;
    }
    return widest + (horizontalPadding * 2);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 18),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: _contentWidth,
          child: Column(
            children: [
              for (var rowIndex = 0; rowIndex < _rows.length; rowIndex++) ...[
                _TreeRow(
                  rowSubjects: _rows[rowIndex],
                  treeWidth: _contentWidth,
                  selectedSubject: widget.selectedSubject,
                  getNodeState: widget.getNodeState,
                  onNodeTap: widget.onNodeTap,
                  onNodeLongPress: widget.onNodeLongPress,
                ),
                if (rowIndex != _rows.length - 1)
                  _TreeConnectorRow(
                    currentRow: _rows[rowIndex],
                    nextRow: _rows[rowIndex + 1],
                    treeWidth: _contentWidth,
                    completedFingerprint: _rows[rowIndex]
                        .map((s) => widget.getNodeState(s).index.toString())
                        .join(),
                    getNodeState: widget.getNodeState,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TREE ROW
// ─────────────────────────────────────────────────────────────────────────────
class _TreeRow extends StatelessWidget {
  final List<Subject> rowSubjects;
  final double treeWidth;
  final Subject? selectedSubject;
  final NodeVisualState Function(Subject) getNodeState;
  final Future<void> Function(Subject) onNodeTap;
  final Future<void> Function(Subject) onNodeLongPress;

  const _TreeRow({
    required this.rowSubjects,
    required this.treeWidth,
    required this.selectedSubject,
    required this.getNodeState,
    required this.onNodeTap,
    required this.onNodeLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final itemWidth = rowSubjects.length == 1 ? 240.0 : 168.0;

    return SizedBox(
      width: treeWidth,
      height: 122,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < rowSubjects.length; i++) ...[
            _TreeNodeCard(
              subject: rowSubjects[i],
              width: itemWidth,
              isSelected: selectedSubject?.code == rowSubjects[i].code,
              state: getNodeState(rowSubjects[i]),
              onTap: () => onNodeTap(rowSubjects[i]),
              onLongPress: () => onNodeLongPress(rowSubjects[i]),
            ),
            if (i != rowSubjects.length - 1) const SizedBox(width: 14),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TREE CONNECTOR ROW
// ─────────────────────────────────────────────────────────────────────────────
class _TreeConnectorRow extends StatelessWidget {
  final List<Subject> currentRow;
  final List<Subject> nextRow;
  final double treeWidth;
  final String completedFingerprint;
  final NodeVisualState Function(Subject) getNodeState;

  const _TreeConnectorRow({
    required this.currentRow,
    required this.nextRow,
    required this.treeWidth,
    required this.completedFingerprint,
    required this.getNodeState,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: treeWidth,
      height: 44,
      child: CustomPaint(
        painter: _TreeConnectorPainter(
          currentRow: currentRow,
          nextRow: nextRow,
          completedFingerprint: completedFingerprint,
          getNodeState: getNodeState,
          theme: Theme.of(context),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TREE CONNECTOR PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _TreeConnectorPainter extends CustomPainter {
  final List<Subject> currentRow;
  final List<Subject> nextRow;
  final String completedFingerprint;
  final NodeVisualState Function(Subject) getNodeState;
  final ThemeData theme;

  _TreeConnectorPainter({
    required this.currentRow,
    required this.nextRow,
    required this.completedFingerprint,
    required this.getNodeState,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final isDark = theme.brightness == Brightness.dark;

    final activePaint = Paint()
      ..color = theme.colorScheme.primary.withOpacity(0.65)
      ..strokeWidth = 2.6
      ..style = PaintingStyle.stroke;

    final lockedPaint = Paint()
      ..color = isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.05)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final currentXs = _positions(currentRow.length, size.width);
    final nextXs = _positions(nextRow.length, size.width);

    for (var pi = 0; pi < currentRow.length; pi++) {
      final parent = currentRow[pi];
      for (var ci = 0; ci < nextRow.length; ci++) {
        final child = nextRow[ci];
        if (!child.prerequisites.contains(parent.code)) continue;

        final from = Offset(currentXs[pi], 0);
        final to = Offset(nextXs[ci], size.height);
        final controlY = size.height * 0.5;

        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..cubicTo(from.dx, controlY, to.dx, controlY, to.dx, to.dy);

        final active = getNodeState(parent) != NodeVisualState.locked &&
            getNodeState(child) != NodeVisualState.locked;

        canvas.drawPath(path, active ? activePaint : lockedPaint);
      }
    }
  }

  List<double> _positions(int count, double width) {
    if (count <= 0) return const [];
    if (count == 1) return [width / 2];
    final gap = width / (count + 1);
    return List<double>.generate(count, (i) => gap * (i + 1));
  }

  @override
  bool shouldRepaint(covariant _TreeConnectorPainter old) {
    return old.completedFingerprint != completedFingerprint ||
        old.theme.brightness != theme.brightness ||
        old.currentRow.length != currentRow.length ||
        old.nextRow.length != nextRow.length;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TREE NODE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TreeNodeCard extends StatelessWidget {
  final Subject subject;
  final double width;
  final bool isSelected;
  final NodeVisualState state;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TreeNodeCard({
    required this.subject,
    required this.width,
    required this.isSelected,
    required this.state,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForState(context, state);
    final phaseLabel = subject.phase == 1 ? 'P1' : 'P2';
    final displayName = subject.localizedName(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: width,
        height: 94,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: palette.gradient,
          border: Border.all(
            color: isSelected
                ? palette.border
                : palette.border.withOpacity(0.55),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: [
            if (isSelected || state == NodeVisualState.completed)
              BoxShadow(
                color: palette.glow,
                blurRadius: isSelected ? 26 : 16,
                spreadRadius: isSelected ? 1.2 : 0,
              ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.22)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            PositionedDirectional(
              end: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: palette.pill,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  phaseLabel,
                  style: TextStyle(
                    color: palette.pillText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            if (state == NodeVisualState.unlocked)
              PositionedDirectional(
                start: 0,
                top: 0,
                child: Icon(
                  Icons.quiz_outlined,
                  size: 14,
                  color: isDark ? Colors.white70 : Colors.black45,
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.code,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: palette.codeText,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.titleText,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _NodePalette _paletteForState(BuildContext context, NodeVisualState state) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    switch (state) {
      case NodeVisualState.completed:
        return const _NodePalette(
          gradient: LinearGradient(
            colors: [Color(0xFFFFE27A), Color(0xFFFFC93C), Color(0xFFFFB300)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Color(0xFFFFF1A6),
          glow: Color(0x55FFD54F),
          titleText: Color(0xFF2D1F00),
          codeText: Color(0xFF5E4300),
          pill: Color(0xFFF8F0B0),
          pillText: Color(0xFF6B5300),
        );
      case NodeVisualState.unlocked:
        return _NodePalette(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF173450), Color(0xFF114A79), Color(0xFF0D6EAF)]
                : [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withOpacity(0.8),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: isDark
              ? const Color(0xFF61D1FF)
              : theme.colorScheme.primaryContainer,
          glow: theme.colorScheme.primary.withOpacity(0.3),
          titleText: Colors.white,
          codeText: const Color(0xFFCFEFFF),
          pill: const Color(0x223FD0FF),
          pillText: const Color(0xFF9FE5FF),
        );
      case NodeVisualState.locked:
        return _NodePalette(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF21262E), Color(0xFF181D25), Color(0xFF131821)]
                : [Colors.grey.shade200, Colors.grey.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: isDark ? const Color(0xFF4E5663) : Colors.black12,
          glow: Colors.transparent,
          titleText: isDark ? const Color(0xFFB3BAC5) : Colors.black38,
          codeText: isDark ? const Color(0xFF858F9D) : Colors.black26,
          pill: isDark ? const Color(0x222A313D) : Colors.black12,
          pillText: isDark ? const Color(0xFF97A0AE) : Colors.black45,
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NODE PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _NodePalette {
  final Gradient gradient;
  final Color border;
  final Color glow;
  final Color titleText;
  final Color codeText;
  final Color pill;
  final Color pillText;

  const _NodePalette({
    required this.gradient,
    required this.border,
    required this.glow,
    required this.titleText,
    required this.codeText,
    required this.pill,
    required this.pillText,
  });
}
