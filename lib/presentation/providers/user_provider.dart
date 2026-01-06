import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isGuest = false;
  User? _user;
  String _name = 'My Name';
  String _bio = 'Tap to add bio';

  User? get user => _user;
  bool get isGuest => _isGuest;
  bool get isAuthenticated => _user != null || _isGuest;

  String get name => _user?.displayName ?? _name;
  String get bio => _bio;
  String? get photoUrl => _user?.photoURL;

  UserProvider() {
    _init();
  }

  void _init() {
    // Listen to auth state only if stream is valid
    _authService.user.listen(
      (User? user) {
        _user = user;
        if (user != null) {
          _isGuest = false;
          _name = user.displayName ?? _name;
          _saveGuestStatus(false);
        }
        notifyListeners();
      },
      onError: (e) {
        print("UserProvider auth listen error: $e");
      },
    );

    loadUserData();
  }

  Future<UserCredential?> loginWithGoogle() async {
    return await _authService.signInWithGoogle();
  }

  Future<void> loginWithEmail(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
  }

  Future<void> loginAsGuest() async {
    _isGuest = true;
    _name = "Guest User";
    await _saveGuestStatus(true);
    notifyListeners();
  }

  Future<void> logout() async {
    print("UserProvider: logout() called. Setting isGuest = false.");
    _isGuest = false;
    _user = null; // Explicitly clear user
    await _saveGuestStatus(false);
    print("UserProvider: Signing out from Firebase...");
    await _authService.signOut();
    print("UserProvider: Sign out done. Notifying listeners.");
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    if (_isGuest) {
      await logout(); // Just logout for guest
    } else {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      try {
        await _authService.deleteAccount();
        _user = null; // Explicitly clear
        _isGuest = false; // Ensure guest is false (user wants to go to login)
        await _saveGuestStatus(false);
        notifyListeners();
      } on FirebaseAuthException catch (e) {
        if (e.code == 'requires-recent-login') {
          throw Exception('REAUTH_REQUIRED');
        }
        rethrow;
      }
    }
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      _isGuest = false;
      await _saveGuestStatus(false);
    } else {
      _isGuest = prefs.getBool('isGuest') ?? false;
    }

    if (_user == null) {
      _name =
          prefs.getString('userName') ?? (_isGuest ? "Guest User" : 'My Name');
    }
    _bio = prefs.getString('userBio') ?? 'Tap to add bio';
    notifyListeners();
  }

  Future<void> _saveGuestStatus(bool isGuest) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGuest', isGuest);
  }

  Future<void> updateName(String newName) async {
    _name = newName;
    if (_user == null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', _name);
    } else {
      // Update Firebase Profile
      await _user!.updateDisplayName(newName);
    }
    notifyListeners();
  }

  Future<void> updateBio(String newBio) async {
    _bio = newBio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userBio', _bio);
    // TODO: Save bio to Firestore if logged in
    notifyListeners();
  }

  Future<void> updateProfile(String newName, String newBio) async {
    await updateName(newName);
    await updateBio(newBio);
  }
}
