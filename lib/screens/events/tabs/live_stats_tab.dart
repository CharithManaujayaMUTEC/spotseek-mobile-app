import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:fl_chart/fl_chart.dart';

class LiveStatsTab extends StatefulWidget {
  final EventModel event;

  const LiveStatsTab({super.key, required this.event});

  @override
  State<LiveStatsTab> createState() => _LiveStatsTabState();
}

class _LiveStatsTabState extends State<LiveStatsTab> {
  int _selectedPackage = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Live Attendance Tracking
          const Text(
            'Live Attendance Tracking',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Total attendees : 1450',
            style: TextStyle(
              color: hintTextColor,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          
          // Bubble Chart
          _buildBubbleChart(),
          
          const SizedBox(height: 20),
          
          // Attendance Cards
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard(
                  'Total Attendees',
                  'Inside: 1216',
                  'To Come: 234',
                  const Color(0xFF00FF00),
                  const Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceCard(
                  'Online Tickets',
                  'Inside: 856',
                  'To Come: 144',
                  const Color(0xFF00FF00),
                  const Color(0xFFFFFF00),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAttendanceCard(
                  'Spotseeker Invites',
                  'Inside: 320',
                  'To Come: 80',
                  const Color(0xFF00FF00),
                  const Color(0xFFFFFF00),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAttendanceCard(
                  'Special Invites',
                  'Inside: 40',
                  'To Come: 10',
                  const Color(0xFF00FF00),
                  const Color(0xFFFFFF00),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Attendance by Ticket Package
          const Text(
            'Attendance by Ticket Package',
            style: TextStyle(
              color: textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Package Tabs
          _buildPackageTabs(),
          
          const SizedBox(height: 16),
          
          // Package Details
          _buildPackageDetails(),
          
          const SizedBox(height: 24),
          
          // Live Scan Insights
          _buildScanInsights(),
          
          const SizedBox(height: 24),
          
          // Fraudulent Scan Alerts
          _buildFraudulentAlerts(),
          
          const SizedBox(height: 24),
          
          // Audience by Gender
          _buildAudienceDemographics(),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBubbleChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
        ),
      ),
      child: Stack(
        children: [
          // Main bubble - Online Tickets
          Positioned(
            left: 40,
            top: 20,
            child: _buildBubble('1000\nOnline Tickets', 120, primaryColor),
          ),
          // Spotseeker Invites
          Positioned(
            right: 30,
            top: 30,
            child: _buildBubble('400\nSpotseeker\nInvites', 90, const Color(0xFF8B0000)),
          ),
          // Special Invites
          Positioned(
            left: 110,
            bottom: 20,
            child: _buildBubble('50\nSpecial\nInvites', 60, const Color(0xFF600000)),
          ),
        ],
      ),
    );
  }

  Widget _buildBubble(String label, double size, Color color) {
    return Container(
      width: size,
      height: size,
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

  Widget _buildAttendanceCard(
    String title,
    String inside,
    String toCome,
    Color insideColor,
    Color toComeColor,
  ) {
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
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: insideColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  inside,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: toComeColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  toCome,
                  style: const TextStyle(
                    color: textColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPackageTabs() {
    final packages = ['Tier 1', 'Tier 2', 'Tier 3', 'Tier 4'];
    
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        itemBuilder: (context, index) {
          final isSelected = _selectedPackage == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPackage = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? textColor : backgroundColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? textColor : hintTextColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    packages[index],
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

  Widget _buildPackageDetails() {
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
            'Tier 01 Package',
            style: TextStyle(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Progress bars
          Row(
            children: List.generate(20, (index) {
              Color barColor;
              if (index < 16) {
                barColor = const Color(0xFF00FF00);
              } else if (index < 18) {
                barColor = const Color(0xFFFFFF00);
              } else {
                barColor = hintTextColor.withValues(alpha: 0.3);
              }
              return Expanded(
                child: Container(
                  height: 8,
                  margin: const EdgeInsets.only(right: 2),
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text(
              '80%',
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFF00FF00), size: 12),
              const SizedBox(width: 8),
              const Text(
                'Inside',
                style: TextStyle(color: textColor, fontSize: 13),
              ),
              const Spacer(),
              const Text(
                '120',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle, color: Color(0xFFFFFF00), size: 12),
              const SizedBox(width: 8),
              const Text(
                'To Come',
                style: TextStyle(color: textColor, fontSize: 13),
              ),
              const Spacer(),
              const Text(
                '95',
                style: TextStyle(
                  color: textColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Live Scan Insights',
              style: TextStyle(
                color: textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                children: [
                  const Text(
                    'All packages',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    color: textColor,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'No of Attendees',
          style: TextStyle(
            color: hintTextColor,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
            ),
          ),
          child: SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 40,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: hintTextColor.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: hintTextColor.withValues(alpha: 0.8),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 15,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: hintTextColor.withValues(alpha: 0.8),
                            fontSize: 10,
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
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: 120,
                minY: 0,
                maxY: 200,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 20),
                      const FlSpot(15, 40),
                      const FlSpot(30, 150),
                      const FlSpot(45, 170),
                      const FlSpot(60, 140),
                      const FlSpot(75, 160),
                      const FlSpot(90, 120),
                      const FlSpot(105, 100),
                      const FlSpot(120, 90),
                    ],
                    isCurved: true,
                    color: primaryColor,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          primaryColor.withValues(alpha: 0.5),
                          primaryColor.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFraudulentAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fraudulent Scan Alerts - 16',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildAlertCard(
          icon: '☑️',
          title: 'Multiple Entry Attempt-10',
          description: '10 tickets tried re-entry after already scanned (Normal Attendees)',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: '📱',
          title: 'Fake QR Pattern Detected-03',
          description: '3 suspicious QR codes don\'t match issued ticket format (Potential Forgery)',
        ),
        const SizedBox(height: 12),
        _buildAlertCard(
          icon: '🔍',
          title: 'Suspicious Device Activity-03',
          description: '3 suspicious QR scans detected from the same device within 1 minute (Tier 2)',
        ),
      ],
    );
  }

  Widget _buildAlertCard({
    required String icon,
    required String title,
    required String description,
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
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(
              color: textColor.withValues(alpha: 0.8),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudienceDemographics() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Audience by Gender',
          style: TextStyle(
            color: textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildGenderChip('Male 75%'),
                  const SizedBox(width: 16),
                  _buildGenderChip('Female 25%'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 180,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 20,
                    barTouchData: BarTouchData(enabled: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final ages = ['18-25', '26-35', '36-45', '46-55', '56+'];
                            return Text(
                              ages[value.toInt()],
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
                          reservedSize: 30,
                          interval: 5,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '${value.toInt()}%',
                              style: TextStyle(
                                color: hintTextColor.withValues(alpha: 0.8),
                                fontSize: 10,
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
                      horizontalInterval: 5,
                      getDrawingHorizontalLine: (value) {
                        return FlLine(
                          color: hintTextColor.withValues(alpha: 0.1),
                          strokeWidth: 1,
                        );
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: [
                      _makeBarGroup(0, 15, primaryColor),
                      _makeBarGroup(1, 17, primaryColor),
                      _makeBarGroup(2, 14, primaryColor),
                      _makeBarGroup(3, 14, primaryColor),
                      _makeBarGroup(4, 11, primaryColor),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGenderChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hintTextColor.withValues(alpha: 0.3),
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
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 40,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}
