import 'package:flutter/material.dart';

class FinalPhaseGateCard extends StatelessWidget {
  final bool isUnlocked;
  final VoidCallback onTap;

  const FinalPhaseGateCard({
    super.key,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              colors: isUnlocked
                  ? (isDark
                      ? const [Color(0xFF2E1E00), Color(0xFF5C3A00), Color(0xFF8E6200)]
                      : [Colors.amber.shade200, Colors.amber.shade400])
                  : (isDark
                      ? const [Color(0xFF1B1F27), Color(0xFF181B20), Color(0xFF15181C)]
                      : [Colors.grey.shade100, Colors.grey.shade200]),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: isUnlocked
                  ? const Color(0xFFFFD54F).withOpacity(0.45)
                  : (isDark ? Colors.white.withOpacity(0.08) : Colors.black12),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.workspace_premium_rounded,
                color: isUnlocked
                    ? (isDark ? const Color(0xFFFFE082) : Colors.amber.shade800)
                    : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINAL PHASE',
                      style: TextStyle(
                        color: isUnlocked
                            ? (isDark ? Colors.white : Colors.black87)
                            : Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isUnlocked
                          ? 'Unlocked. Open the career phase.'
                          : 'Finish all Phase 1 and Phase 2 nodes first.',
                      style: TextStyle(
                        color: isUnlocked
                            ? (isDark ? Colors.white70 : Colors.black54)
                            : Colors.grey.shade400,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
