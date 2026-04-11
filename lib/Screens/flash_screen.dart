import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _logoAnimation;
  late Animation<Offset> _textAnimation;

  double _opacity = 1.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _logoAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _textAnimation = Tween<Offset>(
      begin: const Offset(0.0, 3.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _opacity = 0.0;
          _scale = 3.0;
        });
      }
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => OnboardingScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 800),
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 900),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SlideTransition(
                  position: _logoAnimation,
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                SlideTransition(
                  position: _textAnimation,
                  child: const Text(
                    "SHOP PRO",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
