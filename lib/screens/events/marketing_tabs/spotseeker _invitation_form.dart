import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotseekerInvitationScreen extends StatefulWidget {
  final VoidCallback? onBack;
  
  const SpotseekerInvitationScreen({super.key, this.onBack});

  @override
  State<SpotseekerInvitationScreen> createState() => _SpotseekerInvitationScreenState();
}

class _SpotseekerInvitationScreenState extends State<SpotseekerInvitationScreen> {
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
  Future<void> _sendWhatsAppInvitation(String phoneNumber, String name, String category) async {
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    
    if (!cleanPhone.startsWith('94')) {
      cleanPhone = '94$cleanPhone';
    }

    String message = '''
Hello $name! 🎉

You've been invited to our event!

*Invitation Details:*
Category: $category
Phone: $phoneNumber

Please present this invitation at the entrance.

Looking forward to seeing you!
    ''';

    final Uri whatsappUrl = Uri.parse(
      'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}'
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _downloadQRCode(String name, String category) async {
    // TODO: Implement actual QR code generation and download
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Downloading QR code for $name'),
        backgroundColor: Colors.green,
      ),
    );

    print('Downloading QR for: $name - $category');
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
                const Text(
                  'Recent Invitations',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                // TODO: Replace with dynamic list of invitations
                buildUserCard(
                  name: 'John Doe',
                  phoneNumber: '94771234567',
                  subtitle: 'VIP Invitation - Table #12',
                  imageUrl: 'https://i.pravatar.cc/300?img=1',
                  onWhatsApp: () => _sendWhatsAppInvitation('94771234567', 'John Doe', 'VIP Invitation'),
                  onDownload: () => _downloadQRCode('John Doe', 'VIP Invitation'),
                ),
                
                const SizedBox(height: 16),
                
                buildUserCard(
                  name: 'Sarah Johnson',
                  phoneNumber: '94772345678',
                  subtitle: 'General Admission',
                  imageUrl: 'https://i.pravatar.cc/300?img=5',
                  onWhatsApp: () => _sendWhatsAppInvitation('94772345678', 'Sarah Johnson', 'General Admission'),
                  onDownload: () => _downloadQRCode('Sarah Johnson', 'General Admission'),
                ),
                
                const SizedBox(height: 16),
                
                buildUserCard(
                  name: 'Michael Chen',
                  phoneNumber: '94773456789',
                  subtitle: 'Backstage Pass - Artist',
                  imageUrl: 'https://i.pravatar.cc/300?img=12',
                  onWhatsApp: () => _sendWhatsAppInvitation('94773456789', 'Michael Chen', 'Backstage Pass'),
                  onDownload: () => _downloadQRCode('Michael Chen', 'Backstage Pass'),
                ),
                
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
        
        // TODO: Add logic to generate and save invitation
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
            'Generate & Download QR',
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
Widget buildUserCard({
  required String name,
  required String phoneNumber,
  required String subtitle,
  required String imageUrl,
  VoidCallback? onWhatsApp,
  VoidCallback? onDownload,
}) {
  return Container(
    width: double.infinity,
    height: 241,
    clipBehavior: Clip.antiAlias,
    decoration: ShapeDecoration(
      color: Colors.black.withValues(alpha: 0.10),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          width: 1.30,
          color: Colors.white.withValues(alpha: 0.16),
        ),
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    child: Column(
      children: [
        Container(
          width: double.infinity,
          height: 133,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.10),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Icon(
                  Icons.person_outline,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              );
            },
          ),
        ),
        
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: const ShapeDecoration(
              color: Color(0xFF280929),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Opacity(
                        opacity: 0.60,
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                Row(
                  children: [
                    GestureDetector(
                      onTap: onWhatsApp,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: const OvalBorder(),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/whatsapp_icon.svg',
                            width: 20,
                            height: 20,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withValues(alpha: 0.6),
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 8),
                    
                    GestureDetector(
                      onTap: onDownload,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: ShapeDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: const OvalBorder(),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.download,
                            color: Colors.white.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}