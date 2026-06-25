import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/settings_service.dart';
import '../services/user_profile_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../../features/career/browse_tracks_screen.dart';
import '../../features/phase0/phase0_home_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../l10n/app_localizations.dart';

// ─────────────────────────────────────────────────────────────────────────────
// APP DRAWER
// ─────────────────────────────────────────────────────────────────────────────

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = SettingsService();
    final isArabic = settings.locale.languageCode == 'ar';

    return Drawer(
      backgroundColor:
          isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── HEADER ───────────────────────────────────────────────
            _DrawerHeader(),

            const SizedBox(height: 4),

            // ── MAIN NAVIGATION ──────────────────────────────────────
            DrawerItem(
              icon: Icons.home_outlined,
              label: l10n.home,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Phase0HomeScreen(),
                  ),
                  (route) => false,
                );
              },
            ),
            DrawerItem(
              icon: Icons.explore_outlined,
              label: l10n.browseTracks,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const BrowseTracksScreen(),
                  ),
                );
              },
            ),

            _DrawerDivider(isDark: isDark),

            // ── QUICK SETTINGS ───────────────────────────────────────
            DrawerItem(
              icon: isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
              label: isDark ? l10n.lightMode : l10n.darkMode,
              onTap: () => settings.updateThemeMode(
                isDark ? ThemeMode.light : ThemeMode.dark,
              ),
            ),
            DrawerItem(
              icon: Icons.language_outlined,
              label: isArabic ? l10n.english : l10n.arabic,
              onTap: () => settings.updateLocale(
                isArabic ? const Locale('en') : const Locale('ar'),
              ),
            ),

            // ── FOOTER ───────────────────────────────────────────────
            const Spacer(),
            _DrawerDivider(isDark: isDark),
            DrawerItem(
              icon: Icons.logout_rounded,
              label: l10n.logout,
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.pop(context);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DRAWER HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  String _initials(String? username, String? email) {
    final src = (username != null && username.isNotEmpty && username != '—')
        ? username
        : (email ?? '');
    if (src.isEmpty) return '?';
    final parts = src.trim().split(RegExp(r'[\s@._]+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return src[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF0F1E30)
            : theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.07)
                : Colors.black.withOpacity(0.07),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Logo ────────────────────────────────────────────────────
          Center(
            child: AppLogo(height: 68),
          ),

          const SizedBox(height: 20),

          // ── User row ─────────────────────────────────────────────────
          FutureBuilder<Map<String, dynamic>?>(
            future: UserProfileService().getCurrentUserProfile(),
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final username = snapshot.data?['username'] as String? ?? '';
              final email = user?.email ?? '';
              final initials = _initials(username, email);

              return Row(
                children: [
                  // Initials avatar — taps to open profile
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(23),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primaryContainer,
                      ),
                      child: Center(
                        child: isLoading
                            ? _Skeleton(width: 20, height: 20, isDark: isDark)
                            : Text(
                                initials,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color:
                                      theme.colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Name + email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          _Skeleton(width: 88, height: 13, isDark: isDark)
                        else
                          Text(
                            username.isNotEmpty ? username : email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 3),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE DRAWER ITEM
// ─────────────────────────────────────────────────────────────────────────────

class DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final Color? iconColor;
  final Color? labelColor;

  const DrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.iconColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveIconColor = iconColor ??
        (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);
    final effectiveLabelColor = labelColor ??
        (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
      child: ListTile(
        leading: Icon(icon, color: effectiveIconColor, size: 22),
        title: Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: effectiveLabelColor,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        onTap: onTap,
        selected: isActive,
        selectedTileColor: AppColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        minLeadingWidth: 24,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _DrawerDivider extends StatelessWidget {
  final bool isDark;
  const _DrawerDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Divider(
        height: 1,
        color: isDark
            ? Colors.white.withOpacity(0.07)
            : Colors.black.withOpacity(0.08),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  final double width;
  final double height;
  final bool isDark;

  const _Skeleton({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.09)
            : Colors.black.withOpacity(0.07),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
