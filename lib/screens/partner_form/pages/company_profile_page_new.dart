import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/services/partner_service.dart';
import 'package:spotseeker_app/models/partner/partner_models.dart';
import 'package:spotseeker_app/widgets/file_upload_box.dart';
import 'dart:io';

class CompanyProfilePage extends StatefulWidget {
  final VoidCallback? onSaveSuccess;
  
  const CompanyProfilePage({super.key, this.onSaveSuccess});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _partnerService = PartnerService();
  
  // Form controllers
  final _organizationNameController = TextEditingController();
  final _businessEmailController = TextEditingController();
  final _registeredAddressController = TextEditingController();
  final _instagramUrlController = TextEditingController();
  final _facebookUrlController = TextEditingController();
  final _bankNameController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountHolderNameController = TextEditingController();
  final _branchController = TextEditingController();
  
  bool _isDropdownExpanded = false;
  bool? _hasBusinessRegistration;
  File? _businessRegistrationFile;
  bool _isSaving = false;

  @override
  void dispose() {
    _organizationNameController.dispose();
    _businessEmailController.dispose();
    _registeredAddressController.dispose();
    _instagramUrlController.dispose();
    _facebookUrlController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountHolderNameController.dispose();
    _branchController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_hasBusinessRegistration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select business registration status'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_hasBusinessRegistration == true && _businessRegistrationFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload business registration document'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final profile = CompanyProfile(
        organizationName: _organizationNameController.text.trim(),
        businessEmail: _businessEmailController.text.trim(),
        registeredAddress: _registeredAddressController.text.trim(),
        hasBusinessRegistration: _hasBusinessRegistration!,
        instagramUrl: _instagramUrlController.text.trim().isEmpty 
            ? null 
            : _instagramUrlController.text.trim(),
        facebookUrl: _facebookUrlController.text.trim().isEmpty 
            ? null 
            : _facebookUrlController.text.trim(),
        bankName: _bankNameController.text.trim(),
        accountNumber: _accountNumberController.text.trim(),
        accountHolderName: _accountHolderNameController.text.trim(),
        branch: _branchController.text.trim(),
      );

      await _partnerService.saveCompanyProfile(
        profile: profile,
        businessRegistrationFile: _businessRegistrationFile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Company profile saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Notify parent that save was successful
        widget.onSaveSuccess?.call();
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = 'An unexpected error occurred';
        
        if (e.error != null) {
          errorMessage = e.error.toString().replaceAll('ApiException: ', '');
        } else if (e.response?.data != null) {
          if (e.response!.data is Map && e.response!.data['message'] != null) {
            errorMessage = e.response!.data['message'];
          } else {
            errorMessage = e.response!.data.toString();
          }
        } else if (e.message != null) {
          errorMessage = e.message!;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: hintTextColor),
      filled: true,
      fillColor: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Company Profile Setup',
          style: TextStyle(color: textColor),
        ),
        iconTheme: const IconThemeData(color: textColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Company Details',
                  style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
          _buildTextField(
            controller: _organizationNameController,
            hint: 'Event Organization Name',
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Organization name is required' 
                : null,
          ),
          _buildTextField(
            controller: _businessEmailController,
            hint: 'Business Email Address',
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value?.trim().isEmpty ?? true) {
                return 'Business email is required';
              }
              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                return 'Enter a valid email address';
              }
              return null;
            },
          ),
          _buildTextField(
            controller: _registeredAddressController,
            hint: 'Registered Company Address',
            maxLines: 3,
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Registered address is required' 
                : null,
          ),
          _buildRegistrationDropdown(),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _hasBusinessRegistration == true
                ? _buildFileUploadBox()
                : const SizedBox.shrink(),
          ),
          _buildTextField(
            controller: _instagramUrlController,
            hint: 'Company Instagram Page Link (Optional)',
          ),
          _buildTextField(
            controller: _facebookUrlController,
            hint: 'Company Facebook Page Link (Optional)',
          ),
          const SizedBox(height: 30),
          const Text('Bank Details',
              style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _bankNameController,
            hint: 'Bank Name',
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Bank name is required' 
                : null,
          ),
          _buildTextField(
            controller: _accountNumberController,
            hint: 'Account Number',
            keyboardType: TextInputType.number,
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Account number is required' 
                : null,
          ),
          _buildTextField(
            controller: _accountHolderNameController,
            hint: 'Account Holder Name',
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Account holder name is required' 
                : null,
          ),
          _buildTextField(
            controller: _branchController,
            hint: 'Branch',
            validator: (value) => value?.trim().isEmpty ?? true 
                ? 'Branch is required' 
                : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: textColor,
                    ),
                  )
                : const Text(
                    'Save & Continue',
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationDropdown() {
    String displayText;
    if (_hasBusinessRegistration == null) {
      displayText = 'Business Registration (BR)?';
    } else if (_hasBusinessRegistration == true) {
      displayText = 'Yes - I have a Business Registration (BR)';
    } else {
      displayText = 'No - I don\'t have a Business Registration (BR)';
    }

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _isDropdownExpanded = !_isDropdownExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _hasBusinessRegistration == null ? hintTextColor : textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: _isDropdownExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down, color: hintTextColor),
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isDropdownExpanded ? 113 : 0,
          margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8.0),
            border: Border.all(
              color: _isDropdownExpanded ? primaryColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDropdownOption(
                  text: 'Yes - I have a Business Registration (BR)',
                  value: true,
                ),
                const Divider(height: 1, color: hintTextColor, indent: 15, endIndent: 15),
                _buildDropdownOption(
                  text: 'No - I don\'t have a Business Registration (BR)',
                  value: false,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDropdownOption({required String text, required bool value}) {
    return InkWell(
      onTap: () {
        setState(() {
          _hasBusinessRegistration = value;
          _isDropdownExpanded = false;
          if (!value) {
            _businessRegistrationFile = null;
          }
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(child: Text(text, style: const TextStyle(color: textColor, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: textColor),
        decoration: _inputDecoration(hint: hint),
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildFileUploadBox() {
    return Container(
      key: const ValueKey('file-upload-box'),
      margin: const EdgeInsets.only(bottom: 16.0),
      child: FileUploadBox(
        title: 'Event Company Registration (BR)',
        subtitle: 'Upload supported files: PDF, DOC, or image, max 5MB.',
        allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
        maxSizeMB: 5,
        initialFile: _businessRegistrationFile,
        onFilePicked: (file) {
          setState(() => _businessRegistrationFile = file);
        },
        onFileRemoved: () {
          setState(() => _businessRegistrationFile = null);
        },
      ),
    );
  }
}
