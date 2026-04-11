import 'package:flutter/material.dart';
import 'dart:async';
import 'onboarding_screen.dart';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _entranceFade;
  late Animation<Offset> _logoSlide;
  late Animation<Offset> _textSlide;

  double _dustOpacity = 1.0;
  double _dustScale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _entranceFade = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn));

    _logoSlide = Tween<Offset>(begin: const Offset(-0.5, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _textSlide = Tween<Offset>(begin: const Offset(0.0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart));

    _controller.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _dustOpacity = 0.0;
          _dustScale = 4.0; 
        });
      }
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 800),
            pageBuilder: (context, animation, secondaryAnimation) => OnboardingScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
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
      backgroundColor: const Color(0xFF0A0A0A), 
      body: Center(
        child: AnimatedScale(
          scale: _dustScale,
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutExpo,
          child: AnimatedOpacity(
            opacity: _dustOpacity,
            duration: const Duration(milliseconds: 1000),
            child: FadeTransition(
              opacity: _entranceFade,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: _logoSlide,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24, width: 1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Colors.white, size: 50),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        const Text(
                          "SHOP PRO",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w100,
                            letterSpacing: 12, 
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          width: 40,
                          color: Colors.white24,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}