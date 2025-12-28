import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/habits_provider.dart';
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
  late final HabitsProvider _habitsProvider;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _habitsProvider = HabitsProvider();
    _appRouter = AppRouter(authProvider: _authProvider);
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    await _authProvider.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _habitsProvider),
      ],
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
