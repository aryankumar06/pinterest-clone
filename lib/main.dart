import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';
import 'shared/themes/app_theme.dart';
import 'shared/themes/theme_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();

  // Initialize Dio client
  DioClient.instance.init();

  runApp(
    const ProviderScope(
      child: PinterestCloneApp(),
    ),
  );
}

/// Root application widget.
class PinterestCloneApp extends ConsumerWidget {
  const PinterestCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      title: 'Pinterest Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
