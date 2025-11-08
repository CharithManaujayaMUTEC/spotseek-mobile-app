import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/auth/verify_mobile_screen.dart';
import 'package:spotseeker_app/screens/auth/login_screen.dart';
import 'package:spotseeker_app/screens/status/request_approved_screen.dart';
import 'package:spotseeker_app/screens/status/request_pending_screen.dart';
import 'package:spotseeker_app/screens/status/request_declined_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/services/auth_service.dart';
import 'package:spotseeker_app/core/api/api_exception.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';

enum EmailValidationState { initial, loading, valid, invalid }

class BecomePartnerScreen extends StatefulWidget {
  const BecomePartnerScreen({super.key});

  @override
  State<BecomePartnerScreen> createState() => _BecomePartnerScreenState();
}

class _BecomePartnerScreenState extends State<BecomePartnerScreen> {
  final _emailController = TextEditingController();
  var _validationState = EmailValidationState.initial;
  Timer? _debounce;
  double _contentOpacity = 0.0;
  final _authService = AuthService();
  final _secureStorage = SecureStorage();
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _contentOpacity = 1.0);
      });
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onEmailChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    if (_emailController.text.isEmpty) {
      setState(() => _validationState = EmailValidationState.initial);
      return;
    }
    setState(() => _validationState = EmailValidationState.loading);
    _debounce = Timer(const Duration(milliseconds: 750), () {
      final bool isValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(_emailController.text);
      if (mounted) setState(() => _validationState = isValid ? EmailValidationState.valid : EmailValidationState.invalid);
    });
  }

  Widget? _buildSuffixIcon() {
    switch (_validationState) {
      case EmailValidationState.loading:
        return Container(padding: const EdgeInsets.all(12.0), child: const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: hintTextColor)));
      case EmailValidationState.valid:
        return const Icon(Icons.check, color: Colors.green);
      case EmailValidationState.invalid:
        return const Icon(Icons.error_outline, color: Colors.orange);
      default:
        return null;
    }
  }

  Future<void> _handleProceed() async {
    if (_validationState != EmailValidationState.valid || _isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      
      // Store email in secure storage for status checking
      await _secureStorage.write(ApiConstants.userEmailKey, email);
      print('💾 Stored email in secure storage: $email');
      
      // First, check if the user already has a partner application status
      try {
        final statusResponse = await _authService.checkPartnerBecomeStatus(email);
        
        // Navigate based on status
        if (mounted) {
          if (statusResponse.isApproved) {
            // Status: APPROVED - Navigate to approved screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RequestApprovedScreen(),
              ),
            );
            return;
          } else if (statusResponse.isPending) {
            // Status: PENDING_APPROVAL - Navigate to pending screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RequestPendingScreen(),
              ),
            );
            return;
          } else if (statusResponse.isRejected) {
            // Status: REJECTED - Navigate to declined screen
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const RequestDeclinedScreen(),
              ),
            );
            return;
          }
        }
      } catch (statusError) {
        // If status check fails (e.g., 404 - no application found), continue with registration
        print('Status check returned error (likely no existing application): $statusError');
      }

      // If no existing status or status check failed, proceed with new registration
      await _authService.partnerRegistrationStep1(email);
      
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => VerifyMobileScreen(
              email: email,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Check if error indicates user already exists
        final errorMessage = e.toString();
        if (errorMessage.contains('already exists') || 
            errorMessage.contains('already registered') ||
            errorMessage.contains('User already exists')) {
          // Show dialog suggesting login
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Account Already Exists'),
              content: const Text('This email is already registered. Please login instead.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  },
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _errorMessage = e is ApiException ? e.message : e.toString();
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_errorMessage!),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
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
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Layer 1: The Panel Hero
          Hero(
            tag: 'background-panel',
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.6),
                  radius: 1.5,
                  colors: [Color(0xFF2E2250), Color(0xFF251A39), Color(0xFF0C0911)],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),

          // Layer 2: The Content
          Material(
            type: MaterialType.transparency,
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
                        // The Logo Hero is now a sibling of the Panel Hero
                        Hero(
                          tag: 'spotseeker-logo',
                          child: SizedBox(
                            width: 180,
                            height: 60,
                            child: Image.asset('assets/spotseeker_logo.png'),
                          ),
                        ),
                        const SizedBox(height: 60),
                        AnimatedOpacity(
                          opacity: _contentOpacity,
                          duration: const Duration(milliseconds: 500),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                          const Text('Request Access!', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(height: 12),
                          const Text('Bring innovation to your events partner with\nSpotseeker.lk today.', textAlign: TextAlign.center, style: TextStyle(color: hintTextColor, fontSize: 16)),
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
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide.none),
                            suffixIcon: _buildSuffixIcon(),
                          ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                            ),
                            onPressed: (_validationState == EmailValidationState.valid && !_isSubmitting)
                                ? _handleProceed
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
                                : const Text('Proceed', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          if (_errorMessage != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 14),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Spacer(flex: 3),
                    AnimatedOpacity(
                      opacity: _contentOpacity,
                      duration: const Duration(milliseconds: 500),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already a Partner? ", style: TextStyle(color: hintTextColor)),
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => const LoginScreen()),
                              );
                            },
                            child: const Text("Login", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}