import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'router/app_router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const HabitsApp());
}

class HabitsApp extends StatefulWidget {
  const HabitsApp({super.key});

  @override
  State<HabitsApp> createState() => _HabitsAppState();
}

class _HabitsAppState extends State<HabitsApp> {
  late final AuthProvider _authProvider;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _appRouter = AppRouter(authProvider: _authProvider);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _authProvider,
      child: MaterialApp.router(
        title: 'Habits',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        routerConfig: _appRouter.router,
      ),
    );
  }
}
