import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/auth/become_partner_screen.dart';
import 'package:spotseeker_app/screens/partner_form/partner_form_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/services/auth_service.dart';
import 'package:spotseeker_app/screens/events/events_board_screen.dart';
import 'package:spotseeker_app/services/partner_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  final _authService = AuthService();
  final _partnerService = PartnerService();
  bool _isLoggingIn = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    if (!_isFormValid() || _isLoggingIn) return;

    setState(() {
      _isLoggingIn = true;
      _errorMessage = null;
    });

    try {
      await _authService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // After successful login, query application status to decide destination
        try {
          final status = await _partnerService.getApplicationStatus();
          final step = status.partnerAgreement?.onboardingStep?.toLowerCase();
          final bool isComplete = step == 'complete';

          if (isComplete) {
            print('✅ Onboarding complete → Navigating to Events');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const EventsBoardScreen(),
              ),
              (route) => false,
            );
          } else {
            print('🔹 Onboarding in-progress ($step) → Partner Form');
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) => const PartnerFormScreen(),
              ),
              (route) => false,
            );
          }
        } catch (_) {
          // Fallback: if status fetch fails, go to Partner Form
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const PartnerFormScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        String errorMessage;

        // Extract meaningful error message
        if (e.toString().contains('ApiException:')) {
          errorMessage = e.toString().replaceAll('ApiException: ', '');
        } else if (e.toString().contains('Exception:')) {
          errorMessage = e.toString().replaceAll('Exception: ', '');
        } else {
          errorMessage = e.toString();
        }

        // Check for specific login scenarios
        if (errorMessage.contains('BOTH_FAILED')) {
          // Both APIs failed - navigate to Become Partner screen
          print('❌ Both APIs failed → Navigating to Become Partner Screen');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const BecomePartnerScreen(),
            ),
          );
          return;
        } else if (errorMessage.contains('MOBILE_ONLY_SUCCESS')) {
          // Mobile succeeded but legacy failed - stay on login screen
          print('⚠️ Mobile-only success → Staying on login screen');
          setState(() {
            _errorMessage =
                'Legacy API authentication failed. Please contact support.';
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Legacy API authentication failed. Please contact support.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
          return;
        }

        // For any other error, show the message and stay on login screen
        setState(() {
          _errorMessage = errorMessage;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoggingIn = false;
        });
      }
    }
  }

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
                      controller: _emailController,
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
                      controller: _passwordController,
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
                        disabledBackgroundColor:
                            primaryColor.withValues(alpha: 0.5),
                      ),
                      onPressed: (_isFormValid() && !_isLoggingIn)
                          ? _handleLogin
                          : null,
                      child: _isLoggingIn
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: textColor,
                              ),
                            )
                          : const Text(
                              'Access Copilot',
                              style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
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
                                  builder: (context) =>
                                      const BecomePartnerScreen()),
                            );
                          },
                          child: const Text(
                            "Apply",
                            style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold),
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
