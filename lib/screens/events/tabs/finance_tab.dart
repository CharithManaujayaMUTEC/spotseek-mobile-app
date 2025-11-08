import 'package:flutter/material.dart';
import 'package:spotseeker_app/models/event_model.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/custom_textfield.dart';

class FinanceTab extends StatefulWidget {
  final EventModel event;

  const FinanceTab({super.key, required this.event});

  @override
  State<FinanceTab> createState() => _FinanceTabState();
}

class _FinanceTabState extends State<FinanceTab> {
  int _selectedSubTab = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Sub-tab navigation (horizontally scrollable)
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          height: 40,
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

        // Content
        Expanded(
          child: IndexedStack(
            index: _selectedSubTab,
            children: [
              _SalesSubTab(),
              _FinanceBreakdownSubTab(),
              _WithdrawFundsSubTab(),
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
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        decoration: BoxDecoration(
          color: isSelected ? textColor : backgroundColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? textColor : hintTextColor.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
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
  @override
  State<_SalesSubTab> createState() => _SalesSubTabState();
}

class _SalesSubTabState extends State<_SalesSubTab> {
  String _selectedFilter = 'Today';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showDropdown = false;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
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
          _startDate = picked;
        } else {
          _endDate = picked;
        }
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
          // Filters
          Row(
            children: [
              // Today dropdown
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _showDropdown = !_showDropdown),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_selectedFilter, style: const TextStyle(color: textColor, fontSize: 13)),
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
              // Start date picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, color: textColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _startDate != null ? '${_startDate!.day}/${_startDate!.month}' : 'Start',
                            style: TextStyle(
                              color: _startDate != null ? textColor : hintTextColor,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // End date picker
              Expanded(
                child: GestureDetector(
                  onTap: () => _selectDate(context, false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.calendar_today, color: textColor, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _endDate != null ? '${_endDate!.day}/${_endDate!.month}' : 'End',
                            style: TextStyle(
                              color: _endDate != null ? textColor : hintTextColor,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Dropdown menu
          if (_showDropdown) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: ['Today', 'Last 7 days', 'Last 30 days', 'Last Month', 'Last 3 Month']
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
                                Text(e, style: const TextStyle(color: textColor, fontSize: 13)),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],

          const SizedBox(height: 20),

          // Donut chart
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
            ),
            child: Column(
              children: [
                // Donut
                SizedBox(
                  height: 220,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _DonutChartPainter(),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Total Sales Revenue',
                            style: TextStyle(color: hintTextColor, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Rs. 2,280,000',
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Legend
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _buildLegend('42%', 'Tier 01', Colors.pink.shade300),
                    _buildLegend('20%', 'Tier 02', Colors.purple.shade700),
                    _buildLegend('15%', 'Tier 03', Colors.purple.shade900),
                    _buildLegend('6%', 'Tier 04', Colors.purple.shade800),
                    _buildLegend('10%', 'Tier 05', Colors.red.shade900),
                    _buildLegend('7%', 'Tier 06', Colors.pink.shade600),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Package Wise Sales', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          
          // Package cards
          _buildPackageCard(
            tier: 'Tier 01',
            price: 'Rs. 2,500,000',
            soldOut: '500 Sold out',
            soldOutColor: primaryColor,
            ticketPrice: 'Rs. 5,000',
            releaseCount: '500',
            startDate: '25th Aug | 9:00AM',
            endDate: '25th Aug | 9:00AM',
          ),
          const SizedBox(height: 12),
          _buildPackageCard(
            tier: 'Tier 02',
            price: 'Rs. 560,000',
            soldOut: '160 Sold Out',
            soldOutColor: Colors.green,
            ticketPrice: 'Rs. 3,500',
            releaseCount: '200',
            startDate: '25th Aug | 9:00AM',
            endDate: '25th Aug | 9:00AM',
            countdown: '23h : 42m',
          ),
          const SizedBox(height: 12),
          _buildPackageCard(
            tier: 'Tier 03',
            price: 'Rs. 540,000',
            soldOut: '270 Sold Out',
            soldOutColor: Colors.green,
            ticketPrice: 'Rs. 2,000',
            releaseCount: '300',
            startDate: '25th Aug | 9:00AM',
            endDate: '25th Aug | 9:00AM',
          ),
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
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
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
                    Text(tier, style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
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
                child: Text(soldOut, style: TextStyle(color: soldOutColor, fontSize: 10, fontWeight: FontWeight.w600)),
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
                Text('Countdown', style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 12)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A3E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(countdown, style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
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
        Text(value, style: const TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLegend(String percent, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$percent\n$label', style: TextStyle(color: hintTextColor.withValues(alpha: 0.9), fontSize: 10), textAlign: TextAlign.left),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40;

    final data = [
      (0.42, Colors.pink.shade300),
      (0.07, Colors.pink.shade600),
      (0.10, Colors.red.shade900),
      (0.06, Colors.purple.shade800),
      (0.15, Colors.purple.shade900),
      (0.20, Colors.purple.shade700),
    ];

    double startAngle = -90 * (3.14159 / 180);
    for (var segment in data) {
      paint.color = segment.$2;
      final sweepAngle = segment.$1 * 2 * 3.14159;
      canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ============ FINANCE BREAKDOWN SUB-TAB ============
class _FinanceBreakdownSubTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total revenue
          const Text('Total Revenue', style: TextStyle(color: hintTextColor, fontSize: 13)),
          const SizedBox(height: 4),
          const Text('Rs. 3,978,000', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Bar chart
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
                // Y-axis labels
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Y axis
                      SizedBox(
                        width: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: ['150k', '120k', '90k', '60k', '30k', '0']
                              .map((e) => Text(e, style: TextStyle(color: hintTextColor.withValues(alpha: 0.7), fontSize: 10)))
                              .toList(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Bars
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar(60, 'Week 1'),
                            const SizedBox(width: 8),
                            _buildBar(80, 'Week 2'),
                            const SizedBox(width: 8),
                            _buildBar(110, 'Week 3'),
                            const SizedBox(width: 8),
                            _buildBar(140, 'Week 4'),
                            const SizedBox(width: 8),
                            _buildBar(90, 'Week 5'),
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

          // Fund Withdrawals
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Fund Withdrawals', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {},
                child: const Text('View All', style: TextStyle(color: primaryColor, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Withdrawal cards
          _buildWithdrawalCard('Venue Booking', '03 Oct 2025', 'Rs. 140,000', 'Pending', Colors.orange),
          const SizedBox(height: 12),
          _buildWithdrawalCard('Staff Payment', '03 Oct 2025', 'Rs. 40,000', 'Transferred', Colors.green),
          const SizedBox(height: 12),
          _buildWithdrawalCard('Facebook Ads', '03 Oct 2025', 'Rs. 12,000', 'Transferred', Colors.green),
          const SizedBox(height: 12),
          _buildWithdrawalCard('Sound & Lighting', '03 Oct 2025', 'Rs. 220,000', 'Rejected', Colors.red),
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
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildWithdrawalCard(String title, String date, String amount, String status, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(date, style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: const TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(status, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}

// ============ WITHDRAW FUNDS SUB-TAB ============
class _WithdrawFundsSubTab extends StatefulWidget {
  @override
  State<_WithdrawFundsSubTab> createState() => _WithdrawFundsSubTabState();
}

class _WithdrawFundsSubTabState extends State<_WithdrawFundsSubTab> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Funds summary
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your available Funds', style: TextStyle(color: hintTextColor, fontSize: 12)),
                    const SizedBox(height: 4),
                    const Text('Rs. 245,000', style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Total Revenue', style: TextStyle(color: hintTextColor, fontSize: 11)),
                    const SizedBox(height: 2),
                    const Text('Rs. 545,000', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    const Text('Total Withdrawals', style: TextStyle(color: hintTextColor, fontSize: 11)),
                    const SizedBox(height: 2),
                    const Text('Rs. 300,000', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Bank details
          const Text('Bank Details', style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(colors: [Colors.orange.shade700, Colors.red.shade700]),
                  ),
                  child: const Icon(Icons.account_balance, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bank Of Ceylon', style: TextStyle(color: textColor, fontSize: 14, fontWeight: FontWeight.w600)),
                      SizedBox(height: 4),
                      Text('21345329', style: TextStyle(color: hintTextColor, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: textColor),
                  ),
                  child: const Text('Change', style: TextStyle(color: textColor, fontSize: 12)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount field
          CustomTextField(controller: _amountController, hintText: 'Enter Amount', keyboardType: TextInputType.number),
          const SizedBox(height: 12),

          // Note field
          CustomTextField(controller: _noteController, hintText: 'Note', maxLines: 3),

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
              onPressed: () {
                // Handle submit
              },
              child: const Text('Submit Withdraw Request', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
