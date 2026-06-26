import 'package:flutter/material.dart';

import '../../core/services/progress_service.dart';
import '../career/browse_tracks_screen.dart';
import '../path_view/path_view_screen.dart';
import '../phase0/phase0_home_screen.dart';
import '../home/home_screen.dart';
import '../comp_finder/comp_finder_screen.dart';
import '../ada2k/ada2k_screen.dart';
import '../seven_sabak/seven_sabak_hub_screen.dart';
import '../../l10n/masar_text.dart';

class MainNavigationShell extends StatefulWidget {
  final int initialTab;

  const MainNavigationShell({super.key, this.initialTab = 0});

  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainNavigationShellState>();
    if (state != null) {
      state.setTab(index);
    }
  }

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  late int _currentIndex;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  late final List<Widget> _pages;
  final GlobalKey<_MasarkRouterState> _masarkKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;

    _pages = [
      _TabNavigator(
        navigatorKey: _navigatorKeys[0],
        rootPage: const HomeScreen(),
      ),
      _TabNavigator(
        navigatorKey: _navigatorKeys[1],
        rootPage: _MasarkRouter(key: _masarkKey),
      ),
      _TabNavigator(
        navigatorKey: _navigatorKeys[2],
        rootPage: const CompFinderScreen(),
      ),
      _TabNavigator(
        navigatorKey: _navigatorKeys[3],
        rootPage: const Ada2kScreen(),
      ),
      _TabNavigator(
        navigatorKey: _navigatorKeys[4],
        rootPage: const SevenSabakHubScreen(),
      ),
    ];
  }

  void setTab(int index) {
    if (_currentIndex == index) {
      // Pop to first route if tapping the same tab
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      if (index == 1) {
        _masarkKey.currentState?.reload();
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
      if (index == 1) {
        _masarkKey.currentState?.reload();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = MasarText.t;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final navigator = _navigatorKeys[_currentIndex].currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        } else {
          if (_currentIndex != 0) {
            setTab(0);
          } else {
            // Exit app
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: setTab,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: theme.colorScheme.primary,
          unselectedItemColor: theme.unselectedWidgetColor,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: t(context, 'Home', 'الرئيسية'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.explore_outlined),
              activeIcon: const Icon(Icons.explore),
              label: t(context, 'Masark', 'مسارك'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.emoji_events_outlined),
              activeIcon: const Icon(Icons.emoji_events),
              label: t(context, 'Comp-Finder', 'المسابقات'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.insights_outlined),
              activeIcon: const Icon(Icons.insights),
              label: t(context, 'Ada2k', 'أداؤك'),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline),
              activeIcon: const Icon(Icons.person),
              label: '7sabak',
            ),
          ],
          selectedLabelStyle: const TextStyle(fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}

class _TabNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Widget rootPage;

  const _TabNavigator({required this.navigatorKey, required this.rootPage});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => rootPage);
      },
    );
  }
}

class _MasarkRouter extends StatefulWidget {
  const _MasarkRouter({super.key});

  @override
  State<_MasarkRouter> createState() => _MasarkRouterState();
}

class _MasarkRouterState extends State<_MasarkRouter> {
  TrackIdentifier? _track;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrack();
  }

  Future<void> _loadTrack() async {
    final track = await ProgressService().getSelectedTrack();
    if (mounted) {
      setState(() {
        _track = track;
        _isLoading = false;
      });
    }
  }

  void reload() {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    _loadTrack();
  }

  Future<void> _changeCareer() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const Phase0HomeScreen()));

    reload();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_track != null) {
      return PathViewScreen(
        college: _track!.college,
        specialization: _track!.specialization,
        onChangeCareer: _changeCareer,
      );
    }

    return BrowseTracksScreen(onTrackSelected: reload);
  }
}
