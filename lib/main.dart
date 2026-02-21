import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/premium_theme.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/language_provider.dart';
import 'core/providers/farmer_provider.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/onboarding_provider.dart';
import 'core/providers/weather_provider.dart';
import 'core/providers/chat_provider.dart';
import 'features/language/screens/language_select_screen.dart';
import 'features/auth/screens/auth_signin_screen.dart';
import 'features/onboarding/screens/pmfby_onboarding_screen.dart';
import 'core/widgets/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style for premium look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Create providers
  final languageProvider = LanguageProvider();
  final farmerProvider = FarmerProvider();
  final authProvider = AuthProvider();
  final onboardingProvider = OnboardingProvider();

  // Initialize providers
  await Future.wait([
    languageProvider.loadSavedLanguage(),
    farmerProvider.initialize(),
    authProvider.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: languageProvider),
        ChangeNotifierProvider.value(value: farmerProvider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider.value(value: onboardingProvider),
        ChangeNotifierProvider(create: (_) => WeatherProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const KisanSetuApp(),
    ),
  );
}

class KisanSetuApp extends StatelessWidget {
  const KisanSetuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'KisanSetu',
          debugShowCheckedModeBanner: false,
          theme: PremiumTheme.lightTheme,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
            Locale('mr'),
          ],
          home: const AppInitializer(),
        );
      },
    );
  }
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer4<AuthProvider, FarmerProvider, OnboardingProvider, LanguageProvider>(
      builder: (context, authProvider, farmerProvider, onboardingProvider, languageProvider, _) {
        // Show loading screen while initializing
        if (authProvider.isLoading || farmerProvider.isLoading) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App logo/icon
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'KisanSetu',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2E7D32)),
                  ),
                ],
              ),
            ),
          );
        }

        // First time user - show language selection
        if (!languageProvider.hasSelectedLanguage) {
          return const LanguageSelectScreen();
        }

        // If not authenticated, show sign in screen
        if (!authProvider.isAuthenticated) {
          return const AuthSignInScreen();
        }

        // If authenticated but new user who hasn't completed onboarding
        // Show onboarding only for new users who haven't completed it
        if (authProvider.shouldShowOnboarding && !farmerProvider.isProfileComplete) {
          return const PMFBYOnboardingScreen();
        }

        // Otherwise, show main navigation (existing users or completed onboarding)
        return const MainNavigation();
      },
    );
  }
}
