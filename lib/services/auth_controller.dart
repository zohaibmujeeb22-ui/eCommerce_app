import 'package:flutter/material.dart';

/// Root auth UI state (e.g. Google sign-up must complete profile before [MainScreen]).
class AuthController extends ChangeNotifier {
  bool _needsGoogleProfileSetup = false;

  bool get needsGoogleProfileSetup => _needsGoogleProfileSetup;

  void markNeedsGoogleProfileSetup() {
    if (_needsGoogleProfileSetup) return;
    _needsGoogleProfileSetup = true;
    notifyListeners();
  }

  void clearNeedsGoogleProfileSetup() {
    if (!_needsGoogleProfileSetup) return;
    _needsGoogleProfileSetup = false;
    notifyListeners();
  }
}
