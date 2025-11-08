import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class RequestDeclinedScreen extends StatelessWidget {
  const RequestDeclinedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.green,
        child: const Icon(Icons.support_agent, color: Colors.white),
      ),
      body: Container(
        decoration: backgroundGradient(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 180,
                height: 60,
                child: Image.asset('assets/spotseeker_logo.png'),
              ),
              const SizedBox(height: 60),
              const Text(
                'Access Request Declined!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Your request to access Copilot has been\ndeclined.\nContact Spotseeker for assistance.',
                textAlign: TextAlign.center,
                style: TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}