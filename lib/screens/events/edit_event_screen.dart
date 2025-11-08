import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class EditEventScreen extends StatefulWidget {
  final EventModel event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  late TextEditingController _nameController;
  late TextEditingController _venueController;
  late TextEditingController _trailerController;
  late TextEditingController _descriptionController;
  late TextEditingController _instagramController;
  late TextEditingController _facebookController;
  String _venueType = 'Outdoor';
  late String _imageUrl;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.event.name);
    _venueController = TextEditingController(text: widget.event.venue);
    _trailerController = TextEditingController();
    _descriptionController = TextEditingController();
    _instagramController = TextEditingController();
    _facebookController = TextEditingController();
    _imageUrl = widget.event.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    _trailerController.dispose();
    _descriptionController.dispose();
    _instagramController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  void _showImageUrlDialog() {
    final ctrl = TextEditingController(text: _imageUrl);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Update Banner Image', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            CustomTextField(controller: ctrl, hintText: 'Image URL'),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                  onPressed: () {
                    setState(() => _imageUrl = ctrl.text);
                    Navigator.pop(context);
                  },
                  child: const Text('Save', style: TextStyle(color: textColor)),
                ),
              ),
            ])
          ]),
        ),
      ),
    );
  }

  void _onSave() {
    final updated = EventModel(
      id: widget.event.id,
      uid: widget.event.uid,
      name: _nameController.text,
      description: widget.event.description,
      type: widget.event.type,
      subType: _venueType,
      organizer: widget.event.organizer,
      managerName: widget.event.managerName,
      startDate: widget.event.startDate,
      endDate: widget.event.endDate,
      status: widget.event.status,
      thumbnailImg: _imageUrl,
      bannerImg: widget.event.bannerImg,
      featured: widget.event.featured,
      venueName: _venueController.text,
      venueLocationUrl: widget.event.venueLocationUrl,
      freeSeating: widget.event.freeSeating,
      currency: widget.event.currency,
      ticketPackages: widget.event.ticketPackages,
    );
    Navigator.pop(context, updated);
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: textColor)),
                  const SizedBox(width: 8),
                  const Text('Edit Event', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                ]),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Banner with edit
                    Stack(children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _imageUrl,
                          width: double.infinity,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(height: 220, color: hintTextColor.withValues(alpha: 0.12), alignment: Alignment.center, child: const Icon(Icons.image, color: hintTextColor, size: 48)),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: GestureDetector(
                          onTap: _showImageUrlDialog,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.edit, color: textColor),
                          ),
                        ),
                      ),
                    ]),

                    const SizedBox(height: 20),
                    const Text('Event Details', style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    CustomTextField(controller: _nameController, hintText: 'Summer Beats Festival'),
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
                          isExpanded: true,
                          dropdownColor: const Color(0xFF1A1A2E),
                          icon: const Padding(padding: EdgeInsets.only(right: 16.0), child: Icon(Icons.keyboard_arrow_down, color: textColor)),
                          items: ['Outdoor', 'Indoor', 'Virtual'].map((e) => DropdownMenuItem(value: e, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(e, style: const TextStyle(color: textColor))))).toList(),
                          onChanged: (v) => setState(() => _venueType = v ?? _venueType),
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

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: _onSave,
                        child: const Text('Update Event Details', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
