import 'package:ecommerce_app/Screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class FlashScreen extends StatefulWidget {
  const FlashScreen({super.key});

  @override
  State<FlashScreen> createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen>
    with TickerProviderStateMixin {
  double _logoOffset = -200;
  double _textOffset = 200;
  double _opacity = 1.0;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();

    Timer(Duration(milliseconds: 500), () {
      setState(() {
        _logoOffset = 0;
        _textOffset = 0;
      });
    });

    Timer(Duration(seconds: 3), () {
      setState(() {
        _opacity = 0.0;
        _scale = 1.5;
      });
    });

    Timer(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedScale(
          scale: _scale,
          duration: Duration(milliseconds: 800),
          child: AnimatedOpacity(
            opacity: _opacity,
            duration: Duration(milliseconds: 800),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.elasticOut,
                  transform: Matrix4.translationValues(_logoOffset, 0, 0),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 100,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 20),
                AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeOutCubic,
                  transform: Matrix4.translationValues(0, _textOffset, 0),
                  child: Text(
                    "SHOP PRO",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
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
