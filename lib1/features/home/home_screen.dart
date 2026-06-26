import 'package:flutter/material.dart';
import '../../core/services/progress_service.dart';
import '../../core/services/user_profile_service.dart';
import '../main/main_navigation_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TrackIdentifier? _track;
  String? _username;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final track = await ProgressService().getSelectedTrack();
    final profile = UserProfileService().cachedProfile;
    
    if (mounted) {
      setState(() {
        _track = track;
        _username = profile?['username'] as String?;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome to Masar${_username != null ? ', $_username' : ''}!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (_track != null) ...[
                Text(
                  'Your selected path:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _track!.specialization,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _track!.college,
                  style: theme.textTheme.bodyMedium,
                ),
              ] else ...[
                Text(
                  'No path selected yet.',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              
              Text(
                'Dashboard',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              _DashboardCard(
                title: 'Continue Masark',
                icon: Icons.explore_outlined,
                onTap: () => MainNavigationShell.switchToTab(context, 1),
              ),
              const SizedBox(height: 12),
              _DashboardCard(
                title: 'Check Ada2k',
                icon: Icons.insights_outlined,
                onTap: () => MainNavigationShell.switchToTab(context, 3),
              ),
              const SizedBox(height: 12),
              _DashboardCard(
                title: 'Open 7sabak',
                icon: Icons.person_outline,
                onTap: () => MainNavigationShell.switchToTab(context, 4),
              ),
              const SizedBox(height: 12),
              _DashboardCard(
                title: 'Find Competitions',
                icon: Icons.emoji_events_outlined,
                onTap: () => MainNavigationShell.switchToTab(context, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Icon(icon, size: 28, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
