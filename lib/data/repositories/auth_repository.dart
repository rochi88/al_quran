import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// FlutterFire (auth + firestore) officially supports Android, iOS, macOS, Web
/// and Windows. `lib/firebase_options.dart` has no Linux entry and throws for
/// it, so this app skips Firebase entirely on Linux and falls back to
/// device-local-only bookmarks (see BookmarkRepository).
bool get isFirebaseSupportedOnThisPlatform {
  if (kIsWeb) return true;
  return switch (defaultTargetPlatform) {
    TargetPlatform.android ||
    TargetPlatform.iOS ||
    TargetPlatform.macOS ||
    TargetPlatform.windows =>
      true,
    _ => false,
  };
}

/// Wraps Firebase Auth with automatic anonymous sign-in and optional linking
/// to a Google account (so bookmarks survive reinstalls / follow the user
/// across devices). All methods are no-ops when Firebase isn't supported on
/// the current platform.
class AuthRepository {
  bool _googleSignInInitialized = false;

  Stream<User?> get authStateChanges {
    if (!isFirebaseSupportedOnThisPlatform) return const Stream.empty();
    return FirebaseAuth.instance.authStateChanges();
  }

  User? get currentUser =>
      isFirebaseSupportedOnThisPlatform ? FirebaseAuth.instance.currentUser : null;

  bool get isLinkedToGoogle =>
      currentUser?.providerData.any((p) => p.providerId == 'google.com') ??
      false;

  /// Called once at startup: signs in anonymously if no session exists yet,
  /// so every install has a stable uid to key Firestore bookmarks under.
  Future<void> ensureSignedIn() async {
    if (!isFirebaseSupportedOnThisPlatform) return;
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize();
    _googleSignInInitialized = true;
  }

  /// Links the current (anonymous) session to a Google account. Returns
  /// silently if the user cancels the picker.
  Future<void> linkWithGoogle() async {
    if (!isFirebaseSupportedOnThisPlatform) return;
    await _ensureGoogleSignInInitialized();

    final GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return;
      rethrow;
    }

    final idToken = account.authentication.idToken;
    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.isAnonymous) {
      await user.linkWithCredential(credential);
    } else {
      await FirebaseAuth.instance.signInWithCredential(credential);
    }
  }

  Future<void> signOut() async {
    if (!isFirebaseSupportedOnThisPlatform) return;
    if (_googleSignInInitialized) {
      await GoogleSignIn.instance.signOut();
    }
    await FirebaseAuth.instance.signOut();
    await ensureSignedIn();
  }
}
