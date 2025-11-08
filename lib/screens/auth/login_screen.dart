import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/auth/become_partner_screen.dart';
import 'package:spotseeker_app/screens/partner_form/partner_form_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isPasswordVisible = false;
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    // Get the actual screen height minus the status bar and navigation bar padding
    final screenHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            // 1. Wrap the entire layout in a SingleChildScrollView
            child: SingleChildScrollView(
              child: SizedBox(
                // 2. Constrain the height of the content to at least the screen height
                // This allows the Spacers and Column alignment to work correctly.
                height: screenHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 2),
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: Image.asset('assets/spotseeker_logo.png'),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      'Already a Partner',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bring innovation to your events partner with\nSpotseeker.lk today.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: hintTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Email Address',
                      hintStyle: const TextStyle(color: hintTextColor),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      obscureText: !_isPasswordVisible,
                      style: const TextStyle(color: textColor),
                      decoration: InputDecoration(
                        hintText: 'Password',
                        hintStyle: const TextStyle(color: hintTextColor),
                        filled: true,
                        fillColor: Colors.black.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: hintTextColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (bool? value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                            activeColor: primaryColor,
                            checkColor: textColor,
                            side: const BorderSide(color: hintTextColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Remember Me',
                          style: TextStyle(color: textColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Handle Login Logic
                        Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const PartnerFormScreen()),
                            );
                      },
                      child: const Text(
                        'Access Copilot',
                        style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                    ),
                    const Spacer(flex: 3),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Become a Partner? ",
                            style: TextStyle(color: hintTextColor)),
                        GestureDetector(
                          onTap: () {
                            // Navigate to the Become a Partner screen
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) => const BecomePartnerScreen()),
                            );
                          },
                          child: const Text(
                            "Apply",
                            style: TextStyle(
                                color: primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}