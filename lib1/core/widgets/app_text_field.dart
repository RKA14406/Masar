import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Function(String)? onSubmitted;

  const AppTextField({
    super.key,
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onSubmitted: onSubmitted,

      // 🔥 Correct RTL/LTR alignment
      textAlign: isRTL ? TextAlign.right : TextAlign.left,

      style: theme.textTheme.bodyMedium,

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.hintColor.withOpacity(0.7),
        ),

        // 🔥 Keep simple — Flutter handles RTL mirroring
        suffixIcon: suffixIcon,

        // 🔥 Clean spacing
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),

        // 🔥 Consistent UI
        filled: true,
        fillColor: theme.cardColor.withOpacity(0.6),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.6),
            width: 1.2,
          ),
        ),
      ),
    );
  }
}