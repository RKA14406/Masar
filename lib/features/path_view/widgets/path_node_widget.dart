import 'package:flutter/material.dart';

import '../../../data/models/subject_model.dart';
import '../path_view_controller.dart';

class PathNodeWidget extends StatelessWidget {
  static const double nodeWidth = 160.0;
  static const double nodeHeight = 100.0;

  final Subject subject;
  final NodeVisualState state;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const PathNodeWidget({
    super.key,
    required this.subject,
    required this.state,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLocked = state == NodeVisualState.locked;
    final palette = _paletteFor(isDark, theme);
    final displayName = subject.localizedName(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Opacity(
        opacity: isLocked ? 0.42 : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: nodeWidth,
          height: nodeHeight,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: palette.gradient,
            border: Border.all(
              color: isSelected
                  ? palette.border
                  : palette.border.withOpacity(0.5),
              width: isSelected ? 2.2 : 1.2,
            ),
            boxShadow: [
              if (isSelected || state == NodeVisualState.completed)
                BoxShadow(
                  color: palette.glow,
                  blurRadius: isSelected ? 28 : 16,
                  spreadRadius: isSelected ? 1.0 : 0,
                ),
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.28)
                    : Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Phase pill
              PositionedDirectional(
                start: 0,
                top: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: palette.pill,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'P${subject.phase}',
                    style: TextStyle(
                      color: palette.pillText,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // State icon
              PositionedDirectional(
                end: 0,
                top: 0,
                child: Icon(
                  isLocked
                      ? Icons.lock_outline_rounded
                      : state == NodeVisualState.completed
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_outline_rounded,
                  size: 16,
                  color: state == NodeVisualState.completed
                      ? const Color(0xFF5E4300)
                      : palette.codeText,
                ),
              ),
              // Text content
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    subject.code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: palette.codeText,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Expanded(
                    child: Text(
                      displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: palette.titleText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  _NodePalette _paletteFor(bool isDark, ThemeData theme) {
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
                ? const [
                    Color(0xFF173450),
                    Color(0xFF114A79),
                    Color(0xFF0D6EAF),
                  ]
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
                ? const [Color(0xFF21262E), Color(0xFF181D25)]
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
