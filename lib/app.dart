import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/rtl_theme.dart';
import 'core/routing/app_router.dart';
import 'core/providers/providers.dart';
import 'generated/l10n.dart';

class NeferApp extends ConsumerWidget {
  const NeferApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Nefer',
      debugShowCheckedModeBanner: false,
      
      // Routing
      routerConfig: router,
      
      // Theming
      theme: RTLTheme.getRTLTheme(AppTheme.lightTheme, locale),
      darkTheme: RTLTheme.getRTLTheme(AppTheme.darkTheme, locale),
      themeMode: themeMode,
      
      // Localization
      locale: locale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ar', 'EG'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      
      // Builder for global overlays
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// Providers for app-level state
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);

final localeProvider = StateProvider<Locale>((ref) => const Locale('en', 'US'));

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      
      final isLoggingIn = state.location == '/login' || state.location == '/register';
      
      // Redirect to login if not authenticated and not already on auth pages
      if (!isLoggedIn && !isLoggingIn) {
        return '/login';
      }
      
      // Redirect to home if logged in and on auth pages
      if (isLoggedIn && isLoggingIn) {
        return '/';
      }
      
      return null;
    },
    routes: AppRouter.routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
