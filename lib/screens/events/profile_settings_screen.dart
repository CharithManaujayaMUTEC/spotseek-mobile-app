import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/profile_tab_screen.dart';
import 'package:spotseeker_app/models/profile.dart';
import 'package:spotseeker_app/services/profile_repository.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  bool _appNotifications = true;
  bool _appPermissions = true;

  Profile? _profile;
  bool _loadingProfile = true;

  // Use mock repo for now; swap with a remote repo later via DI
  final ProfileRepository _profileRepo = MockProfileRepository();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _profileRepo.loadProfile();
      setState(() {
        _profile = profile;
        _appNotifications = profile.appNotifications;
        _appPermissions = profile.appPermissions;
        _loadingProfile = false;
      });
    } catch (e) {
      setState(() {
        _loadingProfile = false;
      });
      // ignore: avoid_print
      print('Failed to load profile mock: $e');
    }
  }

  void _onEditProfileTapped() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildEditBottomSheet(),
    );
  }

  Widget _buildEditBottomSheet() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Container(
          decoration: backgroundGradient(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: hintTextColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, color: primaryColor),
                  title: const Text('Change profile photo', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit, color: primaryColor),
                  title: const Text('Edit name', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showEditNameDialog();
                  },
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: hintTextColor)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _profile?.name ?? '');
    controller.selection = TextSelection.collapsed(offset: controller.text.length);
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: backgroundGradient(),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edit name', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w400)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    cursorColor: const Color(0xFF9E9E9E).withValues(alpha: 0.6),
                    style: const TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: controller.text.isEmpty ? 'Enter your name' : null,
                      hintStyle: TextStyle(color: const Color(0xFF9E9E9E).withValues(alpha: 0.6)),
                      filled: true,
                      fillColor: backgroundColor.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintTextColor.withValues(alpha: 0.12)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: hintTextColor.withValues(alpha: 0.12)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: const Color(0xFF9E9E9E).withValues(alpha: 0.6), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: hintTextColor)),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () {
                          final newName = controller.text.trim();
                          setState(() {
                            _profile = Profile(
                              name: newName.isNotEmpty ? newName : (_profile?.name ?? ''),
                              avatarUrl: _profile?.avatarUrl ?? '',
                              appNotifications: _appNotifications,
                              appPermissions: _appPermissions,
                              version: _profile?.version ?? '',
                            );
                          });
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name updated')));
                        },
                        child: const Text('Save', style: TextStyle(color: primaryColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() {
        _profile = Profile(
          name: _profile?.name ?? '',
          avatarUrl: picked.path,
          appNotifications: _appNotifications,
          appPermissions: _appPermissions,
          version: _profile?.version ?? '',
        );
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile photo updated')));
    } catch (e) {
      // ignore: avoid_print
      print('Image pick failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image')));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildProfileHeader(),
                const SizedBox(height: 62),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSection('General', [
                        _buildMenuItem(
                          'Coordinators',
                          hasArrow: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileTabScreen(
                                  initialView: ProfileInitialView.coordinators,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          'Rate Card',
                          hasArrow: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileTabScreen(
                                  initialView: ProfileInitialView.rateCard,
                                ),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          'Invoice', 
                          hasArrow: true, 
                          onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileTabScreen(
                                    initialView: ProfileInitialView.invoicePending,
                                  ),
                                ),
                              );
                            },
                          ),
                        _buildMenuItem(
                          'Logo & Assets', 
                          hasArrow: true, 
                          showDivider: false,
                          onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileTabScreen(
                                      initialView: ProfileInitialView.logoandassets,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ]
                        ),
                      const SizedBox(height: 40),
                      _buildSection('Settings', [
                        _buildMenuItem('App Notifications', 
                          hasToggle: true, 
                          toggleValue: _appNotifications,
                          onToggle: (value) {
                            setState(() {
                              _appNotifications = value;
                            });
                          },
                          onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileTabScreen(
                                      initialView: ProfileInitialView.notifications,
                                    ),
                                  ),
                                );
                              },
                        ),
                        _buildMenuItem('App Permissions', 
                          hasToggle: true, 
                          toggleValue: _appPermissions,
                          onToggle: (value) {
                            setState(() {
                              _appPermissions = value;
                            });
                          },
                          onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const ProfileTabScreen(
                                      initialView: ProfileInitialView.apppermissions,
                                    ),
                                  ),
                                );
                              },
                        ),
                        _buildMenuItem('Talk to Us', hasArrow: true, showDivider: false),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('Other', [
                        _buildMenuItem(
                          'About Us', 
                          hasArrow: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProfileTabScreen(
                                    initialView: ProfileInitialView.aboutus,
                                  ),
                                ),
                              );
                            }),
                        _buildMenuItem('Privacy Policy', hasArrow: true),
                        _buildMenuItem('Terms & Conditions', hasArrow: true, showDivider: false),
                      ]),
                      const SizedBox(height: 40),
                      _buildSection('Our Socials', [
                        _buildMenuItem('Facebook', icon: Icons.facebook, hasArrow: true),
                        _buildMenuItem('Instagram', icon: Icons.camera_alt, hasArrow: true, showDivider: false),
                      ]),
                      const SizedBox(height: 40),
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            'Log out',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Opacity(
                          opacity: 0.6,
                          child: Text(
                            _profile?.version ?? 'Version not found',
                            style: const TextStyle(
                              color: textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
  return Column(
    children: [
      Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 136,
            height: 136,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment(0.95, -0.31), 
                end: Alignment(-0.95, 0.31),
                colors: [
                  Color(0xFFE50914),
                  Color(0xFFFF5858),
                  Color(0xFF4C008B),
                ],
              ),
            ),
          ),
          
          Container(
            width: 124,
            height:164,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
          ),
          
          CircleAvatar(
            radius: 58,
            backgroundImage: _buildAvatarImageProvider(),
          ),
          
          Positioned(
            top: 0,
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [primaryColor, Color(0xFFFF5858), Color(0xFF4C008B)],
                ),
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.asset(
                  'assets/crown-1.png',
                  width: 18,
                  height: 18,
                  color: textColor,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 16),
      Text(
        _profile?.name ?? 'Name not found',
        style: const TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _onEditProfileTapped,
        child: const Opacity(
          opacity: 0.6,
          child: Text(
            'Edit',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.only(left: 12, right: 12, top: 24),
          decoration: BoxDecoration(
            color: backgroundColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              color: hintTextColor.withValues(alpha: 0.12),
            ),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    String title, {
    bool hasArrow = false,
    bool hasToggle = false,
    bool toggleValue = false,
    Function(bool)? onToggle,
    IconData? icon,
    bool showDivider = true,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (icon != null)
                    Icon(icon, color: textColor, size: 24)
                  else
                    const SizedBox(width: 20, height: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              if (hasArrow)
                const Icon(Icons.arrow_forward_ios, color: textColor, size: 16)
              else if (hasToggle)
                GestureDetector(
                  onTap: () {
                    if (onToggle != null) {
                      onToggle(!toggleValue);
                    }
                  },
                  child: _buildToggle(toggleValue),
                )
              else
                const SizedBox(width: 16),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (showDivider) ...[
          Container(
            height: 1,
            color: hintTextColor.withValues(alpha: 0.1),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildToggle(bool value) {
    return Container(
      width: 33,
      height: 20,
      decoration: BoxDecoration(
        color: value ? primaryColor : hintTextColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedAlign(
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        duration: const Duration(milliseconds: 200),
        child: Container(
          margin: const EdgeInsets.all(2),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: textColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withValues(alpha: 0.12),
                blurRadius: 7,
                offset: const Offset(0, 3),
              )
            ],
          ),
        ),
      ),
    );
  }

  ImageProvider<Object>? _buildAvatarImageProvider() {
    final avatar = _profile?.avatarUrl;
    if (avatar == null || avatar.isEmpty) return null;
    if (avatar.startsWith('http') || avatar.startsWith('https')) {
      return NetworkImage(avatar);
    }
    try {
      final file = File(avatar);
      if (file.existsSync()) return FileImage(file);
    } catch (_) {
      // fall through to null
    }
    return null;
  }
}