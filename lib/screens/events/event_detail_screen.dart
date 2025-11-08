import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/screens/events/dashboard_tabs/overview_tab.dart';
import 'package:spotseeker_app/screens/events/dashboard_tabs/event_preview_tab.dart';
import 'package:spotseeker_app/screens/events/dashboard_tabs/live_stats_tab.dart';
import 'package:spotseeker_app/screens/events/finance_tabs/finance_tab.dart';
import 'package:spotseeker_app/screens/events/qr_tabs/qr_scanner_screen.dart';
import 'package:spotseeker_app/screens/events/profile_settings_screen.dart';
import 'package:spotseeker_app/screens/events/marketing_tabs/marketing_tab_screen.dart';
import 'package:spotseeker_app/screens/events/services_tabs/services_tab.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with TickerProviderStateMixin {
  late TabController _dashboardTabController;
  late TabController _marketingTabController;
  int _selectedDashboardTabIndex = 0;
  int _selectedMarketingTabIndex = 0;
  int _selectedBottomNavIndex = 0;

  @override
  void initState() {
    super.initState();
    _dashboardTabController = TabController(length: 4, vsync: this);
    _marketingTabController = TabController(length: 3, vsync: this);

    _dashboardTabController.addListener(() {
      setState(() {
        _selectedDashboardTabIndex = _dashboardTabController.index;
      });
    });

    _marketingTabController.addListener(() {
      setState(() {
        _selectedMarketingTabIndex = _marketingTabController.index;
      });
    });
  }

  @override
  void dispose() {
    _dashboardTabController.dispose();
    _marketingTabController.dispose();
    super.dispose();
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

              // Event Dropdown
              _buildEventSelector(),

              // Conditional Tab Bar
              if (_selectedBottomNavIndex == 0) _buildDashboardTabBar(),
              if (_selectedBottomNavIndex == 3) _buildMarketingTabBar(),

              // Content based on bottom nav selection
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildContent() {
    switch (_selectedBottomNavIndex) {
      case 0: // Dashboard
        return TabBarView(
          controller: _dashboardTabController,
          children: [
            OverviewTab(event: widget.event),
            EventPreviewTab(event: widget.event),
            LiveStatsTab(event: widget.event),
            const Center(
              child: Text(
                'Achievements',
                style: TextStyle(color: textColor, fontSize: 18),
              ),
            ),
          ],
        );
      case 1: // Finance
        return FinanceTab(event: widget.event);
      case 2: // QR Scan
        return const QRScannerScreen();
      case 3: // Marketing
        return TabBarView(
          controller: _marketingTabController,
          children: [
            const MarketingTab(),
            Center(
              child: Image.asset(
                'assets/coming-soon-banner.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
            Center(
              child: Image.asset(
                'assets/coming-soon-banner.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.8,
              ),
            ),
          ],
        );
      case 4: // Services
        return const ServicesTab();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: textColor),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
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

  Widget _buildEventSelector() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          // Event Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              widget.event.imageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 50,
                  height: 50,
                  color: hintTextColor.withValues(alpha: 0.2),
                  child:
                      const Icon(Icons.image, color: hintTextColor, size: 24),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Event Name and Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.event.name,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00FF00),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Active',
                      style: TextStyle(
                        color: Color(0xFF00FF00),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.keyboard_arrow_down, color: textColor, size: 24),
        ],
      ),
    );
  }

  Widget _buildDashboardTabBar() {
    final tabs = ['Overview', 'Event Preview', 'Live Stats', 'Achievements'];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedDashboardTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                _dashboardTabController.animateTo(index);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? textColor
                      : backgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? textColor
                        : hintTextColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? backgroundColor : textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMarketingTabBar() {
    final tabs = ['Invitation', 'SMS Campaign', 'Email Campaign'];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedMarketingTabIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                _marketingTabController.animateTo(index);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? textColor
                      : backgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? textColor
                        : hintTextColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      color: isSelected ? backgroundColor : textColor,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A1E),
        border: Border(
          top: BorderSide(
            color: Colors.deepPurple.shade300.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 0),
              _buildNavItem(
                  Icons.account_balance_wallet_outlined, 'Finance', 1),
              _buildNavItem(Icons.qr_code_scanner, 'QR Scan', 2),
              _buildNavItem(Icons.campaign_outlined, 'Marketing', 3),
              _buildNavItem(Icons.settings_outlined, 'Services', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBottomNavIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? primaryColor : hintTextColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? primaryColor : hintTextColor,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
