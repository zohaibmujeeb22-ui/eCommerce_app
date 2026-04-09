import 'package:ecommerce_app/google_sign_in_server_client.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._internal()
    : _initialization = defaultTargetPlatform == TargetPlatform.android
          ? GoogleSignIn.instance.initialize(
              serverClientId: kGoogleSignInServerClientId,
            )
          : GoogleSignIn.instance.initialize();

  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final Future<void> _initialization;

  Future<UserCredential?> signInWithGoogle({
    bool skipLightweightAuthentication = false,
    VoidCallback? onBeforeFirebaseSignIn,
  }) async {
    await _initialization;
    try {
      GoogleSignInAccount? googleUser;

      if (!skipLightweightAuthentication) {
        final Future<GoogleSignInAccount?>? lightweight = _googleSignIn
            .attemptLightweightAuthentication();
        if (lightweight != null) {
          try {
            googleUser = await lightweight;
          } catch (e) {
            debugPrint("Lightweight authentication attempt failed: $e");
          }
        }
      }

      if (googleUser == null) {
        try {
          googleUser = await _googleSignIn.authenticate(
            scopeHint: const <String>['email', 'profile'],
          );
        } on GoogleSignInException catch (e) {
          debugPrint("Google authenticate: $e");
          return null;
        }
      }

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        debugPrint("Security Error: ID Token is missing from Google.");
        return null;
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      onBeforeFirebaseSignIn?.call();

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Final 2026 Auth Exception: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _initialization;
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      debugPrint("Sign Out Error: $e");
    }
  }
}
