import 'package:flutter/material.dart';
import '../../core/services/auth_service.dart';
import '../../core/widgets/app_logo.dart';
import '../../l10n/app_localizations.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final loc = AppLocalizations.of(context)!;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.fillFields)),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().login(email, password);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.loginFailed(e.toString()))),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Responsive logo height: 18% of screen, clamped to 100–160 px
    final logoHeight =
        (MediaQuery.of(context).size.height * 0.18).clamp(100.0, 160.0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // 🔹 Login logo — prominent, top-center
              Center(
                child: AppLogo(isLogin: true, height: logoHeight),
              ),

              const SizedBox(height: 36),

              // 🔹 Title
              Text(
                loc.welcomeBack,
                textAlign: TextAlign.start,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                loc.loginSubtitle,
                textAlign: TextAlign.start,
                style: theme.textTheme.bodyMedium,
              ),

              const SizedBox(height: 32),

              // 🔹 Email
              AppTextField(
                controller: emailController,
                hint: loc.email,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),

              const SizedBox(height: 16),

              // 🔹 Password
              AppTextField(
                controller: passwordController,
                hint: loc.password,
                obscureText: obscurePassword,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
                suffixIcon: IconButton(
                  onPressed: () {
                    setState(() => obscurePassword = !obscurePassword);
                  },
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 Login Button
              AppButton(
                text: loc.login,
                onPressed: login,
                isLoading: isLoading,
              ),

              const SizedBox(height: 20),

              // 🔹 Register
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/register'),
                  child: Text(loc.createAccount),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}