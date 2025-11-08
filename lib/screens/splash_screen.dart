import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/auth/login_screen.dart';
import 'package:spotseeker_app/screens/onboarding_screen.dart';
import 'package:spotseeker_app/screens/status/request_pending_screen.dart';
import 'package:spotseeker_app/screens/status/request_declined_screen.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final SecureStorage _storage = SecureStorage();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    // Check if there's a stored email from partner registration
    final email = await _storage.read(ApiConstants.userEmailKey);

    if (email != null && email.isNotEmpty) {
      print('📧 Found stored email: $email');
      print('🔍 Checking partner status...');

      try {
        // Check partner registration status
        final statusResponse =
            await _authService.checkPartnerBecomeStatus(email);

        if (!mounted) return;

        if (statusResponse.isApproved) {
          // Status is APPROVED - go to approved screen
          print('✅ Status APPROVED → Navigating to Request Approved Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
          return;
        } else if (statusResponse.isPending) {
          // Status is PENDING_APPROVAL - go to pending screen
          print(
              '⏳ Status PENDING_APPROVAL → Navigating to Request Pending Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const RequestPendingScreen()),
          );
          return;
        } else if (statusResponse.isRejected) {
          // Status is REJECTED - go to declined screen
          print('❌ Status REJECTED → Navigating to Request Declined Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
                builder: (context) => const RequestDeclinedScreen()),
          );
          return;
        } else {
          // Other status - go to onboarding
          print(
              '⚠️ Unknown status (${statusResponse.status}) → Navigating to Onboarding');
        }
      } catch (e) {
        // Error checking status - go to onboarding
        print('❌ Error checking status: $e → Navigating to Onboarding');
      }
    } else {
      print('📭 No email found in storage → Navigating to Onboarding');
    }

    // Default: navigate to onboarding screen
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OnboardingScreen()),
      );
    }
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
            width: 100, // match onboarding screen's _overlayLogoSize
            child: Image.asset('assets/spotseeker_logo.png'),
          ),
        ),
      ),
    );
  }
}
