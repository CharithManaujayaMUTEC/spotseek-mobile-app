import 'dart:math';

import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/analytics/basic_finance_response.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/screens/events/finance_tabs/bank_details_screen.dart';
import 'package:spotseeker_app/screens/events/finance_tabs/fund_withdrawal.dart';
import 'package:spotseeker_app/services/analytics_service.dart';
import 'package:spotseeker_app/services/finance_service.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';

class FinanceTab extends StatefulWidget {
  final EventModel event;

  const FinanceTab({super.key, required this.event});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  bool loading = false;
  int _selectedSubTab = 0;
  bool _showFundWithdrawalInFinanceBreakdown = false;
  final AnalyticsService _analyticsService = AnalyticsService();

  BasicFinanceResponse? _basicFinance;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => loading = true);

    try {
      await _loadFinanceSales();
    } catch (e) {
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _loadFinanceSales() async {
    final usedFinanceId = int.tryParse(widget.event.externalEventId ?? '') ?? widget.event.id;
    try {
      final response =
          await _analyticsService.getBasicFinanceResponse(usedFinanceId, event: widget.event);
      _basicFinance = response;
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab navigation (horizontally scrollable)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          height: 42,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildSubTab('Sales', 0),
                const SizedBox(width: 8),
                _buildSubTab('Finance Breakdown', 1),
                const SizedBox(width: 8),
                _buildSubTab('Withdraw Funds', 2),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Content
        Expanded(
          child: IndexedStack(
            index: _selectedSubTab,
            children: [
              _SalesSubTab(
                event: widget.event,
                finance: _basicFinance,
                isLoading: loading,
                onRefresh: _loadFinanceSales,
              ),
              _showFundWithdrawalInFinanceBreakdown
                  ? const FundWithdrawalScreen()
                  : _FinanceBreakdownSubTab(
                      event: widget.event,
                      onViewAll: () {
                        setState(() {
                          _showFundWithdrawalInFinanceBreakdown = true;
                        });
                      }),
              _WithdrawFundsSubTab(event: widget.event),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubTab(String label, int index) {
    final isSelected = _selectedSubTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubTab = index),
      child: Container(
        height: 42, // same height as _buildMarketingTabBar
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? textColor : backgroundColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? textColor : hintTextColor.withOpacity(0.3),
          ),
        ),
        alignment: Alignment.center, // same alignment fix
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? backgroundColor : textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ============ SALES SUB-TAB ============
class _SalesSubTab extends StatefulWidget {
  final EventModel event;
  final BasicFinanceResponse? finance;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _SalesSubTab({
    required this.event,
    required this.finance,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  State<_SalesSubTab> createState() => _SalesSubTabState();
}

class _SalesSubTabState extends State<_SalesSubTab> {
  String _selectedFilter = 'Today';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDropdown = false;
  bool _isSelectingStartDate = true;
  bool _loading = false;
  double _totalRevenue = 0.0;
  List<Map<String, dynamic>> _packageDetails = [];
  List<(double, String, String)> _segments = const [];
  BasicFinanceResponse? _basicFinance;

  @override
  void initState() {
    super.initState();
    _loading = widget.isLoading;
    _hydrateFromFinance(widget.finance);
  }

  @override
  void didUpdateWidget(covariant _SalesSubTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.finance, oldWidget.finance)) {
      _hydrateFromFinance(widget.finance);
    }
    if (widget.isLoading != oldWidget.isLoading) {
      setState(() {
        _loading = widget.isLoading;
      });
    }
  }

  void _hydrateFromFinance(BasicFinanceResponse? finance) {
    _basicFinance = finance;
    if (finance == null) {
      setState(() {
        _totalRevenue = 0.0;
        _packageDetails = [];
        _segments = const [];
        _loading = widget.isLoading;
      });
      return;
    }

    final packages = finance.packages;
    final totalRevenue = finance.totalSales;
    final totalRevenueForPercentages = packages.fold<double>(0.0, (sum, pkg) => sum + pkg.revenue);

    final packageDetails = packages.map<Map<String, dynamic>>((pkg) {
      final ticketPackage = _resolveTicketPackage(finance, pkg);
      final totalTickets = ticketPackage?.totalTickets ?? pkg.ticketsSold;
      final ticketPrice =
          ticketPackage?.price ?? (pkg.ticketsSold > 0 ? pkg.revenue / pkg.ticketsSold : 0.0);

      return {
        'packageName': pkg.name,
        'totalRevenue': pkg.revenue,
        'ticketsSold': pkg.ticketsSold,
        'totalTickets': totalTickets,
        'ticketPrice': ticketPrice,
        'startDate': ticketPackage?.startDateTime,
        'endDate': ticketPackage?.endDateTime,
        'countdown': null,
      };
    }).toList();

    final segments = packages.map<(double, String, String)>((pkg) {
      final proportion = totalRevenueForPercentages > 0
          ? (pkg.revenue / totalRevenueForPercentages).clamp(0.0, 1.0)
          : 0.0;
      final percentageLabel = '${(proportion * 100).round()}%';
      return (proportion, percentageLabel, pkg.name);
    }).toList();

    setState(() {
      _totalRevenue = totalRevenue;
      _packageDetails = packageDetails;
      _segments = segments;
      _loading = widget.isLoading;
    });
  }

  BasicFinanceTicketPackage? _resolveTicketPackage(
    BasicFinanceResponse finance,
    BasicFinancePackage pkg,
  ) {
    if (pkg.source != null) return pkg.source;
    if (pkg.id != null) {
      for (final ticket in finance.ticketPackages) {
        if (ticket.id == pkg.id) return ticket;
      }
    }
    for (final ticket in finance.ticketPackages) {
      if (ticket.name != null && ticket.name!.toLowerCase() == pkg.name.toLowerCase()) {
        return ticket;
      }
    }
    return null;
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  String _getDateRangeText() {
    if (_startDate == null && _endDate == null) {
      return 'Select Date Range';
    } else if (_startDate != null && _endDate == null) {
      return '${_getMonthName(_startDate!.month)} ${_startDate!.day} - End Date';
    } else if (_startDate != null && _endDate != null) {
      return '${_getMonthName(_startDate!.month)} ${_startDate!.day} - ${_getMonthName(_endDate!.month)} ${_endDate!.day}';
    }
    return 'Select Date Range';
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _isSelectingStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: _isSelectingStartDate ? DateTime(2020) : (_startDate ?? DateTime(2020)),
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
        if (_isSelectingStartDate) {
          _startDate = picked;
          // If end date exists and is before start date, reset it
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
          // Automatically prompt for end date after selecting start date
          _isSelectingStartDate = false;
          Future.delayed(const Duration(milliseconds: 300), () {
            _selectDateRange(context);
          });
        } else {
          _endDate = picked;
          _isSelectingStartDate = true;
        }
      });
    } else {
      // User cancelled, reset to start date selection
      setState(() {
        _isSelectingStartDate = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = widget.finance?.event.currency ?? widget.event.currency;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: hintTextColor, strokeWidth: 2)),
            ),
          const SizedBox(height: 20),

          // DONUT CHART + FILTERS
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                // ==== COMBINED FILTERS ====
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _showDropdown = !_showDropdown),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _selectedFilter,
                                style: const TextStyle(color: textColor, fontSize: 13),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _showDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                color: textColor,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSelectingStartDate = true;
                          });
                          _selectDateRange(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.deepPurple.shade300.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.calendar_today, color: textColor, size: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getDateRangeText(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: (_startDate != null || _endDate != null)
                                        ? textColor
                                        : hintTextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (_startDate != null || _endDate != null)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _startDate = null;
                                      _endDate = null;
                                      _isSelectingStartDate = true;
                                    });
                                  },
                                  child: const Icon(Icons.clear, color: hintTextColor, size: 16),
                                )
                              else
                                const Icon(Icons.keyboard_arrow_down, color: textColor, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (mounted) {
                          setState(() => _loading = true);
                        }
                        await widget.onRefresh();
                      },
                      icon: const Icon(Icons.refresh, color: textColor),
                      tooltip: 'Refresh sales',
                    ),
                  ],
                ),

                // Dropdown menu
                if (_showDropdown) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      children: [
                        'Today',
                        'Last 7 days',
                        'Last 30 days',
                        'Last Month',
                        'Last 3 Month'
                      ]
                          .map((e) => GestureDetector(
                                onTap: () => setState(() {
                                  _selectedFilter = e;
                                  _showDropdown = false;
                                }),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(e,
                                          style: const TextStyle(color: textColor, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 40),

                // ==== DONUT CHART (unchanged) ====
                SizedBox(
                  height: 280,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(280, 280),
                        painter: _DonutChartPainter(segments: _segments),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Sales Revenue',
                            style: TextStyle(color: hintTextColor, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$currency ${(_basicFinance?.totalSales ?? _totalRevenue).toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Package Wise Sales (unchanged)
          const Text('Package Wise Sales',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ..._packageDetails.expand((p) {
            final ticketsSold = p['ticketsSold'] as int;
            final totalTickets = p['totalTickets'] as int;
            final soldOutText = '$ticketsSold Sold';
            final soldColor = ticketsSold > 0 ? Colors.green : primaryColor;
            return [
              _buildPackageCard(
                tier: p['packageName']?.toString() ?? '-',
                price: '$currency ${(p['totalRevenue'] as double).toStringAsFixed(2)}',
                soldOut: soldOutText,
                soldOutColor: soldColor,
                ticketPrice: '$currency ${(p['ticketPrice'] as double).toStringAsFixed(2)}',
                releaseCount: totalTickets.toString(),
                startDate: p['startDate']?.toString() ?? '-',
                endDate: p['endDate']?.toString() ?? '-',
                countdown: p['countdown'] as String?,
              ),
              const SizedBox(height: 12),
            ];
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String tier,
    required String price,
    required String soldOut,
    required Color soldOutColor,
    required String ticketPrice,
    required String releaseCount,
    required String startDate,
    required String endDate,
    String? countdown,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.confirmation_number, color: textColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tier,
                        style: const TextStyle(
                            color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(price, style: const TextStyle(color: textColor, fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: soldOutColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(soldOut,
                    style:
                        TextStyle(color: soldOutColor, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Ticket Price', ticketPrice),
          const SizedBox(height: 8),
          _buildInfoRow('Ticket Release Count', releaseCount),
          const SizedBox(height: 8),
          _buildInfoRow('Start Date & Time', startDate),
          const SizedBox(height: 8),
          _buildInfoRow('End Date & Time', endDate),
          if (countdown != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text('Countdown',
                    style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 12)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(countdown,
                      style: const TextStyle(
                          color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 12)),
        Text(value,
            style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<(double, String, String)> segments;

  _DonutChartPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2;
    final strokeWidth = 50.0;
    final innerRadius = outerRadius - strokeWidth;

    final data = segments.isEmpty ? <(double, String, String)>[(0.0, '0%', '-')] : segments;

    double startAngle = -90 * (3.14159 / 180);

    // Gap between segments
    const gapAngle = 0.04;

    // Corner radius - like rounded rectangle corners
    const cornerRadius = 8.0;

    // Create gradient
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const gradient = SweepGradient(
      colors: [
        Color(0xFF24014E),
        Color(0xFF52078C),
        Color(0xFF6E219A),
        Color(0xFF8B3DA8),
        Color(0xFFB565C8),
        Color(0xFFD88EE0),
        Color(0xFFF59FDE),
        Color(0xFFED40BF),
        Color(0xFFC6179B),
        Color(0xFF8B0C6E),
        Color(0xFF5A0549),
        Color(0xFF24014E),
      ],
      stops: [
        0.0,
        0.10,
        0.20,
        0.30,
        0.40,
        0.50,
        0.60,
        0.70,
        0.80,
        0.85,
        0.95,
        1.0,
      ],
      transform: GradientRotation(75 * 3.14159 / 180),
    );

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    for (var segment in data) {
      final sweepAngle = segment.$1 * 2 * 3.14159 - gapAngle;
      final endAngle = startAngle + sweepAngle;

      // Create path with 4 rounded corners (like a rounded rectangle bent into arc)
      final path = Path();

      // Calculate the 4 corner points of the "rectangle"
      // Corner 1: Start-Outer (top-left of rectangle)
      final c1x = center.dx + outerRadius * cos(startAngle);
      final c1y = center.dy + outerRadius * sin(startAngle);

      // Corner 2: End-Outer (top-right of rectangle)
      final c2x = center.dx + outerRadius * cos(endAngle);
      final c2y = center.dy + outerRadius * sin(endAngle);

      // Corner 3: End-Inner (bottom-right of rectangle)
      final c3x = center.dx + innerRadius * cos(endAngle);
      final c3y = center.dy + innerRadius * sin(endAngle);

      // Corner 4: Start-Inner (bottom-left of rectangle)
      final c4x = center.dx + innerRadius * cos(startAngle);
      final c4y = center.dy + innerRadius * sin(startAngle);

      // Start from first corner with offset for rounding
      final startOffset = cornerRadius / outerRadius;
      path.moveTo(
        center.dx + outerRadius * cos(startAngle + startOffset),
        center.dy + outerRadius * sin(startAngle + startOffset),
      );

      // Side 1: Outer arc from corner 1 to corner 2 (with rounded corners)
      // Draw outer arc but stop before the end for rounding
      path.arcTo(
        Rect.fromCircle(center: center, radius: outerRadius),
        startAngle + startOffset,
        sweepAngle - startOffset - (cornerRadius / outerRadius),
        false,
      );

      // Corner 2: rounded corner at end-outer (top-right)
      path.quadraticBezierTo(c2x, c2y, c3x + (c2x - c3x) * 0.7, c3y + (c2y - c3y) * 0.7);

      // Side 2: Right edge from corner 2 to corner 3
      path.lineTo(c3x + (c2x - c3x) * 0.3, c3y + (c2y - c3y) * 0.3);

      // Corner 3: rounded corner at end-inner (bottom-right)
      path.quadraticBezierTo(
          c3x,
          c3y,
          center.dx + innerRadius * cos(endAngle - (cornerRadius / innerRadius)),
          center.dy + innerRadius * sin(endAngle - (cornerRadius / innerRadius)));

      // Side 3: Inner arc from corner 3 to corner 4 (with rounded corners)
      path.arcTo(
        Rect.fromCircle(center: center, radius: innerRadius),
        endAngle - (cornerRadius / innerRadius),
        -(sweepAngle - (cornerRadius / innerRadius) - startOffset),
        false,
      );

      // Corner 4: rounded corner at start-inner (bottom-left)
      path.quadraticBezierTo(c4x, c4y, c4x + (c1x - c4x) * 0.3, c4y + (c1y - c4y) * 0.3);

      // Side 4: Left edge from corner 4 to corner 1
      path.lineTo(c1x + (c4x - c1x) * 0.3, c1y + (c4y - c1y) * 0.3);

      // Corner 1: rounded corner at start-outer (top-left)
      path.quadraticBezierTo(c1x, c1y, center.dx + outerRadius * cos(startAngle + startOffset),
          center.dy + outerRadius * sin(startAngle + startOffset));

      path.close();

      canvas.drawPath(path, paint);

      // Draw text labels
      final middleAngle = startAngle + sweepAngle / 2;
      final textRadius = innerRadius + strokeWidth / 2;
      final textX = center.dx + textRadius * cos(middleAngle);
      final textY = center.dy + textRadius * sin(middleAngle);

      // Draw percentage
      final percentTextPainter = TextPainter(
        text: TextSpan(
          text: segment.$2,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      percentTextPainter.layout();
      percentTextPainter.paint(
        canvas,
        Offset(textX - percentTextPainter.width / 2, textY - percentTextPainter.height - 1),
      );

      // Draw tier label
      final labelTextPainter = TextPainter(
        text: TextSpan(
          text: segment.$3,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      labelTextPainter.layout();
      labelTextPainter.paint(
        canvas,
        Offset(textX - labelTextPainter.width / 2, textY + 1),
      );

      startAngle += sweepAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ FINANCE BREAKDOWN SUB-TAB ============
class _FinanceBreakdownSubTab extends StatefulWidget {
  final EventModel event;
  final VoidCallback? onViewAll;

  const _FinanceBreakdownSubTab({Key? key, required this.event, this.onViewAll}) : super(key: key);

  @override
  State<_FinanceBreakdownSubTab> createState() => _FinanceBreakdownSubTabState();
}

class _FinanceBreakdownSubTabState extends State<_FinanceBreakdownSubTab> {
  bool _loading = true;
  double _totalRevenue = 0.0;
  List<double> _timeline = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final raw =
          await AnalyticsService().getFinanceBreakdownRaw(widget.event.id, event: widget.event);
      setState(() {
        _totalRevenue =
            (raw['totalRevenue'] is num) ? (raw['totalRevenue'] as num).toDouble() : 0.0;
        _timeline = (raw['revenueTimeline'] as List<dynamic>? ?? [])
            .map<double>((e) => (e is num) ? e.toDouble() : (double.tryParse(e.toString()) ?? 0.0))
            .toList();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _totalRevenue = 0.0;
        _timeline = const [];
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: hintTextColor, strokeWidth: 2));
    }
    final bars = _timeline.isEmpty ? [0.0, 0.0, 0.0, 0.0, 0.0] : _timeline;
    final maxVal = bars.isEmpty ? 1.0 : bars.reduce((a, b) => a > b ? a : b);
    final safeMax = maxVal <= 0 ? 1.0 : maxVal;
    final currency = widget.event.currency;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Total Revenue', style: TextStyle(color: hintTextColor, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            '$currency ${_totalRevenue.toStringAsFixed(2)}',
            style: const TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 250,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ['150k', '120k', '90k', '60k', '30k', '0']
                              .map((e) => Text(e,
                                  style: TextStyle(
                                      color: hintTextColor.withValues(alpha: 0.7), fontSize: 10)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < bars.length; i++) ...[
                              _buildBar((bars[i] / safeMax) * 150.0, 'W${i + 1}')
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fund Withdrawals',
                  style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: widget.onViewAll ?? () {},
                child: const Text('View All', style: TextStyle(color: primaryColor, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('No withdrawals yet', style: TextStyle(color: hintTextColor, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBar(double percent, String label) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: (percent / 150) * 150,
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }
}

// ============ WITHDRAW FUNDS SUB-TAB ============
class _WithdrawFundsSubTab extends StatefulWidget {
  final EventModel event;

  const _WithdrawFundsSubTab({required this.event});

  @override
  State<_WithdrawFundsSubTab> createState() => _WithdrawFundsSubTabState();
}

class _WithdrawFundsSubTabState extends State<_WithdrawFundsSubTab> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  bool _showBankDetails = false;
  double _amount = 0.0;
  double _commission = 0.0;
  double _total = 0.0;
  double _availableFunds = 0.0;
  double _totalRevenueFetched = 0.0;
  int _totalWithdrawals = 0;
  Map<String, dynamic>? _selectedBank;

  @override
  void dispose() {
    _amountController.removeListener(_updateAmounts);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateAmounts);
    _fetchSummary();
  }

  void _updateAmounts() {
    // Remove any non-numeric characters except dot
    final raw = _amountController.text.replaceAll(RegExp(r'[^0-9\.]'), '');
    final parsed = double.tryParse(raw) ?? 0.0;
    final commission = parsed * 0.05;
    final total = parsed - commission;
    setState(() {
      _amount = parsed;
      _commission = commission;
      _total = total;
    });
  }

  String _formatCurrency(double value) {
    final rounded = value.round();
    final s = rounded.toString();
    final reg = RegExp(r"\B(?=(\d{3})+(?!\d))");
    return 'LKR ${s.replaceAllMapped(reg, (m) => ',')}';
  }

  String _formatRs(double value) {
    final rounded = value.round();
    final s = rounded.toString();
    final reg = RegExp(r"\B(?=(\d{3})+(?!\d))");
    return 'Rs. ' + s.replaceAllMapped(reg, (m) => ',');
  }

  Future<void> _fetchSummary() async {
    try {
      final breakdown =
          await AnalyticsService().getFinanceBreakdownRaw(widget.event.id, event: widget.event);
      if (!mounted) return;
      setState(() {
        _availableFunds = (breakdown['availableFunds'] is num)
            ? (breakdown['availableFunds'] as num).toDouble()
            : 0.0;
        _totalRevenueFetched = (breakdown['totalRevenue'] is num)
            ? (breakdown['totalRevenue'] as num).toDouble()
            : 0.0;
        _totalWithdrawals = (breakdown['totalWithdrawals'] is num)
            ? (breakdown['totalWithdrawals'] as num).toInt()
            : 0;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _availableFunds = 0.0;
        _totalRevenueFetched = 0.0;
        _totalWithdrawals = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show Bank Details screen if _showBankDetails is true
    if (_showBankDetails) {
      return BankDetails(
        event: widget.event,
        onSelect: (bank) {
          setState(() {
            _selectedBank = bank;
            _showBankDetails = false;
          });
        },
        onBack: () {
          setState(() {
            _showBankDetails = false;
          });
        },
      );
    }

    // Original Withdraw Funds content
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // New gradient funds summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/background_3.png'),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row with icon and main funds
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side - Your available Funds
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Image.asset(
                              'assets/crown-1.png',
                              width: 20,
                              height: 20,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Opacity(
                            opacity: 0.60,
                            child: Text(
                              'Your available Funds',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                          ),
                          Text(
                            _formatRs(_availableFunds),
                            style: const TextStyle(
                              color: Color(0xFF3AF15D),
                              fontSize: 26,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Right side - Total Revenue
                    Row(
                      children: [
                        Container(
                          width: 3,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0),
                                Colors.white.withValues(alpha: 0.60),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Opacity(
                              opacity: 0.60,
                              child: Text(
                                'Total Revenue',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRs(_totalRevenueFetched),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Bottom row - Realizing Balance and Total Withdrawals
                Row(
                  children: [
                    // Realizing Balance
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 3,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.60),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Opacity(
                                    opacity: 0.60,
                                    child: Text(
                                      'Realizing Balance',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'Onest',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatRs(0),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),
                    // Total Withdrawals
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 3,
                                height: 38,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.60),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Opacity(
                                    opacity: 0.60,
                                    child: Text(
                                      'Total Withdrawals',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontFamily: 'Onest',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _totalWithdrawals.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Bank details
          const Text('Bank Details',
              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _selectedBank != null
                              ? (_selectedBank!['bankName']?.toString() ?? '-')
                              : 'Select Bank',
                          style: const TextStyle(
                            color: hintTextColor,
                            fontSize: 12,
                          )),
                      const SizedBox(height: 4),
                      Text(
                          _selectedBank != null
                              ? (_selectedBank!['accountNumber']?.toString() ?? '-')
                              : '-',
                          style: const TextStyle(color: textColor, fontSize: 14)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showBankDetails = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(225, 255, 255, 255),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: textColor),
                    ),
                    child: const Text('Change',
                        style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 12,
                            fontWeight: FontWeight.w300)),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount field
          CustomTextField(
              controller: _amountController,
              hintText: 'Enter Amount',
              keyboardType: TextInputType.number),
          const SizedBox(height: 12),

          // Note field
          CustomTextField(controller: _noteController, hintText: 'Note', maxLines: 2),

          const SizedBox(height: 20),

          // Withdrawal summary block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            constraints: const BoxConstraints(minHeight: 126),
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A3E).withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Withdrawal Summary',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),

                // Amount row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.60,
                      child: Text(
                        'Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.60,
                      child: Text(
                        _formatCurrency(_amount),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Commission row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.60,
                      child: Text(
                        '5% Commission',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.60,
                      child: Text(
                        _formatCurrency(_commission),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Total Withdrawal row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Opacity(
                      opacity: 0.60,
                      child: Text(
                        'Total Withdrawal Amount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Opacity(
                      opacity: 0.60,
                      child: Text(
                        _formatCurrency(_total),
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final rawText = _amountController.text.trim();
                final parsed = double.tryParse(rawText.replaceAll(RegExp(r'[^0-9\.]'), ''));
                if (parsed == null || parsed <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Enter a valid amount'), backgroundColor: Colors.red),
                  );
                  return;
                }
                if (_selectedBank == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please select bank details'), backgroundColor: Colors.red),
                  );
                  return;
                }
                try {
                  await FinanceService().createWithdrawal(
                    eventId: widget.event.externalEventId?.toString() ?? '',
                    amount: parsed,
                    bankDetails: {
                      'bankName': _selectedBank!['bankName']?.toString() ?? '',
                      'accountNumber': _selectedBank!['accountNumber']?.toString() ?? '',
                      'accountName': _selectedBank!['accountName']?.toString() ?? '',
                    },
                    note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
                  );
                  await _fetchSummary();
                  _amountController.clear();
                  _noteController.clear();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Withdrawal request submitted'),
                        backgroundColor: Colors.green),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Submit failed: $e'), backgroundColor: Colors.red),
                  );
                }
              },
              child: const Text('Submit Withdraw Request',
                  style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
