import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spotseeker_app/models/partner/partner_models.dart';
import 'package:spotseeker_app/utils/colors.dart';

class CompanyProfilePage extends StatefulWidget {
  final Set<String>? editableFields;

  const CompanyProfilePage({super.key, this.editableFields});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  // Controllers for form fields (no UI changes)
  final TextEditingController _organizationNameController =
      TextEditingController();
  final TextEditingController _businessEmailController =
      TextEditingController();
  final TextEditingController _registeredAddressController =
      TextEditingController();
  final TextEditingController _instagramUrlController = TextEditingController();
  final TextEditingController _facebookUrlController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _accountNumberController =
      TextEditingController();
  final TextEditingController _accountHolderNameController =
      TextEditingController();
  final TextEditingController _branchController = TextEditingController();

  bool _isDropdownExpanded = false;
  bool? _hasBusinessRegistration;
  File? _businessRegistrationFile;

  bool _isEditable(String key) {
    final fields = widget.editableFields;
    if (fields == null) return true;
    return fields.contains(key);
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
        borderSide: BorderSide(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.deepPurple.shade200, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Company Details',
            style: TextStyle(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(
            hint: 'Event Organization Name',
            controller: _organizationNameController,
            readOnly: !_isEditable('organizationName')),
        _buildTextField(
            hint: 'Business Email Address',
            controller: _businessEmailController,
            readOnly: !_isEditable('businessEmail')),
        _buildTextField(
            hint: 'Registered Company Address',
            controller: _registeredAddressController,
            readOnly: !_isEditable('registeredAddress')),
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
            hint: 'Company Instagram Page Link',
            controller: _instagramUrlController,
            readOnly: !_isEditable('instagramUrl')),
        _buildTextField(
            hint: 'Company Facebook Page Link',
            controller: _facebookUrlController,
            readOnly: !_isEditable('facebookUrl')),
        const SizedBox(height: 30),
        const Text('Bank Details',
            style: TextStyle(
                color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(
            hint: 'Bank Name',
            controller: _bankNameController,
            readOnly: !_isEditable('bankName')),
        _buildTextField(
            hint: 'Account Number',
            controller: _accountNumberController,
            readOnly: !_isEditable('accountNumber')),
        _buildTextField(
            hint: 'Account Name',
            controller: _accountHolderNameController,
            readOnly: !_isEditable('accountHolderName')),
        _buildTextField(
            hint: 'Branch',
            controller: _branchController,
            readOnly: !_isEditable('branch')),
      ],
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
          onTap: _isEditable('hasBusinessRegistration')
              ? () {
                  setState(() {
                    _isDropdownExpanded = !_isDropdownExpanded;
                  });
                }
              : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Row(
              // No mainAxisAlignment needed, Expanded will handle the space.
              children: [
                // --- THIS IS THE FIX ---
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1, // Force text to stay on a single line
                    softWrap: false, // Prevent wrapping
                    overflow:
                        TextOverflow.ellipsis, // Use ... if text is too long
                    style: TextStyle(
                      color: _hasBusinessRegistration == null
                          ? hintTextColor
                          : textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                // --- END OF FIX ---
                const SizedBox(width: 8), // A small gap between text and icon
                AnimatedRotation(
                  turns: _isDropdownExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: hintTextColor),
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
              children: [
                _buildDropdownOption(
                  text: 'Yes - I have a Business Registration (BR)',
                  value: true,
                ),
                const Divider(
                    height: 1, color: hintTextColor, indent: 15, endIndent: 15),
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
      onTap: _isEditable('hasBusinessRegistration')
          ? () {
              setState(() {
                _hasBusinessRegistration = value;
                _isDropdownExpanded = false;
              });
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
                child: Text(text,
                    style: const TextStyle(color: textColor, fontSize: 16))),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      {required String hint,
      TextEditingController? controller,
      bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        style: const TextStyle(color: textColor),
        controller: controller,
        readOnly: readOnly,
        decoration: _inputDecoration(hint: hint),
      ),
    );
  }

  Widget _buildFileUploadBox() {
    return InkWell(
      onTap: _isEditable('businessRegistrationFile')
          ? _pickBusinessRegistrationFile
          : null,
      child: Container(
        key: const ValueKey('file-upload-box'),
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: _businessRegistrationFile == null
                ? Colors.deepPurple.shade300.withValues(alpha: 0.4)
                : Colors.green.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Event Company Registration (BR)',
              textAlign: TextAlign.center,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Icon(
              Icons.cloud_upload_outlined,
              color: _businessRegistrationFile == null
                  ? hintTextColor
                  : Colors.green,
              size: 40,
            ),
            const SizedBox(height: 10),
            Text(
              _businessRegistrationFile == null
                  ? 'Upload up to 5 supported files: PDF, DOC, or\nimage, up to 50MB.'
                  : _businessRegistrationFile!.path.split('/').last,
              textAlign: TextAlign.center,
              style: const TextStyle(color: hintTextColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickBusinessRegistrationFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf', 'doc', 'docx', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          _businessRegistrationFile = File(result.files.single.path!);
        });
      }
    } catch (_) {
      // Silent fail with UI unchanged
    }
  }

  // Expose data to parent without changing UI
  CompanyProfile? buildCompanyProfileOrNull() {
    if (_organizationNameController.text.trim().isEmpty ||
        _businessEmailController.text.trim().isEmpty ||
        _registeredAddressController.text.trim().isEmpty ||
        _bankNameController.text.trim().isEmpty ||
        _accountNumberController.text.trim().isEmpty ||
        _accountHolderNameController.text.trim().isEmpty ||
        _branchController.text.trim().isEmpty ||
        _hasBusinessRegistration == null) {
      return null;
    }

    return CompanyProfile(
      organizationName: _organizationNameController.text.trim(),
      businessEmail: _businessEmailController.text.trim(),
      registeredAddress: _registeredAddressController.text.trim(),
      hasBusinessRegistration: _hasBusinessRegistration ?? false,
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
  }

  File? getBusinessRegistrationFile() => _businessRegistrationFile;

  // Hydrate from a lightweight profile response
  void applyPartnerProfile(PartnerProfile profile) {
    try {
      if (profile.organizationName != null &&
          profile.organizationName!.isNotEmpty) {
        _organizationNameController.text = profile.organizationName!;
      }
      if (profile.businessEmail != null && profile.businessEmail!.isNotEmpty) {
        _businessEmailController.text = profile.businessEmail!;
      }
      // Other fields may not be available in PartnerProfile; skip safely
      setState(() {});
    } catch (_) {
      // ignore hydration errors silently
    }
  }
}
