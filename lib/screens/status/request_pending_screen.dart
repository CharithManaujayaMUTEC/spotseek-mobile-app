import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/services/auth_service.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';
import 'package:spotseeker_app/screens/status/request_approved_screen.dart';
import 'package:spotseeker_app/screens/status/request_declined_screen.dart';

class RequestPendingScreen extends StatefulWidget {
  const RequestPendingScreen({super.key});

  @override
  State<RequestPendingScreen> createState() => _RequestPendingScreenState();
}

class _RequestPendingScreenState extends State<RequestPendingScreen> {
  Timer? _statusCheckTimer;
  final _authService = AuthService();
  final _secureStorage = SecureStorage();
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _startStatusPolling();
  }

  @override
  void dispose() {
    _statusCheckTimer?.cancel();
    super.dispose();
  }

  void _startStatusPolling() {
    // Check immediately on screen load
    _checkStatus();
    
    // Then check every 5 seconds
    _statusCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkStatus();
    });
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return; // Prevent overlapping requests
    
    try {
      setState(() => _isChecking = true);
      
      // Get user email from secure storage
      final email = await _secureStorage.read(ApiConstants.userEmailKey);
      
      if (email == null || email.isEmpty) {
        print('⚠️ No email found in storage for status check');
        return;
      }
      
      print('🔍 Checking partner become status for: $email');
      
      // Check status from API
      final statusResponse = await _authService.checkPartnerBecomeStatus(email);
      
      print('📊 Status response: ${statusResponse.status}');
      
      if (!mounted) return;
      
      // Navigate based on status
      if (statusResponse.isApproved) {
        print('✅ Status APPROVED → Navigating to Approved Screen');
        _statusCheckTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RequestApprovedScreen(),
          ),
        );
      } else if (statusResponse.isRejected) {
        print('❌ Status REJECTED → Navigating to Declined Screen');
        _statusCheckTimer?.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const RequestDeclinedScreen(),
          ),
        );
      } else {
        print('⏳ Status still PENDING');
      }
    } catch (e) {
      print('❌ Error checking status: $e');
      // Don't show error to user, just keep polling
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement logic to open WhatsApp or a support chat.
        },
        // 1. Use a color that matches WhatsApp's brand green.
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(
          Icons.chat_bubble, // A suitable built-in alternative to the WhatsApp icon.
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              // The main axis alignment is removed to allow Spacers to work.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. The main logo is now at the top.
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    height: 60,
                    child: Image.asset('assets/spotseeker_logo.png'),
                  ),
                ),
                const Spacer(flex: 2), // Provides flexible space

                // 3. The new animated pending icon is added here.
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/pending.gif',
                      height: 80, // Set an appropriate height for the GIF
                    ),
                    if (_isChecking)
                      Positioned(
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Checking...',
                                style: TextStyle(color: Colors.white, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),

                // Text content remains the same but is repositioned by the Spacers.
                const Text(
                  'Access Request Pending!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your request to access Copilot is\nunder review.\nAccess credentials will be delivered to\nyour email once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Checking status every 5 seconds...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hintTextColor,
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(flex: 3), // Provides more space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}