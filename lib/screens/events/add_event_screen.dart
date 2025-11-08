import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';
import 'package:spotseeker_app/screens/events/profile_settings_screen.dart';
import 'package:spotseeker_app/services/event_service.dart';
import 'package:spotseeker_app/core/storage/secure_storage.dart';
import 'package:dio/dio.dart';
import 'package:spotseeker_app/core/constants/api_constants.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _secureStorage = SecureStorage();
  final _imagePicker = ImagePicker();

  // Form Controllers
  final _eventNameController = TextEditingController();
  final _eventTrailerVideoController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventVenueController = TextEditingController();
  final _eventGoogleMapController = TextEditingController();
  final _eventInstagramController = TextEditingController();
  final _eventFacebookController = TextEditingController();
  final _eventOrganizerController = TextEditingController();

  String? _selectedEventType;
  String? _selectedEventCategory;
  int? _selectedVenueId;
  DateTime? _eventStartDate;
  TimeOfDay? _eventStartTime;
  DateTime? _eventEndDate;
  TimeOfDay? _eventEndTime;
  TimeOfDay? _ticketCounterTime;
  String? _selectedKokoPayment;

  File? _bannerImage;
  File? _thumbnailImage;
  File? _flyerFile;
  String? _flyerFileName;
  bool _isSubmitting = false;
  bool _venuesLoading = false;
  String? _venuesError;
  List<_Venue> _venues = [];

  final List<TicketPackage> _ticketPackages = [];

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventTrailerVideoController.dispose();
    _eventDescriptionController.dispose();
    _eventVenueController.dispose();
    _eventGoogleMapController.dispose();
    _eventInstagramController.dispose();
    _eventFacebookController.dispose();
    _eventOrganizerController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    setState(() {
      _venuesLoading = true;
      _venuesError = null;
    });
    try {
      final dio = Dio(BaseOptions(baseUrl: ApiConstants.mobileApiBaseUrl));
      final resp = await dio.get(
        '${ApiConstants.legacyWebApiBaseUrl}/api/venues',
        options: Options(headers: {
          'Accept': 'application/json',
          'Authorization':
              'Bearer 2125|DUGxJh0EckMKLZogFmBQkv4JGWkpIchf8J6j5PcJf4965c35',
        }),
      );
      final data = resp.data;
      final List list = (data is Map && data['data'] is List)
          ? (data['data'] as List)
          : (data is List ? data : []);
      final parsed = list.map<_Venue>((e) {
        final m = Map<String, dynamic>.from(e as Map);
        return _Venue(
            id: (m['id'] as num).toInt(), name: (m['name'] ?? '').toString());
      }).toList();
      if (mounted) {
        setState(() {
          _venues = parsed;
          _venuesLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _venuesError = 'Failed to load venues';
          _venuesLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage(bool isBanner) async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          if (isBanner) {
            _bannerImage = File(pickedFile.path);
          } else {
            _thumbnailImage = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickFlyerFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _flyerFile = File(result.files.single.path!);
          _flyerFileName = result.files.single.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildVenueDropdown() {
    if (_venuesLoading) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
        ),
        child: const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: textColor,
          ),
        ),
      );
    }

    if (_venuesError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: const Text(
              'Failed to load venues',
              style: TextStyle(color: hintTextColor, fontSize: 14),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _fetchVenues,
              child: const Text('Retry'),
            ),
          )
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedVenueId,
          hint: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('Event Venue', style: TextStyle(color: hintTextColor)),
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          icon: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.keyboard_arrow_down, color: textColor),
          ),
          items: _venues
              .map((v) => DropdownMenuItem<int>(
                    value: v.id,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(v.name,
                          style: const TextStyle(color: textColor)),
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedVenueId = value),
        ),
      ),
    );
  }

  Future<void> _submitEvent() async {
    // Graceful defaults for times: if date is picked but time is not, default to 00:00
    if (_eventStartDate != null && _eventStartTime == null) {
      _eventStartTime = const TimeOfDay(hour: 0, minute: 0);
    }
    if (_eventEndDate != null && _eventEndTime == null) {
      _eventEndTime = const TimeOfDay(hour: 0, minute: 0);
    }

    // Validate and show precise feedback
    final List<String> missing = [];
    if (_eventNameController.text.trim().isEmpty) missing.add('Event Name');
    if (_selectedEventType == null) missing.add('Event Type');
    if (_selectedVenueId == null) missing.add('Event Venue');
    if (_eventStartDate == null) missing.add('Start Date');
    if (_eventStartTime == null) missing.add('Start Time');
    if (_eventEndDate == null) missing.add('End Date');
    if (_eventEndTime == null) missing.add('End Time');
    if (_ticketPackages.isEmpty) missing.add('At least one Ticket Package');

    if (missing.isNotEmpty) {
      final msg = 'Please complete: ' + missing.join(', ');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Get user ID from secure storage
      final userId = await _secureStorage.read('user_id') ?? '1';

      // Format dates to match backend format: "YYYY-MM-DD HH:mm"
      final startDateTime = DateTime(
        _eventStartDate!.year,
        _eventStartDate!.month,
        _eventStartDate!.day,
        _eventStartTime!.hour,
        _eventStartTime!.minute,
      );

      final endDateTime = DateTime(
        _eventEndDate!.year,
        _eventEndDate!.month,
        _eventEndDate!.day,
        _eventEndTime!.hour,
        _eventEndTime!.minute,
      );

      final startDateStr =
          '${startDateTime.year}-${startDateTime.month.toString().padLeft(2, '0')}-${startDateTime.day.toString().padLeft(2, '0')} ${startDateTime.hour.toString().padLeft(2, '0')}:${startDateTime.minute.toString().padLeft(2, '0')}';
      final endDateStr =
          '${endDateTime.year}-${endDateTime.month.toString().padLeft(2, '0')}-${endDateTime.day.toString().padLeft(2, '0')} ${endDateTime.hour.toString().padLeft(2, '0')}:${endDateTime.minute.toString().padLeft(2, '0')}';

      // Create invoice JSON from ticket packages
      final invoiceList = _ticketPackages.map((pkg) {
        return {
          'packageName': pkg.name,
          'packageDesc': '',
          'packagePrice': pkg.price,
          'packageQty': pkg.count,
          'packageAvailQty': pkg.count,
          'packageResQty': '0',
          'packageAllocSeats': '',
          'packageAvailSeats': '',
          'packageFreeSeating': true,
          'sold_out': false,
          'promotions': false,
          'promotion': [
            {
              'promoCode': '',
              'discAmount': '',
              'discAmtIsPercentage': true,
              'isPerTicket': false,
              'minTickets': '',
              'minAmount': '',
              'maxTickets': '',
              'maxAmount': '',
              'startDateTime': '',
              'endDateTime': '',
              'isAutoApply': false,
              'redeems': '',
            }
          ],
          'active': true,
          'deleted': false,
          'maxBuyTickets': 0,
        };
      }).toList();

      // Create description in Draft.js format
      final description = {
        'blocks': [
          {
            'key': '1sgva',
            'text': _eventDescriptionController.text.isNotEmpty
                ? _eventDescriptionController.text
                : 'Event description',
            'type': 'unstyled',
            'depth': 0,
            'inlineStyleRanges': [],
            'entityRanges': [],
            'data': {}
          }
        ],
        'entityMap': {}
      };

      // Payment gateways (you can make this dynamic later)
      final paymentGateways = [
        {
          'id': '',
          'name': '',
          'commission_rate': 0,
          'apply_handling_fee': true,
          'deleted': false
        }
      ];

      final response = await EventService.createEvent(
        name: _eventNameController.text,
        description: jsonEncode(description),
        organizer: _eventOrganizerController.text.isEmpty
            ? 'Event Organizer'
            : _eventOrganizerController.text,
        manager: userId,
        startDate: startDateStr,
        endDate: endDateStr,
        type: _selectedEventType!.toLowerCase(),
        subType: _selectedEventCategory?.toLowerCase() ?? 'general',
        featured: false,
        freeSeating: true,
        venue: (_selectedVenueId ?? 0).toString(),
        invoice: jsonEncode(invoiceList),
        bannerImgPath: _bannerImage?.path,
        thumbnailImgPath: _thumbnailImage?.path,
        soldOutMsg: '',
        handlingCost: '',
        handlingCostPerc: false,
        currency: 'LKR',
        invitationFeature: false,
        invitationCount: '',
        invitationPackages: jsonEncode([
          {
            'packageName': '',
            'packageDesc': '',
            'packageQty': '',
            'packageAvailQty': '',
            'packageSoldQty': '',
            'packageAllocSeats': '',
            'active': true,
            'deleted': false,
            'packageFreeSeating': true
          }
        ]),
        addonsFeature: false,
        addons: jsonEncode([
          {
            'addonName': '',
            'addonCategory': '',
            'addonPrice': '',
            'deleted': false
          }
        ]),
        trailerUrl: _eventTrailerVideoController.text.isNotEmpty
            ? _eventTrailerVideoController.text
            : '',
        paymentGateways: jsonEncode(paymentGateways),
        analyticsIds: '[]',
      );

      print('Event created successfully: ${response['message']}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: primaryColor,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
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
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _eventStartDate = picked;
        } else {
          _eventEndDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, String timeType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
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
    if (picked != null) {
      setState(() {
        if (timeType == 'start') {
          _eventStartTime = picked;
        } else if (timeType == 'end') {
          _eventEndTime = picked;
        } else if (timeType == 'counter') {
          _ticketCounterTime = picked;
        }
      });
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
              // Limit dialog width on wide screens and ensure it can shrink on small screens
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
                            if (nameController.text.isNotEmpty &&
                                priceController.text.isNotEmpty &&
                                countController.text.isNotEmpty) {
                              setState(() {
                                _ticketPackages.add(TicketPackage(
                                  name: nameController.text,
                                  price: priceController.text,
                                  count: countController.text,
                                ));
                              });
                              Navigator.pop(context);
                            }
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
    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Banner
                        _buildBanner(),

                        const SizedBox(height: 24),

                        // Event Details Section
                        const Text(
                          'Event Details',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventNameController,
                          hintText: 'Event Name',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventOrganizerController,
                          hintText: 'Organizer Name',
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          hint: 'Event Type',
                          value: _selectedEventType,
                          items: [
                            'Concert',
                            'Conference',
                            'Workshop',
                            'Festival',
                            'Meetup',
                            'Sport'
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedEventType = value),
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          hint: 'Event Category',
                          value: _selectedEventCategory,
                          items: [
                            'Music',
                            'Technology',
                            'Art',
                            'Sports',
                            'Food',
                            'Business'
                          ],
                          onChanged: (value) =>
                              setState(() => _selectedEventCategory = value),
                        ),
                        const SizedBox(height: 16),

                        // File Upload Section
                        _buildFileUploadSection(),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventTrailerVideoController,
                          hintText: 'Event Trailer Video link',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventDescriptionController,
                          hintText: 'Event Description On The Website',
                          maxLines: 4,
                        ),
                        const SizedBox(height: 16),

                        // Date and Time Fields
                        _buildDateTimeField(
                          label: 'Event Start Date & Time',
                          date: _eventStartDate,
                          time: _eventStartTime,
                          onTapDate: () => _selectDate(context, true),
                          onTapTime: () => _selectTime(context, 'start'),
                        ),
                        const SizedBox(height: 16),

                        _buildDateTimeField(
                          label: 'Event End Date & Time',
                          date: _eventEndDate,
                          time: _eventEndTime,
                          onTapDate: () => _selectDate(context, false),
                          onTapTime: () => _selectTime(context, 'end'),
                        ),
                        const SizedBox(height: 16),

                        _buildTimeField(
                          label: 'Ticket Counter Operation - Start time',
                          time: _ticketCounterTime,
                          onTap: () => _selectTime(context, 'counter'),
                        ),
                        const SizedBox(height: 16),

                        _buildVenueDropdown(),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventGoogleMapController,
                          hintText: 'Event Venue Google Map Link',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventInstagramController,
                          hintText: 'Event Instagram Page Link',
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          controller: _eventFacebookController,
                          hintText: 'Event Facebook Page Link',
                        ),
                        const SizedBox(height: 24),

                        // Ticket Packages Section
                        const Text(
                          'Ticket Packages',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildAddTicketPackageButton(),
                        const SizedBox(height: 16),

                        // Display Added Ticket Packages
                        ..._ticketPackages
                            .map((package) => _buildTicketPackageCard(package)),

                        const SizedBox(height: 24),

                        // Koko Payment Section
                        const Text(
                          'Enable Koko Payment',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildDropdown(
                          hint: 'Would you like to add Koko',
                          value: _selectedKokoPayment,
                          items: ['Yes', 'No'],
                          onChanged: (value) =>
                              setState(() => _selectedKokoPayment = value),
                        ),
                        const SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              disabledBackgroundColor:
                                  primaryColor.withValues(alpha: 0.5),
                            ),
                            onPressed: _isSubmitting ? null : _submitEvent,
                            child: _isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: textColor,
                                    ),
                                  )
                                : const Text(
                                    'Add New Event',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: textColor),
          ),
          const SizedBox(width: 8),
          RichText(
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'SPOTSEEKER\n',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                TextSpan(
                  text: 'Copilot',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: navigate to notifications screen
                },
                child: SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: ShapeDecoration(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                width: 1,
                                color: Colors.white.withOpacity(0.30),
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const Positioned(
                        left: 13,
                        top: 13,
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 26,
                        top: 17,
                        child: Container(
                          width: 8.67,
                          height: 8.67,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment(0.00, 0.50),
                              end: Alignment(1.00, 0.50),
                              colors: [Color(0xFFF857A6), Color(0xFFFF5858)],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color(0xFF0B0417), width: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileSettingsScreen(),
                    ),
                  );
                },
                child: const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 26.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/add-event-banner.png',
          height: 180,
          fit: BoxFit.cover,
          semanticLabel: 'Add Event Banner',
          errorBuilder: (context, error, stackTrace) => Container(
            height: 180,
            color: hintTextColor.withValues(alpha: 0.08),
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image, color: hintTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              hint,
              style: const TextStyle(color: hintTextColor),
            ),
          ),
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A2E),
          icon: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.keyboard_arrow_down, color: textColor),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  item,
                  style: const TextStyle(color: textColor),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFileUploadSection() {
    return Column(
      children: [
        // Banner Image Upload
        GestureDetector(
          onTap: () => _pickImage(true),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _bannerImage != null
                      ? 'Banner Image Selected ✓'
                      : 'Upload Banner Image (1000px*1000px)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _bannerImage != null ? primaryColor : textColor,
                    fontSize: 14,
                    fontWeight: _bannerImage != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  _bannerImage != null
                      ? Icons.check_circle
                      : Icons.cloud_upload_outlined,
                  color: _bannerImage != null ? primaryColor : hintTextColor,
                  size: 40,
                ),
                if (_bannerImage == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select banner image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: hintTextColor.withValues(alpha: 0.7),
                        fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Thumbnail Image Upload
        GestureDetector(
          onTap: () => _pickImage(false),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _thumbnailImage != null
                      ? 'Thumbnail Image Selected ✓'
                      : 'Upload Thumbnail Image (1000px*1000px)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _thumbnailImage != null ? primaryColor : textColor,
                    fontSize: 14,
                    fontWeight: _thumbnailImage != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 12),
                Icon(
                  _thumbnailImage != null
                      ? Icons.check_circle
                      : Icons.cloud_upload_outlined,
                  color: _thumbnailImage != null ? primaryColor : hintTextColor,
                  size: 40,
                ),
                if (_thumbnailImage == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select thumbnail image',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: hintTextColor.withValues(alpha: 0.7),
                        fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Event Flyer Upload
        GestureDetector(
          onTap: _pickFlyerFile,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _flyerFile != null
                      ? 'Event Flyer Selected ✓'
                      : 'Upload Event Flyer (PDF/Image)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _flyerFile != null ? primaryColor : textColor,
                    fontSize: 14,
                    fontWeight: _flyerFile != null
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                if (_flyerFileName != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _flyerFileName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: hintTextColor.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Icon(
                  _flyerFile != null
                      ? Icons.check_circle
                      : Icons.upload_file_outlined,
                  color: _flyerFile != null ? primaryColor : hintTextColor,
                  size: 40,
                ),
                if (_flyerFile == null) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select flyer file (PDF, JPG, PNG)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: hintTextColor.withValues(alpha: 0.7),
                        fontSize: 11),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onTapDate,
    required VoidCallback onTapTime,
  }) {
    String dateText =
        date != null ? '${date.day}/${date.month}/${date.year}' : label;

    return GestureDetector(
      onTap: onTapDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              dateText,
              style: TextStyle(
                color: date != null ? textColor : hintTextColor,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.calendar_today, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    String timeText = time != null
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : label;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeText,
              style: TextStyle(
                color: time != null ? textColor : hintTextColor,
                fontSize: 14,
              ),
            ),
            const Icon(Icons.access_time, color: textColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAddTicketPackageButton() {
    return GestureDetector(
      onTap: _showAddTicketPackageDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add, color: textColor),
            SizedBox(width: 8),
            Text(
              'Add New Ticket Packages',
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketPackageCard(TicketPackage package) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Package Name',
                style: TextStyle(color: hintTextColor, fontSize: 12),
              ),
              Text(
                package.name,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ticket Price',
                style: TextStyle(color: hintTextColor, fontSize: 12),
              ),
              Text(
                package.price,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ticket Release Count',
                style: TextStyle(color: hintTextColor, fontSize: 12),
              ),
              Text(
                package.count,
                style: const TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Venue {
  final int id;
  final String name;
  _Venue({required this.id, required this.name});
}

class TicketPackage {
  final String name;
  final String price;
  final String count;

  TicketPackage({
    required this.name,
    required this.price,
    required this.count,
  });
}
