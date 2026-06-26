import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../l10n/masar_text.dart';
import 'fit_questions_screen.dart';
import 'know_what_i_want_screen.dart';

class Phase0HomeScreen extends StatelessWidget {
  const Phase0HomeScreen({super.key});

  void _openKnownMajorFlow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const KnowWhatIWantScreen(userInput: ''),
      ),
    );
  }

  void _openAiFinderFlow(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FitQuestionsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;

    return Scaffold(
      drawer: const AppDrawer(),
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.sizeOf(context).height -
                  MediaQuery.paddingOf(context).top -
                  MediaQuery.paddingOf(context).bottom -
                  32,
            ),
            child: Column(
              children: [
                const _TopControl(),
                const SizedBox(height: 14),
                const _CareerFinderIllustration(),
                const SizedBox(height: 18),
                const _TitleBlock(),
                const SizedBox(height: 26),
                _OptionCard(
                  title: t(context, 'I know my major', 'أعرف تخصصي'),
                  description: t(
                    context,
                    'I already know my major and want to start learning.',
                    'أعرف تخصصي مسبقاً وأريد أن أبدأ التعلم.',
                  ),
                  actionLabel: t(context, 'Start My Path', 'ابدأ مساري'),
                  tint: const Color(0xFFEEF4FF),
                  accent: AppColors.primary,
                  icon: Icons.school_rounded,
                  onTap: () => _openKnownMajorFlow(context),
                ),
                const SizedBox(height: 14),
                _OptionCard(
                  title: t(context, 'Help me choose', 'ساعدني في الاختيار'),
                  description: t(
                    context,
                    'Let AI analyze your interests and recommend the best major for you.',
                    'دع الذكاء الاصطناعي يحلل اهتماماتك ويقترح أنسب تخصص لك.',
                  ),
                  actionLabel: t(
                    context,
                    'Start AI CareerFinder',
                    'ابدأ CareerFinder بالذكاء الاصطناعي',
                  ),
                  tint: const Color(0xFFF3EDFF),
                  accent: const Color(0xFF8B7CFF),
                  icon: Icons.smart_toy_rounded,
                  onTap: () => _openAiFinderFlow(context),
                ),
                const SizedBox(height: 16),
                _InfoNote(
                  text: t(
                    context,
                    'You can always change your learning path later based on your progress and goals.',
                    'يمكنك دائماً تغيير مسارك التعليمي لاحقاً حسب تقدمك وأهدافك.',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopControl extends StatelessWidget {
  const _TopControl();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Builder(
        builder: (ctx) {
          return _RoundIconButton(
            icon: canPop
                ? (isRtl
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_new_rounded)
                : Icons.menu_rounded,
            onTap: canPop
                ? () => Navigator.pop(context)
                : () => Scaffold.of(ctx).openDrawer(),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Icon(icon, size: 18, color: AppColors.lightTextSecondary),
        ),
      ),
    );
  }
}

class _CareerFinderIllustration extends StatelessWidget {
  const _CareerFinderIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 145,
      width: double.infinity,
      child: CustomPaint(painter: _SignpostPainter()),
    );
  }
}

class _SignpostPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.58);
    final shadowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, size.height * 0.82),
        width: 150,
        height: 26,
      ),
      shadowPaint,
    );

    final postPaint = Paint()
      ..color = const Color(0xFF8AA0CF)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8;
    canvas.drawLine(
      Offset(center.dx, size.height * 0.36),
      Offset(center.dx, size.height * 0.78),
      postPaint,
    );

    _drawBoard(
      canvas,
      rect: Rect.fromLTWH(center.dx - 8, size.height * 0.22, 92, 30),
      color: AppColors.primary,
      pointsRight: true,
    );
    _drawBoard(
      canvas,
      rect: Rect.fromLTWH(center.dx - 88, size.height * 0.42, 92, 30),
      color: const Color(0xFFB59AFF),
      pointsRight: false,
    );

    final hillPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.42)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3;
    final hill = Path()
      ..moveTo(size.width * 0.2, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.33,
        size.height * 0.67,
        size.width * 0.46,
        size.height * 0.78,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.92,
        size.width * 0.8,
        size.height * 0.76,
      );
    canvas.drawPath(hill, hillPaint);

    final dotPaint = Paint()..color = AppColors.secondary;
    final purpleDot = Paint()..color = const Color(0xFFB59AFF);
    for (final offset in [
      Offset(size.width * 0.25, size.height * 0.28),
      Offset(size.width * 0.76, size.height * 0.34),
      Offset(size.width * 0.31, size.height * 0.61),
    ]) {
      canvas.drawCircle(
        offset,
        3,
        dotPaint..color = dotPaint.color.withValues(alpha: 0.42),
      );
    }
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.63),
      3,
      purpleDot..color = purpleDot.color.withValues(alpha: 0.5),
    );

    final sparklePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.42)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    for (final offset in [
      Offset(size.width * 0.18, size.height * 0.48),
      Offset(size.width * 0.82, size.height * 0.24),
    ]) {
      canvas.drawLine(
        offset.translate(-4, 0),
        offset.translate(4, 0),
        sparklePaint,
      );
      canvas.drawLine(
        offset.translate(0, -4),
        offset.translate(0, 4),
        sparklePaint,
      );
    }
  }

  void _drawBoard(
    Canvas canvas, {
    required Rect rect,
    required Color color,
    required bool pointsRight,
  }) {
    final radius = Radius.circular(rect.height / 2);
    final path = Path();

    if (pointsRight) {
      path
        ..moveTo(rect.left + radius.x, rect.top)
        ..lineTo(rect.right - 18, rect.top)
        ..lineTo(rect.right, rect.center.dy)
        ..lineTo(rect.right - 18, rect.bottom)
        ..lineTo(rect.left + radius.x, rect.bottom)
        ..quadraticBezierTo(
          rect.left,
          rect.bottom,
          rect.left,
          rect.bottom - radius.y,
        )
        ..lineTo(rect.left, rect.top + radius.y)
        ..quadraticBezierTo(
          rect.left,
          rect.top,
          rect.left + radius.x,
          rect.top,
        );
    } else {
      path
        ..moveTo(rect.right - radius.x, rect.top)
        ..lineTo(rect.left + 18, rect.top)
        ..lineTo(rect.left, rect.center.dy)
        ..lineTo(rect.left + 18, rect.bottom)
        ..lineTo(rect.right - radius.x, rect.bottom)
        ..quadraticBezierTo(
          rect.right,
          rect.bottom,
          rect.right,
          rect.bottom - radius.y,
        )
        ..lineTo(rect.right, rect.top + radius.y)
        ..quadraticBezierTo(
          rect.right,
          rect.top,
          rect.right - radius.x,
          rect.top,
        );
    }

    canvas.drawShadow(path, color.withValues(alpha: 0.24), 10, false);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TitleBlock extends StatelessWidget {
  const _TitleBlock();

  @override
  Widget build(BuildContext context) {
    final t = MasarText.t;

    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              fontSize: 34,
              height: 1.05,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
            children: [
              TextSpan(
                text: 'Career',
                style: TextStyle(color: AppColors.lightTextPrimary),
              ),
              TextSpan(
                text: 'Finder',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          t(context, 'How would you like to start?', 'كيف تريد أن تبدأ؟'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.lightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 6),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            t(
              context,
              'Choose the best way to discover or continue your learning path.',
              'اختر أفضل طريقة لاكتشاف مسارك التعليمي أو متابعته.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.lightTextSecondary,
              fontSize: 12,
              height: 1.35,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final Color tint;
  final Color accent;
  final IconData icon;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.tint,
    required this.accent,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Material(
      color: AppColors.lightSurface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.lightSurface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.05),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: accent, size: 31),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.lightTextPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: const TextStyle(
                        color: AppColors.lightTextSecondary,
                        fontSize: 11.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: _SmallActionButton(
                        label: actionLabel,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
                child: Icon(
                  isRtl
                      ? Icons.arrow_back_rounded
                      : Icons.arrow_forward_rounded,
                  color: accent,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final String label;
  final Color color;

  const _SmallActionButton({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            isRtl ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;

  const _InfoNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.lightTextSecondary,
                fontSize: 11.5,
                height: 1.35,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
