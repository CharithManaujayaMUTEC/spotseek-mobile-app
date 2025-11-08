import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class OverviewTab extends StatelessWidget {
  final EventModel event;

  const OverviewTab({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Alerts & Notifications
          _buildSectionHeader('Alerts & Notifications', onViewAll: () {}),
          const SizedBox(height: 12),
          _buildAlertCard(
            icon: '🔓',
            title: 'Sales Milestone Unlocked 💰',
            description: 'Big win! Music Fest Colombo 2025 has crossed LKR 500,000 in sales.',
            timestamp: '01 Sep 2025 | 10:00 AM',
          ),
          const SizedBox(height: 10),
          _buildAlertCard(
            icon: '⚠️',
            title: 'Fraudulent Scan Alert ⚠️',
            description: '3 suspicious QR scans detected at Summer Beats Festival 2025.',
            timestamp: '01 Sep 2025 | 10:00 AM',
          ),
          const SizedBox(height: 10),
          _buildAlertCard(
            icon: '⏰',
            title: 'Closing Soon ⏰',
            description: 'Tier 2 Tickets Closing in 3 Days - Only 120 tickets left. Hurry before they\'re gone!',
            timestamp: '01 Sep 2025 | 10:00 AM',
          ),
          
          const SizedBox(height: 24),
          
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
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onViewAll, String? label}) {
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

  Widget _buildAlertCard({
    required String icon,
    required String title,
    required String description,
    required String timestamp,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 14,
                color: hintTextColor.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 4),
              Text(
                timestamp,
                style: TextStyle(
                  color: hintTextColor.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendeesCard() {
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
            'Total Attendees: 1450',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // Simplified representation - in real app use custom painter for bubbles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBubble('1000\nOnline Tickets', 120, primaryColor),
              _buildBubble('400\nSpotseeker\nInvites', 80, const Color(0xFF8B0000)),
              _buildBubble('50\nSpecial\nInvites', 50, const Color(0xFF600000)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String label, double size, Color color) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: textColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTicketSalesCard() {
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
              const Text(
                'Rs. 2,280,000',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '456 Tickets Sold Out',
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
                      colors: [primaryColor, primaryColor.withValues(alpha: 0.6)],
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
          const Text(
            '990 tickets sold',
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
                barGroups: [
                  _makeBarGroup(0, 200, primaryColor),
                  _makeBarGroup(1, 160, primaryColor),
                  _makeBarGroup(2, 120, primaryColor),
                  _makeBarGroup(3, 100, primaryColor),
                  _makeBarGroup(4, 180, primaryColor),
                  _makeBarGroup(5, 140, primaryColor),
                  _makeBarGroup(6, 130, primaryColor),
                ],
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
          const Text(
            'Rs. 645,000',
            style: TextStyle(
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
                maxY: 150,
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
                  _makeBarGroup(0, 70, primaryColor),
                  _makeBarGroup(1, 65, primaryColor),
                  _makeBarGroup(2, 100, primaryColor),
                  _makeBarGroup(3, 130, primaryColor),
                  _makeBarGroup(4, 85, primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
