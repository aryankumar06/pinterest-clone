import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/home/domain/entities/pin.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/pin_detail/presentation/screens/pin_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/board/presentation/screens/board_detail_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../features/pin_create/presentation/screens/pin_create_screen.dart';

/// Responsive shell screen that switches between BottomNavigationBar (Mobile)
/// and NavigationRail (Tablet/Desktop).
class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 768) {
          return _TabletDesktopShell(child: child);
        } else {
          return _MobileShell(child: child);
        }
      },
    );
  }
}

class _TabletDesktopShell extends StatelessWidget {
  const _TabletDesktopShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            backgroundColor: theme.scaffoldBackgroundColor,
            selectedIndex: currentIndex,
            onDestinationSelected: (index) => _onItemTapped(index, context),
            labelType: NavigationRailLabelType.none,
            selectedIconTheme: IconThemeData(
              color: theme.colorScheme.onSurface,
              size: 28,
            ),
            unselectedIconTheme: IconThemeData(
              color: theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: Text('Home'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.explore_outlined),
                selectedIcon: Icon(Icons.explore_rounded),
                label: Text('Explore'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.add_circle_outline_rounded),
                selectedIcon: Icon(Icons.add_circle_rounded),
                label: Text('Create'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.chat_bubble_outline_rounded),
                selectedIcon: Icon(Icons.chat_bubble_rounded),
                label: Text('Chat'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person_outlined),
                selectedIcon: Icon(Icons.person_rounded),
                label: Text('Profile'),
              ),
            ],
          ),
          VerticalDivider(
            thickness: 1,
            width: 1,
            color: theme.dividerColor.withValues(alpha: 0.1),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _MobileShell extends StatelessWidget {
  const _MobileShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = GoRouterState.of(context).uri.toString();

    int currentIndex = _calculateSelectedIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_filled),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              activeIcon: Icon(Icons.search, color: Colors.black),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add, size: 30),
              activeIcon: Icon(Icons.add, size: 30, color: Colors.black),
              label: 'Create',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline_rounded),
              activeIcon: Icon(Icons.chat_bubble_rounded),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Saved',
            ),
          ],
        ),
      ),
    );
  }
}

int _calculateSelectedIndex(String location) {
  if (location.startsWith('/search')) return 1;
  if (location.startsWith('/create')) return 2;
  if (location.startsWith('/chat')) return 3;
  if (location.startsWith('/profile')) return 4;
  return 0;
}

void _onItemTapped(int index, BuildContext context) {
  switch (index) {
    case 0:
      context.go('/home');
    case 1:
      context.go('/search');
    case 2:
      context.go('/create');
    case 3:
      context.go('/chat');
    case 4:
      context.go('/profile');
  }
}

// ── Navigator Keys ─────────────────────────────────────────────────────
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

final goRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: Listenable.merge([
      // Provider doesn't expose listenable directly, so we watch it above.
      // Actually, we can use ValueNotifier if we really want to monitor state changes.
    ]),
    redirect: (context, state) {
      final isSplash = state.uri.path == '/splash';
      final isLoggingIn =
          state.uri.path == '/login' ||
          state.uri.path == '/welcome' ||
          state.uri.path == '/onboarding';

      if (isSplash) return null;

      // DON'T REDIRECT WHILE INITIALIZING AUTH (Prevents hot reload/init logout)
      if (!authState.isInitialized) return null;

      if (authState.isAuthenticated) {
        if (isLoggingIn) return '/home';
      } else {
        // Not authenticated, and NOT already at a login screen
        if (!isLoggingIn && state.uri.path != '/splash') return '/welcome';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const _SplashScreen(),
      ),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ResponsiveShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const HomeScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOut,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const SearchScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOut,
                      ).animate(animation),
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.98, end: 1.0).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOut,
                          ),
                        ),
                        child: child,
                      ),
                    );
                  },
                ),
          ),
          GoRoute(
            path: '/create',
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: PinCreateScreen()),
          ),
          GoRoute(
            path: '/chat',
            pageBuilder:
                (context, state) => NoTransitionPage(
                  child: Scaffold(
                    appBar: AppBar(title: const Text('Chat')),
                    body: const Center(child: Text('Chats coming soon!')),
                  ),
                ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder:
                (context, state) => CustomTransitionPage(
                  key: state.pageKey,
                  child: const ProfileScreen(),
                  transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                  ) {
                    return FadeTransition(
                      opacity: CurveTween(
                        curve: Curves.easeInOut,
                      ).animate(animation),
                      child: child,
                    );
                  },
                ),
          ),
        ],
      ),
      GoRoute(
        path: '/board/:name',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final name = state.pathParameters['name'] ?? 'Board';
          return BoardDetailScreen(boardName: name);
        },
      ),
      GoRoute(
        path: '/profile/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/pin/:id',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) {
          final id = state.pathParameters['id']!;
          final pin = state.extra as Pin?;

          return CustomTransitionPage(
            key: state.pageKey,
            child: PinDetailScreen(pinId: id, pin: pin),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                ),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    ],
  );
});

class _SplashScreen extends ConsumerStatefulWidget {
  const _SplashScreen();

  @override
  ConsumerState<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    try {
      // Wait for initial auth check with a 5-second safety timeout
      await ref
          .read(authProvider.notifier)
          .checkAuthStatus()
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              // Force-mark as initialized so GoRouter's redirect fires and
              // moves us off the splash screen (as unauthenticated).
              ref.read(authProvider.notifier).forceInitialized();
            },
          );
    } catch (e) {
      // Force initialized even on error so we never get stuck
      ref.read(authProvider.notifier).forceInitialized();
    }

    if (!mounted) return;
    // Navigate directly as a safety fallback in case the redirect didn't fire
    final isAuth = ref.read(authProvider).isAuthenticated;
    context.go(isAuth ? '/home' : '/welcome');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE60023),
      body: Center(
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'P',
              style: GoogleFonts.notoSerif(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
