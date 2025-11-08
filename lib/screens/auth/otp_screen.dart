import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:spotseeker_app/screens/status/request_pending_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/services/auth_service.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  final String mobile;
  
  const OtpScreen({super.key, required this.email, required this.mobile});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();
  final _authService = AuthService();

  // State variables
  bool _isError = false;
  bool _isVerifying = false;
  bool _isResending = false;
  late Timer _timer;
  int _start = 60;

  @override
  void initState() {
    super.initState();
    startTimer();
    // When the screen loads, we want the text field to be focused
    // and the keyboard to pop up immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _pinController.dispose();
    _focusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  void startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) {
        if (_start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  Future<void> _resendOtp() async {
    if (_isResending || _start > 0) return;

    setState(() {
      _isResending = true;
      _isError = false;
    });

    try {
      // Resend OTP by calling step 2 again
      await _authService.partnerRegistrationStep2(
        email: widget.email,
        mobile: widget.mobile,
      );

      if (mounted) {
        // Clear the PIN field
        _pinController.clear();
        
        // Reset timer
        _timer.cancel();
        setState(() {
          _start = 60;
        });
        startTimer();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP has been resent successfully'),
            backgroundColor: Colors.green,
          ),
        );

        // Refocus on input
        _focusNode.requestFocus();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend OTP: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  void _verifyOtp() async {
    if (_isVerifying) return;

    setState(() {
      _isVerifying = true;
      _isError = false;
    });

    try {
      await _authService.partnerRegistrationStep3(
        email: widget.email,
        mobile: widget.mobile,
        otp: _pinController.text,
      );

      if (mounted) {
        // Navigate to Partner Form (stepper) after successful OTP verification
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const RequestPendingScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        // 1. Set error state to show red borders
        setState(() => _isError = true);

        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );

        // 2. After a short delay, clear the input and reset the error state
        Timer(const Duration(milliseconds: 800), () {
          if (mounted) {
            _pinController.clear();
            setState(() => _isError = false);
            _focusNode.requestFocus(); // Bring focus back to the first field
          }
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isVerifying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the pin themes
    final defaultPinTheme = PinTheme(
      width: 56,
      height: 60,
      textStyle: const TextStyle(fontSize: 22, color: textColor),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.transparent),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.white),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: Colors.red),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(),
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: Image.asset('assets/spotseeker_logo.png'),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      'Mobile Number Verification',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'A one-time OTP will be sent to this mobile number\nfor verification.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: hintTextColor, fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    // The pinput widget will now use the native keyboard
                    Pinput(
                      length: 6,
                      controller: _pinController,
                      focusNode: _focusNode,
                      keyboardType: TextInputType.number, // <-- This is the key change
                      defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  errorPinTheme: errorPinTheme,
                  forceErrorState: _isError,
                  onCompleted: (pin) => _verifyOtp(), // Automatically verify when 6 digits are entered
                ),
                const SizedBox(height: 30),
                Text(
                  'This code will expire in $_start secs',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: hintTextColor, fontSize: 14),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code? ", style: TextStyle(color: hintTextColor)),
                    GestureDetector(
                      onTap: (_start == 0 && !_isResending) ? _resendOtp : null,
                      child: _isResending
                          ? const SizedBox(
                              height: 14,
                              width: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            )
                          : Text(
                              "Resend",
                              style: TextStyle(
                                  color: _start == 0 ? primaryColor : hintTextColor,
                                  fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                  ),
                  onPressed: (_pinController.text.length == 6 && !_isVerifying) ? _verifyOtp : null,
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: textColor,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
                const Spacer(flex: 2),
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