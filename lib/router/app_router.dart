import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';

class AppRouter {
  final AuthProvider authProvider;

  AppRouter({required this.authProvider});

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: authProvider,
    redirect: (context, state) {
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoading = authProvider.status == AuthStatus.initial ||
          authProvider.status == AuthStatus.loading;
      final isOnLogin = state.matchedLocation == '/login';

      if (isLoading) {
        return null;
      }

      if (!isAuthenticated && !isOnLogin) {
        return '/login';
      }

      if (isAuthenticated && isOnLogin) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
