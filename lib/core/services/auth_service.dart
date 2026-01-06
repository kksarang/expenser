import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Use getters to access instances safely.
  // If Firebase.initializeApp() hasn't run, FirebaseAuth.instance might throw.
  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (e) {
      return null;
    }
  }

  GoogleSignIn get _googleSignIn => GoogleSignIn();

  // Stream of auth changes
  Stream<User?> get user {
    try {
      return _auth?.authStateChanges() ?? Stream.value(null);
    } catch (e) {
      return Stream.value(null);
    }
  }

  // Current user
  User? get currentUser {
    try {
      return _auth?.currentUser;
    } catch (e) {
      return null;
    }
  }

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    final auth = _auth;
    if (auth == null) {
      throw Exception("Firebase not initialized.");
    }

    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // The user canceled the sign-in

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Once signed in, return the UserCredential
      return await auth.signInWithCredential(credential);
    } catch (e) {
      print('Error signing in with Google: $e');
      rethrow;
    }
  }

  // Delete Account
  Future<void> deleteAccount() async {
    try {
      // Best-effort sign out from Google.
      // If this fails (e.g. GMS missing/broken), we still want to delete the Firebase account.
      try {
        await _googleSignIn.signOut().timeout(const Duration(seconds: 2));
      } catch (e) {
        print(
          "AuthService: Google SignOut failed during delete (non-fatal): $e",
        );
      }

      await _auth?.currentUser?.delete();
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }

  // Sign in with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final auth = _auth;
    if (auth == null) {
      throw Exception("Firebase not initialized.");
    }
    try {
      return await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in with Email/Password: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth?.signOut();
  }
}
