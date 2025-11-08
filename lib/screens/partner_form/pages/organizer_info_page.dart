import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';

enum IdType { nic, drivingLicense, passport }

class OrganizerInfoPage extends StatefulWidget {
  const OrganizerInfoPage({super.key});

  @override
  State<OrganizerInfoPage> createState() => _OrganizerInfoPageState();
}

class _OrganizerInfoPageState extends State<OrganizerInfoPage> {
  IdType? _selectedIdType;
  bool _isDropdownExpanded = false;

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
        const Text('Event Organizer Details',
            style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        _buildTextField(hint: 'Name of the Event Organizer'),
        _buildTextField(hint: 'Mobile Number of the Event Organizer'),
        _buildTextField(hint: 'Address of the Event Organizer'),
        _buildTextField(hint: 'NIC Number of the Event Organizer'),
        _buildIdTypeDropdown(),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: _buildConditionalFileUploaders(),
        ),
      ],
    );
  }

  Widget _buildIdTypeDropdown() {
    String displayText;
    if (_selectedIdType == null) {
      displayText = 'Select One';
    } else {
      switch (_selectedIdType!) {
        case IdType.nic:
          displayText = 'NIC';
          break;
        case IdType.drivingLicense:
          displayText = 'Driving License';
          break;
        case IdType.passport:
          displayText = 'Passport';
          break;
      }
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    color: _selectedIdType == null ? hintTextColor : textColor,
                    fontSize: 16,
                  ),
                ),
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
          height: _isDropdownExpanded ? 160 : 0,
          margin: _isDropdownExpanded ? const EdgeInsets.only(top: 2) : EdgeInsets.zero,
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
                _buildDropdownOption(text: 'NIC', value: IdType.nic),
                const Divider(height: 1, color: hintTextColor, indent: 15, endIndent: 15),
                _buildDropdownOption(text: 'Driving License', value: IdType.drivingLicense),
                const Divider(height: 1, color: hintTextColor, indent: 15, endIndent: 15),
                _buildDropdownOption(text: 'Passport', value: IdType.passport),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownOption({required String text, required IdType value}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIdType = value;
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

  Widget _buildConditionalFileUploaders() {
    if (_selectedIdType == null) {
      return const SizedBox.shrink(key: ValueKey('empty'));
    }

    switch (_selectedIdType!) {
      case IdType.nic:
        return Row(
          key: const ValueKey('nic'),
          children: [
            // When in a row, we use Expanded to divide the space.
            Expanded(child: _buildFileUploadBox(title: 'NIC - Front')),
            const SizedBox(width: 16),
            Expanded(child: _buildFileUploadBox(title: 'NIC - Back')),
          ],
        );
      case IdType.drivingLicense:
        return Row(
          key: const ValueKey('driving-license'),
          children: [
            Expanded(child: _buildFileUploadBox(title: 'Driving License - Front')),
            const SizedBox(width: 16),
            Expanded(child: _buildFileUploadBox(title: 'Driving License - Back')),
          ],
        );
      case IdType.passport:
        // When standalone, we don't use Expanded, and the box itself will fill the width.
        return _buildFileUploadBox(
          key: const ValueKey('passport'),
          title: 'Passport',
        );
    }
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

  // --- THIS IS THE FIX ---
  // The builder method is simplified and now works in both standalone and Row contexts.
  Widget _buildFileUploadBox({Key? key, required String title}) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      // By setting the crossAxisAlignment to stretch, the Column forces its
      // children to be as wide as possible. This makes the Container fill the
      // available width, whether it's the full screen or half the screen inside an Expanded.
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            // We must now explicitly center the text, since the column is stretching.
            textAlign: TextAlign.center,
            style: const TextStyle(color: textColor, fontSize: 14),
          ),
          const SizedBox(height: 16),
          const Icon(Icons.cloud_upload_outlined, color: hintTextColor, size: 30),
          const SizedBox(height: 10),
          const Text(
            'Upload 1 supported file: PDF, document or image. Max 10 MB.',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintTextColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}