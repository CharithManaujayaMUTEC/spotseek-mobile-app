import 'dart:async';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';
import 'package:spotseeker_app/screens/events/edit_event_screen.dart';

class EventPreviewTab extends StatefulWidget {
  final EventModel event;

  const EventPreviewTab({super.key, required this.event});

  @override
  State<EventPreviewTab> createState() => _EventPreviewTabState();
}

class _EventPreviewTabState extends State<EventPreviewTab> {
  Timer? _timer;
  Duration _timeRemaining = const Duration(days: 35, hours: 23, minutes: 42);
  DateTime? _editStartDateTime;
  DateTime? _editEndDateTime;
  bool _isEditing = false;
  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _trailerController;
  late TextEditingController _descriptionController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  String? _venueType;
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  // init controllers with event data (some fields not present on model -> start empty)
  _nameController = TextEditingController(text: widget.event.name);
  _venueController = TextEditingController(text: widget.event.venue);
  _trailerController = TextEditingController();
  _descriptionController = TextEditingController();
  _instagramController = TextEditingController();
  _facebookController = TextEditingController();
  _venueType = 'Outdoor';
  _displayName = widget.event.name;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _venueController.dispose();
    _trailerController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeRemaining.inMinutes > 0) {
            _timeRemaining = Duration(minutes: _timeRemaining.inMinutes - 1);
          }
        });
      }
    });
  }

  void _showAddTicketPackageDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final countController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = MediaQuery.of(context).size.width * 0.92;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'New Ticket Package Details',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: nameController,
                        hintText: 'Ticket Package Name',
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: priceController,
                        hintText: 'Ticket Price',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: countController,
                        hintText: 'Ticket Release Count',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            // For preview tab we only close the dialog. Persisting is handled elsewhere.
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditTicketPackageDialog() {
    // local controllers not needed since we use DateTime state

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxW = MediaQuery.of(context).size.width * 0.92;
              return ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Edit Ticket Package Details',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close, color: textColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomTextField(
                        controller: TextEditingController(text: _editStartDateTime != null ? '${_editStartDateTime!.day}/${_editStartDateTime!.month}/${_editStartDateTime!.year}, ${_editStartDateTime!.hour.toString().padLeft(2,'0')}:${_editStartDateTime!.minute.toString().padLeft(2,'0')}' : ''),
                        hintText: 'Start Date, Time',
                        readOnly: true,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _editStartDateTime ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: primaryColor,
                                    surface: Color(0xFF1A1A2E),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_editStartDateTime ?? DateTime.now()),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: primaryColor,
                                      surface: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _editStartDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        controller: TextEditingController(text: _editEndDateTime != null ? '${_editEndDateTime!.day}/${_editEndDateTime!.month}/${_editEndDateTime!.year}, ${_editEndDateTime!.hour.toString().padLeft(2,'0')}:${_editEndDateTime!.minute.toString().padLeft(2,'0')}' : ''),
                        hintText: 'End Date, Time',
                        readOnly: true,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _editEndDateTime ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: ThemeData.dark().copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: primaryColor,
                                    surface: Color(0xFF1A1A2E),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (pickedDate != null) {
                            final pickedTime = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(_editEndDateTime ?? DateTime.now()),
                              builder: (context, child) {
                                return Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: primaryColor,
                                      surface: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (pickedTime != null) {
                              setState(() {
                                _editEndDateTime = DateTime(
                                  pickedDate.year,
                                  pickedDate.month,
                                  pickedDate.day,
                                  pickedTime.hour,
                                  pickedTime.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Save',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Edit Button
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () async {
                final updated = await Navigator.push<EventModel?>(
                  context,
                  MaterialPageRoute(builder: (_) => EditEventScreen(event: widget.event)),
                );
                if (updated != null) {
                  setState(() {
                    // update local display name and image
                    _displayName = updated.name;
                  });
                }
              },
              icon: const Icon(Icons.edit, size: 16, color: primaryColor),
              label: const Text(
                'Edit Event Details',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Event Banner
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              widget.event.imageUrl,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 250,
                  decoration: BoxDecoration(
                    color: hintTextColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.image, color: hintTextColor, size: 60),
                );
              },
            ),
          ),
          
          const SizedBox(height: 16),

          // Event Title
          Text(
            _displayName,
            style: const TextStyle(
              color: textColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 4),
          
          const Text(
            'By Momento Magico',
            style: TextStyle(
              color: hintTextColor,
              fontSize: 13,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Social Icons
          Row(
            children: [
              _buildSocialIcon(Icons.facebook, () {}),
              const SizedBox(width: 12),
              _buildSocialIcon(Icons.camera_alt, () {}),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Event Details Cards
          _buildInfoCard(
            icon: Icons.calendar_today,
            text: 'Mon, 25th Aug 2025',
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.access_time,
            text: '4:30 PM onwards',
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            icon: Icons.location_on,
            title: 'Colombo City Hall Grounds',
            subtitle: 'Outdoor Event',
            hasNavigate: true,
          ),
          
          const SizedBox(height: 24),
          
          // Countdown
          _buildCountdownSection(),
          
          const SizedBox(height: 24),
          
          // About Event
          const Text(
            'About Event',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAboutSection(),
          
          const SizedBox(height: 24),

          // Event Details Section (editable)
          const Text(
            'Event Details',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_isEditing) ...[
            CustomTextField(controller: _nameController, hintText: 'Event Name'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _venueType,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Venue Type', style: TextStyle(color: hintTextColor)),
                  ),
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1A1A2E),
                  icon: const Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: Icon(Icons.keyboard_arrow_down, color: textColor),
                  ),
                  items: ['Outdoor', 'Indoor', 'Virtual'].map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(item, style: const TextStyle(color: textColor)),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _venueType = v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(controller: _trailerController, hintText: 'Event Trailer Video link'),
            const SizedBox(height: 12),
            CustomTextField(controller: _descriptionController, hintText: 'Event Description On The Website', maxLines: 4),
            const SizedBox(height: 12),
            CustomTextField(controller: _instagramController, hintText: 'Event Instagram Page Link'),
            const SizedBox(height: 12),
            CustomTextField(controller: _facebookController, hintText: 'Event Facebook Page Link'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  setState(() {
                    _displayName = _nameController.text;
                    _isEditing = false;
                  });
                },
                child: const Text('Update Event Details', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 24),
          ] else ...[
            const SizedBox(height: 8),
          ],

          // Ticket Packages
          const Text(
            'Ticket Packages',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildAddTicketButton(),
          const SizedBox(height: 12),
          _buildTicketPackageCard(
            tier: 'Tier 1',
            price: 'Rs 5,000',
            releaseCount: 'Release Count: 500',
            dateTime: '25th Aug 2025 | 9:00AM - 12:00PM',
            status: 'Releasing Soon',
          ),
          const SizedBox(height: 12),
          _buildTicketPackageCard(
            tier: 'Tier 3',
            price: 'Rs 5,000',
            releaseCount: 'Release Count: 500',
            dateTime: '25th Aug 2025 | 9:00AM - 12:00PM',
            status: 'Releasing Soon',
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
          ),
        ),
        child: Icon(icon, color: textColor, size: 18),
      ),
    );
  }

  Widget _buildInfoCard({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool hasNavigate,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: hintTextColor.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (hasNavigate)
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text(
                    'Navigate',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.navigation, color: primaryColor, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCountdownSection() {
    final days = _timeRemaining.inDays;
    final hours = _timeRemaining.inHours.remainder(24);
    final minutes = _timeRemaining.inMinutes.remainder(60);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Event Starts in',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildTimeBox('${days}d'),
            const SizedBox(width: 4),
            const Text(':', style: TextStyle(color: textColor, fontSize: 20)),
            const SizedBox(width: 4),
            _buildTimeBox('${hours}h'),
            const SizedBox(width: 4),
            const Text(':', style: TextStyle(color: textColor, fontSize: 20)),
            const SizedBox(width: 4),
            _buildTimeBox('${minutes}m'),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Get ready for the most electrifying summer night! ✨ Summer Beats Festival 2025 brings together top local and international artists for an unforgettable music celebration under the stars. Expect amazing performances, vibrant lighting, and a lively festival atmosphere. ',
            style: TextStyle(
              color: textColor.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Read More',
            style: TextStyle(
              color: primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddTicketButton() {
    return GestureDetector(
      onTap: _showAddTicketPackageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: textColor, size: 20),
            SizedBox(width: 8),
            Text(
              'Add New Ticket Packages',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketPackageCard({
    required String tier,
    required String price,
    required String releaseCount,
    required String dateTime,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Ticket Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.confirmation_number, color: primaryColor, size: 20),
          ),
          const SizedBox(width: 12),
          // Ticket Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _showEditTicketPackageDialog,
                      icon: const Icon(Icons.edit, size: 14, color: primaryColor),
                      label: const Text(
                        'Edit',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  price,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  releaseCount,
                  style: TextStyle(
                    color: hintTextColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateTime,
                  style: TextStyle(
                    color: hintTextColor.withValues(alpha: 0.8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status,
                  style: TextStyle(
                    color: hintTextColor.withValues(alpha: 0.8),
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
