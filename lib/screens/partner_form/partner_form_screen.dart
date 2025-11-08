import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/events_board_screen.dart';
import 'package:spotseeker_app/screens/partner_form/pages/company_profile_page.dart';
import 'package:spotseeker_app/screens/partner_form/pages/organizer_info_page.dart';
import 'package:spotseeker_app/screens/partner_form/pages/partnership_agreement_page.dart';
import 'package:spotseeker_app/screens/partner_form/widgets/form_header.dart';
import 'package:spotseeker_app/screens/partner_form/widgets/form_stepper.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class PartnerFormScreen extends StatefulWidget {
  const PartnerFormScreen({super.key});

  @override
  State<PartnerFormScreen> createState() => _PartnerFormScreenState();
}

class _PartnerFormScreenState extends State<PartnerFormScreen> {
  int _currentPage = 0;
  bool _isSwitching = false;
  final _scrollController = ScrollController();

  // 1. Add state variables to track the agreement status from the child page
  bool _agreementHasBeenAgreed = false;
  bool _signatureHasBeenProvided = false;

  // Lazily initialize the list of pages inside the state
  late final List<Widget> _formPages;

  @override
  void initState() {
    super.initState();
    _formPages = [
      const CompanyProfilePage(),
      const OrganizerInfoPage(),
      PartnershipAgreementPage(
        // Pass the callback function to the child
        onStateChanged: (hasAgreed, hasSignature) {
          setState(() {
            _agreementHasBeenAgreed = hasAgreed;
            _signatureHasBeenProvided = hasSignature;
          });
        },
      ),
    ];
  }
  
  // Method to handle the state change from the child page
  void onAgreementStateChanged(bool hasAgreed, bool hasSignature) {
    setState(() {
      _agreementHasBeenAgreed = hasAgreed;
      _signatureHasBeenProvided = hasSignature;
    });
  }

  Future<void> _nextPage() async {
    if (_isSwitching) return;
    
    // For the final step, navigate to Events Board Screen
    if (_currentPage == _formPages.length - 1) {
      // Navigate to Events Board Screen
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const EventsBoardScreen()),
      );
      return;
    }

    if (_currentPage < _formPages.length - 1) {
      setState(() => _isSwitching = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _currentPage++);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _isSwitching = false);
    }
  }

  Future<void> _onBackPressed() async {
    if (_isSwitching) return;
    if (_currentPage > 0) {
      setState(() => _isSwitching = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _currentPage--);
      _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _isSwitching = false);
    } else {
      Navigator.of(context).pop();
    }
  }

  Widget _buildLoader() {
    return Container(
      height: 300,
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(hintTextColor),
        strokeWidth: 3,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 2. Define the button's state and text based on the current page and child state
    bool isLastPage = _currentPage == _formPages.length - 1;
    bool isFinalButtonEnabled = _agreementHasBeenAgreed && _signatureHasBeenProvided;
    String buttonText = 'Next';
    
    if (isLastPage) {
      buttonText = _signatureHasBeenProvided
          ? 'Submit Contract & Access Copilot'
          : 'Submit';
    }

    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: FormHeader(onBackPressed: _onBackPressed),
                ),
                FormStepper(currentStep: _currentPage),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isSwitching
                      ? _buildLoader()
                      : Padding(
                          key: ValueKey<int>(_currentPage),
                          padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
                          child: _formPages[_currentPage],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                    ),
                    // 3. The button's onPressed is now fully dynamic
                    onPressed: isLastPage ? (isFinalButtonEnabled ? _nextPage : null) : _nextPage,
                    child: Text(
                      buttonText,
                      style: const TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center,
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