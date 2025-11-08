import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/analytics/analytics_models.dart';
import 'package:spotseeker_app/models/analytics/basic_finance_response.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/services/analytics_service.dart';
import 'package:spotseeker_app/services/auth_service.dart';
import 'package:spotseeker_app/utils/colors.dart';

class OverviewTab extends StatefulWidget {
  final EventModel event;

  const OverviewTab({super.key, required this.event});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final AnalyticsService _analyticsService = AnalyticsService();

  BasicFinanceResponse? _basicFinance;
  FinanceSales? _financeSales;
  List<dynamic>? _partnersFinance;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);

    try {
      await _loadPartnersFinance();
      await _loadFinanceSales();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loadPartnersFinance() async {
    try {
      final partnerToken = await AuthService().getPartnerToken();
      if (partnerToken != null && partnerToken.isNotEmpty) {
        final partnersData = await _analyticsService.getPartnersFinance(partnerToken: partnerToken);
        _partnersFinance = partnersData;
        print('Partner Finance :  ${_partnersFinance!.toList()}');
      }
    } catch (_) {}
  }

  Future<void> _loadFinanceSales() async {
    final usedFinanceId = int.tryParse(widget.event.externalEventId ?? '') ?? widget.event.id;
    try {
      final response =
          await _analyticsService.getBasicFinanceResponse(usedFinanceId, event: widget.event);
      _basicFinance = response;
      _financeSales = response.toFinanceSales();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading) _buildLoading(),
          if (_error != null) _buildError(),
          if (!_loading && _error == null) ..._buildContent(context),
        ],
      ),
    );
  }

  Widget _buildLoading() => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'Failed to load data: $_error',
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildContent(BuildContext context) {
    return [
      if (_partnersFinance != null) ...[
        const SizedBox(height: 12),
        _buildPartnersFinancePreview(),
        const SizedBox(height: 12),
      ],
      _buildSectionHeader('Attendees Summary', label: 'Live Stats'),
      const SizedBox(height: 12),
      _buildAttendeesCard(),
      const SizedBox(height: 24),
      _buildSectionHeader('Ticket Sales Summary', onViewAll: () {}),
      const SizedBox(height: 12),
      _buildTicketSalesCard(),
      const SizedBox(height: 24),
      _buildSectionHeader('Booking Summary', onViewAll: () {}),
      const SizedBox(height: 12),
      _buildBookingChart(),
      const SizedBox(height: 24),
      _buildSectionHeader('Revenue Breakdown', onViewAll: () {}),
      const SizedBox(height: 12),
      _buildRevenueChart(),
      const SizedBox(height: 24),
    ];
  }

  Widget _buildPartnersFinancePreview() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF12121A).withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.deepPurple.shade200.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Manager Sales Rows: ${_partnersFinance!.length}',
            style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          GestureDetector(
            onTap: () {
              // For now just log details. You can expand to a full screen if needed.
              debugPrint(
                  'Partners finance sample: ${_partnersFinance!.isNotEmpty ? _partnersFinance![0] : {}}');
            },
            child: const Text(
              'View sample',
              style: TextStyle(color: primaryColor, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, String? label}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Text(
              'View All',
              style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w600),
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
              style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildAttendeesCard() {
    final finance = _financeSales;
    final basic = _basicFinance;

    final soldTicketCount =
        finance?.salesByPackage?.fold<int>(0, (sum, p) => sum + p.ticketsSold) ?? 0;

    final totalAttendees = (basic?.customerCount ?? []).fold<int>(0, (sum, count) => sum + count);

    final attendeesDisplay = totalAttendees > 0 ? totalAttendees : soldTicketCount;

    const spotseekerInvites = 0;
    final specialInvites =
        (basic?.totalAccepted ?? 0) > 0 ? basic!.totalAccepted! : (basic?.totalNoResponse ?? 0);

    final screenWidth = MediaQuery.of(context).size.width;

    final largeSize = screenWidth * 0.45;
    final mediumSize = screenWidth * 0.35;
    final smallSize = screenWidth * 0.225;
    final bubbleHeight = largeSize * 1.2;

    final largeLeft = screenWidth * 0.05;
    final mediumRight = screenWidth * 0.05;
    final mediumTop = screenWidth * 0.11;
    final smallBottom = -screenWidth * 0.025;
    final smallLeft = screenWidth * 0.3;

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
            'Total Attendees: $attendeesDisplay',
            style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: bubbleHeight,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: largeLeft,
                  top: screenWidth * 0.025,
                  child: _buildBubble(
                    value: '$soldTicketCount',
                    label: 'Online Tickets',
                    size: largeSize,
                    color: primaryColor,
                    valueFontSize: largeSize * 0.144,
                    labelFontSize: largeSize * 0.067,
                    isStroke: false,
                  ),
                ),
                Positioned(
                  right: mediumRight,
                  top: mediumTop,
                  child: _buildBubble(
                    value: '$spotseekerInvites',
                    label: 'Spotseeker Invites',
                    size: mediumSize,
                    color: const Color(0xFF840812),
                    valueFontSize: mediumSize * 0.171,
                    labelFontSize: mediumSize * 0.079,
                    isStroke: true,
                  ),
                ),
                Positioned(
                  bottom: smallBottom,
                  left: smallLeft,
                  child: _buildBubble(
                    value: '$specialInvites',
                    label: 'Special\nInvites',
                    size: smallSize,
                    color: const Color(0xFF500812),
                    valueFontSize: smallSize * 0.244,
                    labelFontSize: smallSize * 0.111,
                    isStroke: true,
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
    bool isStroke = false,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: isStroke ? Border.all(color: const Color(0xFF1F0818), width: 4.0) : null,
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
                    height: 1.2),
              ),
              TextSpan(
                text: '\n$label',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w500,
                    height: 1.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSalesCard() {
    final totalSales = _basicFinance?.totalSales ?? _financeSales?.totalSales ?? 0.0;
    int soldTickets = 0;
    if (_basicFinance != null) {
      soldTickets = _basicFinance!.packages.fold<int>(0, (sum, pkg) => sum + pkg.ticketsSold);
    } else if (_financeSales?.salesByPackage != null) {
      soldTickets =
          _financeSales!.salesByPackage!.fold<int>(0, (sum, pkg) => sum + pkg.ticketsSold);
    }
    int totalTicketCount = 0;
    if (_basicFinance != null) {
      totalTicketCount = _basicFinance!.event.ticketSalesSumTotalTicketCount ?? 0;
      if (totalTicketCount == 0) {
        totalTicketCount = _basicFinance!.ticketPackages.fold<int>(
          0,
          (sum, pkg) => sum + (pkg.totalTickets ?? 0),
        );
      }
    }
    if (totalTicketCount == 0 && widget.event.ticketPackages.isNotEmpty) {
      totalTicketCount = widget.event.ticketPackages.length;
    }
    if (totalTicketCount == 0 && soldTickets > 0) {
      totalTicketCount = soldTickets;
    }

    final soldRatio = totalTicketCount > 0 ? soldTickets / totalTicketCount : 0.0;
    final soldPercent = (soldRatio * 100).clamp(0, 100).round();
    final filledFlex = math.max(
      0,
      (soldRatio * 1000).round(),
    );
    final emptyFlex = filledFlex >= 1000 ? 0 : 1000 - filledFlex;

    final currency = _basicFinance?.event.currency ?? widget.event.currency;

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

          // Progress bar (static 98% as per original)
          Row(children: [
            Expanded(
              flex: filledFlex,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [primaryColor, primaryColor.withValues(alpha: 0.6)]),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Expanded(
              flex: emptyFlex,
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  color: hintTextColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ]),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$soldPercent%',
              style: const TextStyle(
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
    final counts = <double>[];
    if (_basicFinance != null) {
      counts.addAll(
        _basicFinance!.packages.map(
          (pkg) => pkg.ticketsSold.toDouble(),
        ),
      );
    } else if (_financeSales?.salesByPackage != null) {
      counts.addAll(
        _financeSales!.salesByPackage!.map(
          (pkg) => pkg.ticketsSold.toDouble(),
        ),
      );
    }
    final trimmedCounts = counts.take(6).toList();
    while (trimmedCounts.length < 6) {
      trimmedCounts.add(0.0);
    }

    final totalSold = trimmedCounts.fold<int>(
      0,
      (sum, value) => sum + value.toInt(),
    );
    final maxTickets = trimmedCounts.fold<double>(
      0.0,
      (maxValue, value) => math.max(maxValue, value),
    );
    final maxY = maxTickets > 0 ? maxTickets * 1.2 : 1.0;

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
            '$totalSold tickets sold',
            style: const TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        _basicFinance!.packages[value.toInt()].name,
                        style: TextStyle(
                          color: hintTextColor.withValues(alpha: 0.8),
                          fontSize: 11,
                        ),
                      ),
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
                barGroups: List.generate(
                  _basicFinance!.packages.length,
                  (i) => _makeBarGroup(i, trimmedCounts[i], primaryColor),
                ),
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
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueChart() {
    final revenue =
        _financeSales?.netRevenue ?? _financeSales?.totalSales ?? _basicFinance?.totalSales ?? 0.0;
    final currency = _basicFinance?.event.currency ?? widget.event.currency;

    final revenueBars = _basicFinance!.packages.map((entry) => entry.revenue / 1000).toList();
    while (revenueBars.length < 5) {
      revenueBars.add(0.0);
    }

    final maxRevenueBar = revenueBars.fold<double>(
      0.0,
      (currentMax, value) => math.max(currentMax, value),
    );
    final maxY = maxRevenueBar > 0 ? maxRevenueBar * 1.2 : 1.0;

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
            style: TextStyle(color: hintTextColor, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            '$currency ${revenue.toStringAsFixed(2)}',
            style: const TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Text(
                        _basicFinance!.packages[value.toInt()].name,
                        style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 11),
                      ),
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        '${value.toInt()}k',
                        style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 11),
                      ),
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
                  horizontalInterval: maxY / 4,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: hintTextColor.withValues(alpha: 0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(
                  _basicFinance!.packages.length,
                  (i) => _makeBarGroup(i, revenueBars[i], primaryColor),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
