import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:spotseeker_app/services/analytics_service.dart';
import 'package:spotseeker_app/models/analytics/analytics_models.dart';
import 'package:spotseeker_app/services/auth_service.dart';
import 'package:spotseeker_app/mocks/partners_finance_mock.dart';

class OverviewTab extends StatefulWidget {
  final EventModel event;

  const OverviewTab({super.key, required this.event});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final AnalyticsService _analyticsService = AnalyticsService();
  FinanceSales? _financeSales;
  LiveStats? _liveStats;
  List<dynamic>? _partnersFinance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Try to fetch partners/manager-level finance if we have a partner token saved
      try {
        final String? partnerToken = await AuthService().getPartnerToken();
        if (partnerToken != null && partnerToken.isNotEmpty) {
          final List<dynamic> partnersData = await _analyticsService
              .getPartnersFinance(partnerToken: partnerToken);
          if (partnersData.isEmpty) {
            // Fallback to mock if external API returned no rows
            _partnersFinance = partnersFinanceMock;
          } else {
            _partnersFinance = partnersData;
          }
        }
      } catch (pf) {
        // If API fails, fallback to mock data so UI can still render.
        _partnersFinance = partnersFinanceMock;
      }

      // Fetch sales with fallback: try basic finance endpoint first, then event-scoped
      final int _usedFinanceId =
          int.tryParse(widget.event.externalEventId ?? '') ?? widget.event.id;
      FinanceSales? sales;
      try {
        sales = await _analyticsService.getBasicFinance(_usedFinanceId,
            event: widget.event);
      } catch (e) {
        sales = null;
      }

      if (!mounted) return;
      setState(() {
        _financeSales = sales;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child:
                  Center(child: CircularProgressIndicator(color: primaryColor)),
            ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  Text('Failed to load data: $_error',
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          if (!_loading && _error == null) ...[
            if (_partnersFinance != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF12121A).withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: Colors.deepPurple.shade200.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Manager Sales Rows: ${_partnersFinance!.length}',
                      style: const TextStyle(
                          color: textColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600),
                    ),
                    GestureDetector(
                      onTap: () {
                        // For now just log details. You can expand to a full screen if needed.
                        print(
                            'Partners finance sample: ${_partnersFinance!.isNotEmpty ? _partnersFinance![0] : {}}');
                      },
                      child: const Text('View sample',
                          style: TextStyle(color: primaryColor, fontSize: 12)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            // Attendees Summary
            _buildSectionHeader('Attendees Summary', label: 'Live Stats'),
            const SizedBox(height: 12),
            _buildAttendeesCard(),

            const SizedBox(height: 24),

            // Ticket Sales Summary
            _buildSectionHeader('Ticket Sales Summary', onViewAll: () {}),
            const SizedBox(height: 12),
            _buildTicketSalesCard(),

            const SizedBox(height: 24),

            // Booking Summary
            _buildSectionHeader('Booking Summary', onViewAll: () {}),
            const SizedBox(height: 12),
            _buildBookingChart(),

            const SizedBox(height: 24),

            // Revenue Breakdown
            _buildSectionHeader('Revenue Breakdown', onViewAll: () {}),
            const SizedBox(height: 12),
            _buildRevenueChart(),

            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title,
      {VoidCallback? onViewAll, String? label}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (label != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendeesCard() {
    final totalAttendees = _liveStats?.liveAttendance ?? 0;
    final onlineTickets = _financeSales?.salesByPackage
            ?.fold<int>(0, (sum, p) => sum + (p.ticketsSold)) ??
        0;
    final invites = (totalAttendees - onlineTickets) > 0
        ? (totalAttendees - onlineTickets)
        : 0;
// Get the available width using MediaQuery for responsiveness
    final screenWidth = MediaQuery.of(context).size.width;

    // Calculate dynamic sizes and positions based on screen width
    // Assuming a base for mobile (~320-400px), scale proportionally
    final largeSize = screenWidth * 0.45; // ~180 for 400px width
    final mediumSize = screenWidth * 0.35; // ~140
    final smallSize = screenWidth * 0.225; // ~90
    final bubbleHeight = largeSize *
        1.2; // Dynamic height for the stack to fit bubbles without clipping

    final largeLeft = screenWidth * 0.05; // Scaled from original left:20 (~5%)
    final mediumRight = screenWidth *
        0.05; // Changed from 0.075 to 0.05 to shift medium bubble a little to the right (decreasing 'right' moves it rightward, ~20 for 400px)
    final mediumTop = screenWidth * 0.11; // Scaled from top:45 (~11%)
    final smallBottom = -screenWidth * 0.025; // Scaled from bottom:-10 (~-2.5%)
    final smallLeft = screenWidth * 0.3; // Scaled from left:120 (~30%)
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
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
            'Total Attendees: $totalAttendees',
            style: const TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Simplified representation - in real app use custom painter for bubbles
          SizedBox(
            height: bubbleHeight, // Dynamic height
            width: double.infinity, // Full width for the stack
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                // Large red circle (Online Tickets) - positioned left
                Positioned(
                  left: largeLeft,
                  top: screenWidth * 0.025, // Scaled from top:10 (~2.5%)
                  child: _buildBubble(
                    value: '$onlineTickets',
                    label: 'Online Tickets',
                    size: largeSize,
                    color: primaryColor,
                    valueFontSize:
                        largeSize * 0.144, // Scaled from 26/180 (~0.144)
                    labelFontSize:
                        largeSize * 0.067, // Scaled from 12/180 (~0.067)
                    isStroke: false, // No stroke for large circle
                  ),
                ),
                // Medium dark red circle (Spotseeker Invites) - positioned right
                Positioned(
                  right: mediumRight,
                  top: mediumTop,
                  child: _buildBubble(
                    value: '$invites',
                    label: 'Spotseeker Invites',
                    size: mediumSize,
                    color: const Color(0xFF840812),
                    valueFontSize:
                        mediumSize * 0.171, // Scaled from 24/140 (~0.171)
                    labelFontSize:
                        mediumSize * 0.079, // Scaled from 11/140 (~0.079)
                    isStroke: true, // Add stroke for medium circle
                  ),
                ),
                // Small darkest circle (Special Invites) - positioned bottom center
                Positioned(
                  bottom: smallBottom,
                  left: smallLeft,
                  child: _buildBubble(
                    value: '0',
                    label: 'Special\nInvites',
                    size: smallSize,
                    color: const Color(0xFF500812),
                    valueFontSize:
                        smallSize * 0.244, // Scaled from 22/90 (~0.244)
                    labelFontSize:
                        smallSize * 0.111, // Scaled from 10/90 (~0.111)
                    isStroke: true, // Add stroke for small circle
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble({
    required String value,
    required String label,
    required double size,
    required Color color,
    required double valueFontSize,
    required double labelFontSize,
    bool isStroke =
        false, // New boolean parameter to control if stroke (border) is added, default false
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isStroke
            ? Border.all(color: const Color(0xFF1F0818), width: 4.0)
            : null, // Conditionally add border (stroke) with color #1F0818 and width 2 if isStroke is true
      ),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: valueFontSize,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              TextSpan(
                text: '\n$label',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: labelFontSize,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSalesCard() {
    final totalSales = _financeSales?.totalSales ?? 0.0;
    final soldTickets = _financeSales?.salesByPackage
            ?.fold<int>(0, (s, p) => s + p.ticketsSold) ??
        0;
    final currency = widget.event.currency;

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currency ${totalSales.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$soldTickets Tickets Sold Out',
                style: TextStyle(
                  color: hintTextColor.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress bar
          Row(
            children: [
              Expanded(
                flex: 98,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor,
                        primaryColor.withValues(alpha: 0.6)
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: hintTextColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '98%',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
            '${_financeSales?.salesByPackage?.fold<int>(0, (s, p) => s + p.ticketsSold) ?? 0} tickets sold',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 250,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Tier ${value.toInt() + 1}',
                          style: TextStyle(
                            color: hintTextColor.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: () {
                  final counts = (_financeSales?.salesByPackage ?? [])
                      .map<double>((p) => p.ticketsSold.toDouble())
                      .toList();
                  while (counts.length < 6) counts.add(0.0);
                  return [
                    _makeBarGroup(0, counts[0], primaryColor),
                    _makeBarGroup(1, counts[1], primaryColor),
                    _makeBarGroup(2, counts[2], primaryColor),
                    _makeBarGroup(3, counts[3], primaryColor),
                    _makeBarGroup(4, counts[4], primaryColor),
                    _makeBarGroup(5, counts[5], primaryColor),
                  ];
                }(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 30,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          const Text(
            'Total Revenue',
            style: TextStyle(
              color: hintTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${widget.event.currency} ${((_financeSales?.netRevenue ?? _financeSales?.totalSales) ?? 0.0).toStringAsFixed(2)}',
            style: const TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 1.0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'Week ${value.toInt() + 1}',
                          style: TextStyle(
                            color: hintTextColor.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}k',
                          style: TextStyle(
                            color: hintTextColor.withValues(alpha: 0.8),
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 30,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: hintTextColor.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _makeBarGroup(0, 0.0, primaryColor),
                  _makeBarGroup(1, 0.0, primaryColor),
                  _makeBarGroup(2, 0.0, primaryColor),
                  _makeBarGroup(3, 0.0, primaryColor),
                  _makeBarGroup(4, 0.0, primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
