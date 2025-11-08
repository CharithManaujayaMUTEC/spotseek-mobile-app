import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';

class SpecialInvitationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  
  const SpecialInvitationScreen({super.key, this.onBack});

  @override
  State<SpecialInvitationScreen> createState() => _SpecialInvitationScreenState();
}

class _SpecialInvitationScreenState extends State<SpecialInvitationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  
  String? _selectedInvitationType;
  String? _selectedCategory;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroundColor,
              backgroundColor.withValues(alpha: 0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: widget.onBack ?? () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: textColor),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Single Invitation',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                _buildDropdownField(
                  hint: 'Invitation Type',
                  value: _selectedInvitationType,
                  items: ['Spotseeker Invitation', 'Special Invitation'],
                  onChanged: (value) {
                    setState(() {
                      _selectedInvitationType = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildDropdownField(
                  hint: 'Category',
                  value: _selectedCategory,
                  items: ['General Invitation', 'VIP Invitation', 'Backstage Invitation'],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Name',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _phoneController,
                  hint: 'Phone Number - 94xxxxxxxxx',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _countController,
                  hint: 'Invitation Count - MAX 5',
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                _buildGenerateButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1.3,
          color: hintTextColor.withValues(alpha: 0.12),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.5),
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: textColor.withValues(alpha: 0.7),
            size: 24,
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(8),
          elevation: 8,
          style: const TextStyle(
            color: textColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
          menuMaxHeight: 300,
          itemHeight: 48,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 1.3,
          color: hintTextColor.withValues(alpha: 0.12),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: textColor.withValues(alpha: 0.5),
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateButton() {
    return GestureDetector(
      onTap: () {
        if (_nameController.text.isEmpty ||
            _phoneController.text.isEmpty ||
            _countController.text.isEmpty ||
            _selectedInvitationType == null ||
            _selectedCategory == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please fill all fields'),
              backgroundColor: primaryColor,
            ),
          );
          return;
        }
        
        print('Generating invitation...');
        print('Type: $_selectedInvitationType');
        print('Category: $_selectedCategory');
        print('Name: ${_nameController.text}');
        print('Phone: ${_phoneController.text}');
        print('Count: ${_countController.text}');
      },
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: primaryColor,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            width: 1,
            color: primaryColor,
          ),
        ),
        child: const Center(
          child: Text(
            'Send Invitation',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.32,
            ),
          ),
        ),
      ),
    );
  }
}