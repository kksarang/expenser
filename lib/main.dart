import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Added
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/transaction_provider.dart';
import 'presentation/providers/category_provider.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/theme_provider.dart';
// import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';

import 'package:firebase_core/firebase_core.dart'; // Added
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'presentation/widgets/auth_wrapper.dart'; // Added import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Explicitly enable persistence (default on mobile, but good for clarity)
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );
  } catch (e) {
    print("Firebase init failed: $e. Make sure to run 'flutterfire configure'");
  }
  runApp(const MyApp());
}

// Global key for SnackBars
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          final isDark = themeProvider.isDarkMode;

          // Fix for "White space" / System Bar issues
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
              statusBarBrightness: isDark
                  ? Brightness.dark
                  : Brightness.light, // For iOS
              systemNavigationBarColor: isDark ? AppColors.dark : Colors.white,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
            ),
          );

          return MaterialApp(
            title: 'Expense Tracker',
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            // Force Indian English Locale
            locale: const Locale('en', 'IN'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'IN'), // Indian English
              Locale('en', 'US'),
            ],
            home: const AuthWrapper(), // Changed from SplashScreen
            routes: {
              '/home': (context) => const MainScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/login': (context) => const LoginScreen(),
            },
          );
        },
      ),
    );
  }
}
