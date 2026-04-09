import 'package:flutter/material.dart';

/// Used so post-auth SnackBars survive route tree swaps (e.g. AuthWrapper → MainScreen).
final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
