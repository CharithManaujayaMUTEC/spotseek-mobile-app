import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotseeker_app/screens/auth/otp_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/services/auth_service.dart';

// 1. Define an enum for the phone number validation states
enum PhoneValidationState { initial, valid, invalid }

class VerifyMobileScreen extends StatefulWidget {
  final String email;
  
  const VerifyMobileScreen({super.key, required this.email});

  @override
  State<VerifyMobileScreen> createState() => _VerifyMobileScreenState();
}

class _VerifyMobileScreenState extends State<VerifyMobileScreen> {
  final _phoneController = TextEditingController();
  var _validationState = PhoneValidationState.initial;
  final _authService = AuthService();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // 2. Add a listener to react to changes in the text field
    _phoneController.addListener(_onPhoneChanged);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_onPhoneChanged);
    _phoneController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    // The validation logic is simple: check if the length is exactly 10 digits
    // (Common for Sri Lankan mobile numbers like 0771234567)
    final text = _phoneController.text;
    PhoneValidationState newState;

    if (text.isEmpty) {
      newState = PhoneValidationState.initial;
    } else if (text.length == 10) {
      newState = PhoneValidationState.valid;
    } else {
      newState = PhoneValidationState.invalid;
    }

    // Only call setState if the validation state has actually changed
    // This prevents unnecessary rebuilds
    if (newState != _validationState) {
      setState(() {
        _validationState = newState;
      });
    }
  }

  // 3. Helper function to build the suffix icon based on the current state
  Widget? _buildSuffixIcon() {
    switch (_validationState) {
      case PhoneValidationState.valid:
        // Show a green checkmark when the number is valid
        return const Icon(Icons.check, color: Colors.green);
      case PhoneValidationState.invalid:
      case PhoneValidationState.initial:
        // No icon for initial or invalid states
        return null;
    }
  }

  // Convert 0719000492 to +94719000492
  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('0')) {
      return '+94${phone.substring(1)}';
    }
    return phone;
  }

  Future<void> _handleRequestOTP() async {
    if (_validationState != PhoneValidationState.valid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
      await _authService.partnerRegistrationStep2(
        email: widget.email,
        mobile: formattedPhone,
      );
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => OtpScreen(
              email: widget.email,
              mobile: formattedPhone,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    const Spacer(flex: 2),
                    SizedBox(
                      width: 180,
                      height: 60,
                      child: Image.asset('assets/spotseeker_logo.png'),
                    ),
                    const SizedBox(height: 60),
                    const Text(
                      'Verify Your Mobile Number',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                const Text(
                  'Enter your mobile number to receive a one-time\npassword (OTP) for verification.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: hintTextColor, fontSize: 16),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  // 4. Add input formatters to only allow digits and limit length
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  style: const TextStyle(
                      color: textColor, letterSpacing: 3, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '07X XXXXXXX',
                    hintStyle:
                        const TextStyle(color: hintTextColor, letterSpacing: 1),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                    // Use the helper to display the icon
                    suffixIcon: _buildSuffixIcon(),
                    suffixIconConstraints: const BoxConstraints(minWidth: 50),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                  ),
                  // 5. Disable the button unless the phone number is valid
                  onPressed: (_validationState == PhoneValidationState.valid && !_isSubmitting)
                      ? _handleRequestOTP
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: textColor,
                          ),
                        )
                      : const Text(
                          'Request OTP',
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