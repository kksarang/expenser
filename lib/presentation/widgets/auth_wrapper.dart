import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// actually MainScreen is used.
import '../screens/login_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/main_screen.dart';
import '../screens/splash_screen.dart';
import '../providers/user_provider.dart';
import '../../core/services/remote_config_service.dart';
import 'update_dialog.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool? _isFirstTime;

  @override
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
    _checkUpdate();
  }

  Future<void> _checkUpdate() async {
    final remoteConfig = RemoteConfigService();
    
    // Check for Force Update
    if (await remoteConfig.isUpdateRequired()) {
      _showUpdateDialog(force: true, version: remoteConfig.latestVersion);
      return;
    }
    
    // Check for Flexible Update
    if (await remoteConfig.isUpdateAvailable()) {
      _showUpdateDialog(force: false, version: remoteConfig.latestVersion);
    }
  }

  void _showUpdateDialog({required bool force, required String version}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: !force,
        builder: (context) => UpdateDialog(
          isForceUpdate: force,
          latestVersion: version,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    if (_isFirstTime == null) {
      return const SplashScreen();
    }

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        }

        if (userProvider.isGuest) {
          return const MainScreen();
        }

        if (_isFirstTime == true) {
          return const OnboardingScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
