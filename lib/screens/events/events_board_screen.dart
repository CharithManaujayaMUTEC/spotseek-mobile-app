import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/screens/events/add_event_screen.dart';
import 'package:spotseeker_app/screens/events/event_detail_screen.dart';
import 'package:spotseeker_app/screens/events/profile_settings_screen.dart';
import 'package:spotseeker_app/services/event_service.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:intl/intl.dart';

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
  bool _isLoadingMore = false;

  // Pagination variables
  int _currentPage = 0;
  int _limit = 10;
  int _totalEvents = 0;
  bool _hasMoreData = true;

  final ScrollController _scrollController = ScrollController();

  final List<String> _filterOptions = [
    'All Events',
    'Active Events',
    'Inactive Events',
    'Pending Approval',
    'Resolve Issues',
  ];

  @override
  void initState() {
    super.initState();
    _loadEvents();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      if (!_isLoadingMore && _hasMoreData) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
      _currentPage = 0;
      _allEvents = [];
      _filteredEvents = [];
    });

    final response = await EventService.loadEventsWithPagination(
      page: _currentPage,
      limit: _limit,
    );

    setState(() {
      _allEvents = response.events;
      _totalEvents = response.total;
      _hasMoreData = _allEvents.length < _totalEvents;
      _filteredEvents = _allEvents;
      _isLoading = false;
    });

    _applyCurrentFilter();
  }

  Future<void> _loadMoreEvents() async {
    if (_isLoadingMore || !_hasMoreData) return;

    setState(() => _isLoadingMore = true);

    final nextPage = _currentPage + 1;
    final response = await EventService.loadEventsWithPagination(
      page: nextPage,
      limit: _limit,
    );

    setState(() {
      _currentPage = nextPage;
      _allEvents.addAll(response.events);
      _totalEvents = response.total;
      _hasMoreData = _allEvents.length < _totalEvents;
      _isLoadingMore = false;
    });

    _applyCurrentFilter();
  }

  void _filterEvents(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    setState(() {
      _filteredEvents =
          EventService.filterEventsByCategory(_allEvents, _selectedFilter);
    });
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending Approval':
        return const Color(0xFFFFC107);
      case 'Fix Issues':
        return const Color(0xFFE50914);
      case 'Active':
        return const Color(0xFF28A745);
      case 'Inactive':
        return const Color(0xFFFFFFFF).withOpacity(0.1);
      default:
        return const Color(0xFFFFFFFF).withOpacity(0.1);
    }
  }

  Color _getDateBadgeColor(String status) {
    final normalized = status.trim().toLowerCase();
    return normalized == 'inactive'
        ? const Color(0xFF95070D) // Dark red for Inactive
        : const Color(0xFFE50914); // Bright red for everything else
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth =
        (screenWidth - 48 - 12) / 2; // 24 padding left/right, 12 cross spacing
    const double maxTextHeight =
        87.0; // Slightly increased max text height estimation to accommodate increased gap without causing overflow
    const double additionalPadding =
        12.0; // Image top padding 6 + image bottom padding 0 + text bottom padding 6
    final double requiredHeight = cardWidth + maxTextHeight + additionalPadding;
    final double aspectRatio = cardWidth / requiredHeight;

    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadEvents,
            color: primaryColor,
            child: CustomScrollView(
              controller:
                  _scrollController, // <-- same controller for pagination
              slivers: [
                // ── HEADER ───────────────────────────────────────
                SliverToBoxAdapter(child: _buildHeader()),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                // ── BANNER ───────────────────────────────────────
                SliverToBoxAdapter(child: _buildBanner()),
                const SliverToBoxAdapter(child: SizedBox(height: 30)),

                // ── TITLE ────────────────────────────────────────
                const SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Our Valuable Partnerships',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── FILTER CHIPS ─────────────────────────────────
                SliverToBoxAdapter(child: _buildFilterChips()),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),

                // ── GRID (or empty / loading) ───────────────────
                _isLoading
                    ? const SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                            child:
                                CircularProgressIndicator(color: primaryColor)),
                      )
                    : _filteredEvents.isEmpty
                        ? SliverFillRemaining(
                            hasScrollBody: false,
                            child: _selectedFilter == 'All Events'
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24.0),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    left: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                        0.05,
                                                    top: 10.0,
                                                  ),
                                                  child: const Text(
                                                    'Let\'s Create your \nFirst Event!',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 255, 255, 255),
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.12,
                                                  right: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.03,
                                                ),
                                                child: Transform.rotate(
                                                  angle: 0.2,
                                                  child: Image.asset(
                                                    'assets/arrow_icon_1.png',
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.15,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.fromLTRB(
                              24.0,
                              8.0,
                              24.0,
                              MediaQuery.of(context).padding.bottom + 80.0,
                            ),
                            sliver: SliverGrid(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: aspectRatio,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  if (index == _filteredEvents.length) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(
                                            color: primaryColor),
                                      ),
                                    );
                                  }
                                  return _buildEventCard(
                                      _filteredEvents[index]);
                                },
                                childCount: _filteredEvents.length +
                                    (_isLoadingMore ? 1 : 0),
                              ),
                            ),
                          ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEventScreen()),
          );
          if (result == true) _loadEvents();
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
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

          // Notifications button + Profile Picture (tappable -> ProfileSettingsScreen)
          Row(
            children: [
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
    // Show all filter chips
    return Container(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: _filterOptions.length,
        itemBuilder: (context, index) {
          final filter = _filterOptions[index];
          final isSelected = _selectedFilter == filter;
          final isResolveIssues = filter == 'Resolve Issues';

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(filter),
                  if (isResolveIssues)
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Icon(
                        Icons.error,
                        color: isSelected
                            ? backgroundColor
                            : const Color(0xFFE50914),
                        size: 16,
                      ),
                    ),
                ],
              ),
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
                color: isSelected
                    ? textColor
                    : hintTextColor.withValues(alpha: 0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24.0),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventCard(EventModel event) {
    final dateTime = DateTime.parse(event.date);
    final month = DateFormat('MMM').format(dateTime);
    final day = DateFormat('dd').format(dateTime);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => EventDetailScreen(event: event)),
      ),
      child: Container(
        // ---- outer border of the card ----
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: hintTextColor.withValues(alpha: 0.2)),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ────────────────────── IMAGE ──────────────────────
            Padding(
              padding: const EdgeInsets.only(
                  left: 6.0,
                  right: 6.0,
                  top: 6.0,
                  bottom:
                      0.0), // Reduced gap between image and text section by setting bottom padding to 0
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // ---- the image ----
                      Image.network(
                        event.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: hintTextColor.withValues(alpha: 0.2),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image,
                              color: hintTextColor, size: 40),
                        ),
                      ),

                      // ---- Featured badge ----
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: textColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/star.png',
                                  width: 12, height: 12),
                              const SizedBox(width: 4),
                              const Text('Featured',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),

                      // ---- Date badge ----
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 0),
                          decoration: BoxDecoration(
                            color: _getDateBadgeColor(event.status),
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(8),
                              bottomLeft: Radius.circular(8),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(month,
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                              Text(day,
                                  style: const TextStyle(
                                      color: textColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ────────────────────── TEXT SECTION ──────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6.0, 0.0, 6.0, 6.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(event.status),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        event.status,
                        style: const TextStyle(
                            color: textColor,
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(
                        height:
                            10), // Increased spacing between status badge and event name slightly for better readability
                    Text(
                      event.name,
                      style: const TextStyle(
                          color: textColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                        height:
                            4), // Reduced spacing to make overall text section more compact
                    Text(
                      '${event.startTime} - ${event.endTime}',
                      style: TextStyle(
                          color: hintTextColor.withValues(alpha: 0.8),
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(
                        height:
                            2), // Reduced spacing to make overall text section more compact
                    Text(
                      event.venue,
                      style: TextStyle(
                          color: hintTextColor.withValues(alpha: 0.8),
                          fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
