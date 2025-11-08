import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0.0, -0.6),
            radius: 1.5,
            colors: [
              Color(0xFF2E2250),
              Color(0xFF251A39),
              Color(0xFF0C0911),
            ],
            stops: [0.0, 0.4, 1.0],
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 250,
            child: Image.asset('assets/spotseeker_logo.png'),
          ),
        ),
      ),
    );
  }

}