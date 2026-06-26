import 'package:flutter/material.dart';

import '../../core/services/progress_service.dart';
import '../career/browse_tracks_screen.dart';
import '../path_view/path_view_screen.dart';
import '../home/home_screen.dart';
import '../comp_finder/comp_finder_screen.dart';
import '../ada2k/ada2k_screen.dart';
import '../seven_sabak/seven_sabak_hub_screen.dart';

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
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Masark',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              activeIcon: Icon(Icons.emoji_events),
              label: 'Comp-Finder',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insights_outlined),
              activeIcon: Icon(Icons.insights),
              label: 'Ada2k',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: '7sabak',
            ),
          ],
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
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrowseTracksScreen(
          onTrackSelected: () {
            Navigator.of(context).pop();
            reload();
          },
        ),
      ),
    );

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
