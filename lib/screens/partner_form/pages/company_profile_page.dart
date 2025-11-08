import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends State<CompanyProfilePage> {
  bool _isDropdownExpanded = false;
  bool? _hasBusinessRegistration;

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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Company Details',
            style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(hint: 'Event Organization Name'),
        _buildTextField(hint: 'Business Email Address'),
        _buildTextField(hint: 'Registered Company Address'),
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
        _buildTextField(hint: 'Company Instagram Page Link'),
        _buildTextField(hint: 'Company Facebook Page Link'),
        const SizedBox(height: 30),
        const Text('Bank Details',
            style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(hint: 'Bank Name'),
        _buildTextField(hint: 'Account Number'),
        _buildTextField(hint: 'Account Name'),
        _buildTextField(hint: 'Branch'),
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
              // No mainAxisAlignment needed, Expanded will handle the space.
              children: [
                // --- THIS IS THE FIX ---
                Expanded(
                  child: Text(
                    displayText,
                    maxLines: 1, // Force text to stay on a single line
                    softWrap: false, // Prevent wrapping
                    overflow: TextOverflow.ellipsis, // Use ... if text is too long
                    style: TextStyle(
                      color: _hasBusinessRegistration == null ? hintTextColor : textColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                // --- END OF FIX ---
                const SizedBox(width: 8), // A small gap between text and icon
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

  Widget _buildTextField({required String hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        style: const TextStyle(color: textColor),
        decoration: _inputDecoration(hint: hint),
      ),
    );
  }

  Widget _buildFileUploadBox() {
    return Container(
      key: const ValueKey('file-upload-box'),
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Event Company Registration (BR)',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 16),
          ),
          SizedBox(height: 16),
          Icon(Icons.cloud_upload_outlined, color: hintTextColor, size: 40),
          SizedBox(height: 10),
          Text(
            'Upload up to 5 supported files: PDF, DOC, or\nimage, up to 50MB.',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintTextColor, fontSize: 12),
          ),
        ],
      ),
    );
  }
}