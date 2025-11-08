import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';
import 'package:spotseeker_app/services/analytics_service.dart';
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
  late String _bannerImg;
  late String _organizer;
  late String _venueName;
  late String _venueLocationUrl;
  late String _subType;
  late String _startDateStr;
  late String _descriptionStr;
  List<Map<String, dynamic>> _packages = [];

  @override
  void initState() {
    super.initState();
    // init controllers with event data (some fields not present on model -> start empty)
    _nameController = TextEditingController(text: widget.event.name);
    _venueController = TextEditingController(text: widget.event.venue);
    _trailerController = TextEditingController();
    _descriptionController = TextEditingController();
    _instagramController = TextEditingController();
    _facebookController = TextEditingController();
    _venueType = 'Outdoor';
    _displayName = widget.event.name;
    _bannerImg = widget.event.bannerImg;
    _organizer = widget.event.organizer;
    _venueName = widget.event.venueName;
    _venueLocationUrl = widget.event.venueLocationUrl;
    _subType = widget.event.subType;
    _startDateStr = widget.event.startDate;
    _descriptionStr = widget.event.description;
    // Start countdown after we have initial event data
    _startCountdown();
    _fetchEvent();
    _fetchPackages();
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

  void _updateTimeRemainingFromStart() {
    try {
      final start = DateTime.parse(_startDateStr);
      final now = DateTime.now();
      final diff = start.difference(now);
      _timeRemaining = diff.isNegative ? Duration.zero : diff;
    } catch (_) {}
  }

  void _startCountdown() {
    // Initial compute
    setState(_updateTimeRemainingFromStart);
    // Tick every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!mounted) return;
      setState(_updateTimeRemainingFromStart);
    });
  }

  Future<void> _fetchEvent() async {
    try {
      final fresh = await AnalyticsService()
          .getEventById(widget.event.id, event: widget.event);
      if (!mounted) return;
      setState(() {
        _displayName = fresh.name;
        _bannerImg = fresh.bannerImg.isNotEmpty ? fresh.bannerImg : _bannerImg;
        _organizer = fresh.organizer.isNotEmpty ? fresh.organizer : _organizer;
        _venueName = fresh.venueName.isNotEmpty ? fresh.venueName : _venueName;
        _venueLocationUrl = fresh.venueLocationUrl.isNotEmpty
            ? fresh.venueLocationUrl
            : _venueLocationUrl;
        _subType = fresh.subType.isNotEmpty ? fresh.subType : _subType;
        _startDateStr =
            fresh.startDate.isNotEmpty ? fresh.startDate : _startDateStr;
        _descriptionStr =
            fresh.description.isNotEmpty ? fresh.description : _descriptionStr;
        // Update edit controllers
        _nameController.text = _displayName;
        _venueController.text = _venueName;
        _descriptionController.text = _descriptionStr;
        _updateTimeRemainingFromStart();
      });
    } catch (_) {}
  }

  Future<void> _fetchPackages() async {
    try {
      final svc = AnalyticsService();
      final raw =
          await svc.getBasicFinanceRaw(widget.event.id, event: widget.event);
      final pkgs = (raw['ticket_packages'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map((p) => {
                'name': p['name']?.toString() ?? '-',
                'price': p['price']?.toString() ?? '0',
                'tot_tickets': (p['tot_tickets'] is num)
                    ? (p['tot_tickets'] as num).toInt()
                    : int.tryParse(p['tot_tickets']?.toString() ?? '0') ?? 0,
                'sold_out': p['sold_out'] == true,
                'active': p['active'] == true,
              })
          .toList();
      if (!mounted) return;
      setState(() => _packages = pkgs);
    } catch (_) {
      if (mounted) setState(() => _packages = []);
    }
  }

  Future<void> _submitEventUpdate() async {
    final String newName = _nameController.text.trim();
    final String newDescription = _descriptionController.text.trim();
    final Map<String, dynamic> payload = {
      if (newName.isNotEmpty) 'name': newName,
      if (newDescription.isNotEmpty) 'description': newDescription,
      if (newDescription.isNotEmpty) 'json_desc': newDescription,
    };

    if (payload.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Nothing to update'),
              backgroundColor: Colors.orange),
        );
      }
      return;
    }

    try {
      final updated = await AnalyticsService().updateEvent(
        widget.event.id,
        data: payload,
        event: widget.event,
      );
      if (!mounted) return;
      setState(() {
        _displayName = updated.name;
        _descriptionStr = updated.description;
        _isEditing = false;
      });
      // Re-fetch to ensure parity with server-side transformations
      await _fetchEvent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Event updated'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Update failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatEventDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];

      final weekday = weekdays[dateTime.weekday - 1];
      final day = dateTime.day;
      final suffix = _getDaySuffix(day);
      final month = months[dateTime.month - 1];
      final year = dateTime.year;

      return '$weekday, $day$suffix $month $year';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _formatEventTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

      return '$displayHour:$minute $period onwards';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _parseDescription(String descriptionJson) {
    try {
      dynamic decoded = jsonDecode(descriptionJson);
      // Handle double-encoded Draft.js JSON (string that contains JSON)
      if (decoded is String) {
        try {
          decoded = jsonDecode(decoded);
        } catch (_) {
          // Not valid nested JSON, treat as plain text
          return decoded.toString();
        }
      }

      if (decoded is Map<String, dynamic>) {
        final List<dynamic>? blocks = decoded['blocks'];
        if (blocks != null && blocks.isNotEmpty) {
          final textBlocks = blocks
              .map((block) => (block is Map && block['text'] is String)
                  ? (block['text'] as String)
                  : '')
              .where((text) => text.trim().isNotEmpty)
              .join('\n\n');
          if (textBlocks.isNotEmpty) return textBlocks;
        }
      }
      // Fallback: if structure not as expected, return original string
      return descriptionJson;
    } catch (_) {
      // If parsing fails at any point, return as-is
      return descriptionJson;
    }
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        controller: TextEditingController(
                            text: _editStartDateTime != null
                                ? '${_editStartDateTime!.day}/${_editStartDateTime!.month}/${_editStartDateTime!.year}, ${_editStartDateTime!.hour.toString().padLeft(2, '0')}:${_editStartDateTime!.minute.toString().padLeft(2, '0')}'
                                : ''),
                        hintText: 'Start Date, Time',
                        readOnly: true,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _editStartDateTime ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
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
                              initialTime: TimeOfDay.fromDateTime(
                                  _editStartDateTime ?? DateTime.now()),
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
                        controller: TextEditingController(
                            text: _editEndDateTime != null
                                ? '${_editEndDateTime!.day}/${_editEndDateTime!.month}/${_editEndDateTime!.year}, ${_editEndDateTime!.hour.toString().padLeft(2, '0')}:${_editEndDateTime!.minute.toString().padLeft(2, '0')}'
                                : ''),
                        hintText: 'End Date, Time',
                        readOnly: true,
                        onTap: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: _editEndDateTime ?? DateTime.now(),
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 365)),
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
                              initialTime: TimeOfDay.fromDateTime(
                                  _editEndDateTime ?? DateTime.now()),
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
                  MaterialPageRoute(
                      builder: (_) => EditEventScreen(event: widget.event)),
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
              _bannerImg,
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
                  child:
                      const Icon(Icons.image, color: hintTextColor, size: 60),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Event Title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column: two texts stacked vertically
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayName,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${widget.event.organizer}',
                      style: const TextStyle(
                        color: hintTextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      _buildSocialAssetIcon('assets/facebook_icon.png', () {}),
                      const SizedBox(width: 12),
                      _buildSocialAssetIcon(
                          'assets/Instagram _icon.png', () {}),
                    ],
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Event Details Cards
          _buildInfoCard(
            icon: Icons.calendar_today,
            text: _formatEventDate(_startDateStr),
          ),
          const SizedBox(height: 12),
          _buildInfoCard(
            icon: Icons.access_time,
            text: _formatEventTime(_startDateStr),
          ),
          const SizedBox(height: 12),
          _buildLocationCard(
            icon: Icons.location_on,
            title: _venueName,
            subtitle: '$_subType Event',
            hasNavigate: true,
            locationUrl: _venueLocationUrl,
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
            CustomTextField(
                controller: _nameController, hintText: 'Event Name'),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _venueType,
                  hint: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Venue Type',
                        style: TextStyle(color: hintTextColor)),
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
                        child: Text(item,
                            style: const TextStyle(color: textColor)),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _venueType = v),
                ),
              ),
            ),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _trailerController,
                hintText: 'Event Trailer Video link'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _descriptionController,
                hintText: 'Event Description On The Website',
                maxLines: 4),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _instagramController,
                hintText: 'Event Instagram Page Link'),
            const SizedBox(height: 12),
            CustomTextField(
                controller: _facebookController,
                hintText: 'Event Facebook Page Link'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: _submitEventUpdate,
                child: const Text('Update Event Details',
                    style: TextStyle(
                        color: textColor, fontWeight: FontWeight.bold)),
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
          // Display ticket packages from basic finance
          ..._packages.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTicketPackageCard(
                  tier: p['name']?.toString() ?? '-',
                  price:
                      '${widget.event.currency} ${double.tryParse(p['price']?.toString() ?? '0')?.toStringAsFixed(0) ?? '0'}',
                  releaseCount: (p['tot_tickets'] as int).toString(),
                  dateTime: '',
                  status: (p['sold_out'] == true)
                      ? 'Sold Out'
                      : ((p['active'] == true) ? 'Available' : 'Not Available'),
                ),
              )),

          const SizedBox(height: 24),
        ],
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
    String? locationUrl,
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
          if (hasNavigate && locationUrl != null && locationUrl.isNotEmpty)
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(locationUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
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
        Row(
          children: [
            const Text(
              'Event Starts in',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Use Expanded so the countdown row takes the remaining space and
            // never forces a fixed width (prevents RenderFlex overflow).
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildTimeBox('${days}d'),
                  const SizedBox(width: 6),
                  const Text(':',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  _buildTimeBox('${hours}h'),
                  const SizedBox(width: 6),
                  const Text(':',
                      style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(width: 6),
                  _buildTimeBox('${minutes}m'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeBox(String time) {
    // Styled to match the "Inactive" chip used elsewhere (dark rounded chip with gray text)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        time,
        style: const TextStyle(
          color: Color.fromARGB(255, 255, 255, 255),
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    final description = _parseDescription(widget.event.description);
    final shortDescription = description.length > 250
        ? '${description.substring(0, 250)}...'
        : description;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shortDescription,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          if (description.length > 250) ...[
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
            color: const Color(0xFF9E9E9E).withValues(alpha: 0.2),
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
            child: const Icon(Icons.confirmation_number,
                color: primaryColor, size: 20),
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
                      icon:
                          const Icon(Icons.edit, size: 14, color: primaryColor),
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

Widget _buildSocialAssetIcon(String assetPath, VoidCallback onTap,
    {double iconSize = 18}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Image.asset(
        assetPath,
        width: iconSize,
        height: iconSize,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.image_not_supported,
              color: textColor, size: iconSize);
        },
      ),
    ),
  );
}
