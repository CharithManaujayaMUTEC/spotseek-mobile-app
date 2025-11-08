import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/events_board_screen.dart';
import 'package:spotseeker_app/screens/partner_form/pages/company_profile_page.dart';
import 'package:spotseeker_app/screens/partner_form/pages/organizer_info_page.dart';
import 'package:spotseeker_app/screens/partner_form/pages/partnership_agreement_page.dart';
import 'package:spotseeker_app/screens/partner_form/widgets/form_header.dart';
import 'package:spotseeker_app/screens/partner_form/widgets/form_stepper.dart';
import 'package:spotseeker_app/services/partner_service.dart';
import 'package:spotseeker_app/models/partner/partner_models.dart';
import 'package:path_provider/path_provider.dart';
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
  List<Widget> _formPages = [];

  // Keys to access child states without changing UI
  final GlobalKey _companyKey = GlobalKey();
  final GlobalKey _organizerKey = GlobalKey();
  final GlobalKey _agreementKey = GlobalKey();

  final PartnerService _partnerService = PartnerService();
  Set<String>? _editableFields;

  @override
  void initState() {
    super.initState();
    _rebuildPages();

    _prefetchCurrentStep();
    _loadEditableFields();
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
      // Submit agreement
      try {
        final state = _agreementKey.currentState as dynamic;
        final bool hasAgreed = state.getHasAgreed() as bool;
        final Uint8List? signature = state.getSignatureData() as Uint8List?;
        if (!hasAgreed || signature == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Please agree and provide a signature.')),
          );
          return;
        }

        setState(() => _isSwitching = true);

        final dir = await getTemporaryDirectory();
        final file = File(
            '${dir.path}/signature_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(signature);

        await _partnerService.saveAgreement(
          agreementAccepted: true,
          signatureFile: file,
        );

        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EventsBoardScreen()),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to submit agreement. Please try again.')),
        );
      } finally {
        if (mounted) setState(() => _isSwitching = false);
      }
      return;
    }

    if (_currentPage < _formPages.length - 1) {
      // Before moving forward, persist the current step
      try {
        setState(() => _isSwitching = true);
        if (_currentPage == 0) {
          final state = _companyKey.currentState as dynamic;
          final CompanyProfile? profile =
              state.buildCompanyProfileOrNull() as CompanyProfile?;
          final File? brFile = state.getBusinessRegistrationFile() as File?;
          if (profile == null) {
            throw Exception('Please complete all required fields.');
          }
          await _partnerService.saveCompanyProfile(
            profile: profile,
            businessRegistrationFile: brFile,
          );
        } else if (_currentPage == 1) {
          final state = _organizerKey.currentState as dynamic;
          final OrganizerInfo? info =
              state.buildOrganizerInfoOrNull() as OrganizerInfo?;
          final File? idFront = state.getIdFrontFile() as File?;
          final File? idBack = state.getIdBackFile() as File?;
          if (info == null || idFront == null || idBack == null) {
            throw Exception(
                'Please complete organizer info and upload ID files.');
          }
          await _partnerService.saveOrganizerInfo(
            organizerInfo: info,
            idFrontFile: idFront,
            idBackFile: idBack,
          );
        }

        await Future.delayed(const Duration(milliseconds: 300));
        final int before = _currentPage;
        await _prefetchCurrentStep();
        if (mounted) {
          // If server didn't advance us, move forward locally
          if (_currentPage == before && _currentPage < _formPages.length - 1) {
            setState(() => _currentPage++);
          }
          _scrollController.animateTo(0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(e.toString().replaceFirst('Exception: ', ''))),
          );
        }
      } finally {
        if (mounted) {
          await Future.delayed(const Duration(milliseconds: 300));
          setState(() => _isSwitching = false);
        }
      }
    }
  }

  Future<void> _onBackPressed() async {
    if (_isSwitching) return;
    if (_currentPage > 0) {
      setState(() => _isSwitching = true);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _currentPage--);
      _scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() => _isSwitching = false);
    } else {
      Navigator.of(context).pop();
    }
  }

  Future<void> _prefetchCurrentStep() async {
    try {
      final status = await _partnerService.getApplicationStatus();
      final step = status.partnerAgreement?.onboardingStep?.toLowerCase();
      int pageIndex = 0;
      if (step == 'company_profile')
        pageIndex = 0;
      else if (step == 'organizer_info')
        pageIndex = 1;
      else if (step == 'agreement' || step == 'complete') pageIndex = 2;
      if (mounted) setState(() => _currentPage = pageIndex);
    } catch (_) {
      // ignore
    }
  }

  Future<void> _loadEditableFields() async {
    try {
      final status = await _partnerService.getApplicationStatus();
      final fields = status.fieldsToResolve?.toSet();
      if (mounted) {
        setState(() {
          _editableFields = fields;
          _rebuildPages();
        });
      }
    } catch (_) {
      // ignore and allow all fields editable by default
    }
  }

  void _rebuildPages() {
    _formPages = [
      CompanyProfilePage(key: _companyKey, editableFields: _editableFields),
      OrganizerInfoPage(key: _organizerKey, editableFields: _editableFields),
      PartnershipAgreementPage(
        key: _agreementKey,
        onStateChanged: (hasAgreed, hasSignature) {
          setState(() {
            _agreementHasBeenAgreed = hasAgreed;
            _signatureHasBeenProvided = hasSignature;
          });
        },
        onResolveIssues: (fields) async {
          _onResolveIssues(fields);
        },
      ),
    ];
  }

  void _onResolveIssues(List<String>? fields) {
    final Set<String>? set = fields?.toSet();
    const companyKeys = {
      'organizationName',
      'businessEmail',
      'registeredAddress',
      'hasBusinessRegistration',
      'businessRegistrationFile',
      'instagramUrl',
      'facebookUrl',
      'bankName',
      'accountNumber',
      'accountHolderName',
      'branch',
    };
    const organizerKeys = {
      'organizerName',
      'organizerMobile',
      'organizerAddress',
      'organizerNic',
      'idType',
      'idFrontFile',
      'idBackFile',
    };

    int pageIndex = _currentPage;
    if (set != null && set.isNotEmpty) {
      if (set.any((k) => companyKeys.contains(k))) {
        pageIndex = 0;
      } else if (set.any((k) => organizerKeys.contains(k))) {
        pageIndex = 1;
      } else {
        pageIndex = 2;
      }
    } else {
      pageIndex = 0; // default to first step if unknown
    }

    setState(() {
      _editableFields = set;
      _rebuildPages();
      _currentPage = pageIndex;
    });

    // Attempt to hydrate fields with existing server data
    _partnerService.getPartnerProfile().then((profile) {
      try {
        final companyState = _companyKey.currentState as dynamic;
        companyState.applyPartnerProfile(profile);
      } catch (_) {}
    }).catchError((_) {});
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
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
    bool isFinalButtonEnabled =
        _agreementHasBeenAgreed && _signatureHasBeenProvided;
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
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isSwitching
                      ? _buildLoader()
                      : Padding(
                          key: ValueKey<int>(_currentPage),
                          padding:
                              const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 0),
                          child: _formPages[_currentPage],
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      disabledBackgroundColor:
                          primaryColor.withValues(alpha: 0.5),
                    ),
                    // 3. The button's onPressed is now fully dynamic
                    onPressed: isLastPage
                        ? (isFinalButtonEnabled ? _nextPage : null)
                        : _nextPage,
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
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
