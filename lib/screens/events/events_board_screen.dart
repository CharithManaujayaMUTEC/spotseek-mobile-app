import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/screens/events/add_event_screen.dart';
import 'package:spotseeker_app/screens/events/event_detail_screen.dart';
import 'package:spotseeker_app/services/event_service.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

class EventsBoardScreen extends StatefulWidget {
  const EventsBoardScreen({super.key});

  @override
  State<EventsBoardScreen> createState() => _EventsBoardScreenState();
}

class _EventsBoardScreenState extends State<EventsBoardScreen> {
  List<EventModel> _allEvents = [];
  List<EventModel> _filteredEvents = [];
  String _selectedFilter = 'All Events';
  bool _isLoading = true;

  final List<String> _filterOptions = [
    'All Events',
    'Active Events',
    'Inactive Events',
    'Pending Approval',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() => _isLoading = true);
    final events = await EventService.loadEvents();
    setState(() {
      _allEvents = events;
      _filteredEvents = events;
      _isLoading = false;
    });
  }

  void _filterEvents(String filter) {
    setState(() {
      _selectedFilter = filter;
      _filteredEvents = EventService.filterEventsByCategory(_allEvents, filter);
    });
  }

  Color _getStatusColor(String statusType) {
    switch (statusType) {
      case 'error':
        return primaryColor;
      case 'warning':
        return const Color(0xFFFFA500);
      case 'success':
        return const Color(0xFF00FF00);
      default:
        return Colors.grey;
    }
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
              
              // Banner
              _buildBanner(),
              
              // Events Board Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Events Board',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Filter Chips
              _buildFilterChips(),
              
              // Events Grid
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: primaryColor))
                    : _filteredEvents.isEmpty
                        ? const Center(
                            child: Text(
                              'No events found',
                              style: TextStyle(color: hintTextColor, fontSize: 16),
                            ),
                          )
                        : _buildEventsGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEventScreen()),
          );
        },
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: textColor, size: 32),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo
          Row(
            children: [
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
            ],
          ),
          
          // Profile Picture
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
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/events-board-banner.png',
          height: 180,
          fit: BoxFit.cover,
          semanticLabel: 'Events board banner',
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

  Widget _buildFilterChips() {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) _filterEvents(filter);
              },
              backgroundColor: backgroundColor.withValues(alpha: 0.5),
              selectedColor: textColor,
              labelStyle: TextStyle(
                color: isSelected ? backgroundColor : textColor,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: BorderSide(
                color: isSelected ? textColor : hintTextColor.withValues(alpha: 0.3),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventsGrid() {
    // Add extra bottom padding that accounts for the device's bottom inset
    // (navigation bar / safe area). This prevents tiny fractional pixel
    // overflows that may appear on some devices (e.g. "Bottom overflowed by
    // 0.182 pixels").
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        24.0,
        8.0,
        24.0,
        MediaQuery.of(context).padding.bottom + 16.0,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: _filteredEvents.length,
      itemBuilder: (context, index) {
        final event = _filteredEvents[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hintTextColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image with Date Badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    event.imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 120,
                        color: hintTextColor.withValues(alpha: 0.2),
                        child: const Icon(Icons.image, color: hintTextColor, size: 40),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.date,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(event.statusType),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      event.status,
                      style: const TextStyle(
                        color: backgroundColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Event Details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: const TextStyle(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${event.startTime} - ${event.endTime}',
                    style: TextStyle(
                      color: hintTextColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.venue,
                    style: TextStyle(
                      color: hintTextColor.withValues(alpha: 0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
