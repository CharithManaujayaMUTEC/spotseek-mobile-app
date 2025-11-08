import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({super.key});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  
  // Form Controllers
  final _eventNameController = TextEditingController();
  final _eventTrailerVideoController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventVenueController = TextEditingController();
  final _eventGoogleMapController = TextEditingController();
  final _eventInstagramController = TextEditingController();
  final _eventFacebookController = TextEditingController();
  
  String? _selectedEventType;
  String? _selectedEventCategory;
  DateTime? _eventStartDate;
  TimeOfDay? _eventStartTime;
  DateTime? _eventEndDate;
  TimeOfDay? _eventEndTime;
  TimeOfDay? _ticketCounterTime;
  String? _selectedKokoPayment;
  
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
    _scrollController.dispose();
    super.dispose();
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                        
                        _buildDropdown(
                          hint: 'Event Type',
                          value: _selectedEventType,
                          items: ['Concert', 'Conference', 'Workshop', 'Festival', 'Meetup'],
                          onChanged: (value) => setState(() => _selectedEventType = value),
                        ),
                        const SizedBox(height: 16),
                        
                        _buildDropdown(
                          hint: 'Event Category',
                          value: _selectedEventCategory,
                          items: ['Music', 'Technology', 'Art', 'Sports', 'Food', 'Business'],
                          onChanged: (value) => setState(() => _selectedEventCategory = value),
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
                        
                        CustomTextField(
                          controller: _eventVenueController,
                          hintText: 'Event Venue Name',
                        ),
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
                        ..._ticketPackages.map((package) => _buildTicketPackageCard(package)),
                        
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
                          onChanged: (value) => setState(() => _selectedKokoPayment = value),
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
                            ),
                            onPressed: () {
                              // TODO: Implement form submission
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Event added successfully!'),
                                  backgroundColor: primaryColor,
                                ),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text(
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
          const CircleAvatar(
            radius: 24,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100',
            ),
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
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Event Flyer Size (1000px*1000px)',
            textAlign: TextAlign.center,
            style: TextStyle(color: textColor, fontSize: 14),
          ),
          const SizedBox(height: 12),
          const Icon(Icons.cloud_upload_outlined, color: hintTextColor, size: 40),
          const SizedBox(height: 12),
          Text(
            'Upload up to 5 supported files: PDF, doc, image,',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintTextColor.withValues(alpha: 0.7), fontSize: 11),
          ),
          Text(
            'or image. Max 100 MB per file.',
            textAlign: TextAlign.center,
            style: TextStyle(color: hintTextColor.withValues(alpha: 0.7), fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? date,
    required TimeOfDay? time,
    required VoidCallback onTapDate,
    required VoidCallback onTapTime,
  }) {
    String dateText = date != null
        ? '${date.day}/${date.month}/${date.year}'
        : label;
    
    return GestureDetector(
      onTap: onTapDate,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
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
          border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
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
          border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
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
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
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
