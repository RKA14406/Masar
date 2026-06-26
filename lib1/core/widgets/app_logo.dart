import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  /// When true → loginlogolighttheme.png (large, login screen use).
  /// When false → masar_logo_dark / masar_logo_light based on brightness.
  final bool isLogin;

  /// Explicit height. When omitted, defaults to 140 (login) or 36 (appbar).
  /// Width always scales proportionally via BoxFit.contain.
  final double? height;

  const AppLogo({
    super.key,
    this.isLogin = false,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final String asset;
    final double effectiveHeight;

    if (isLogin) {
      asset = 'assets/icons/loginlogolighttheme.png';
      effectiveHeight = height ?? 140.0;
    } else {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      asset = isDark
          ? 'assets/icons/masar_logo_dark.png'
          : 'assets/icons/masar_logo_light.png';
      effectiveHeight = height ?? 36.0;
    }

    return Image.asset(
      asset,
      height: effectiveHeight,
      fit: BoxFit.contain,
    );
  }
}
