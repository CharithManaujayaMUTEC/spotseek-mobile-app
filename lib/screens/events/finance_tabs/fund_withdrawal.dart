import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:intl/intl.dart';

/// Fund Withdrawal screen
/// - Title with a day-filter dropdown (default: Today)
/// - Subtitles grouped by day (Today, Yesterday, or date)
/// - Withdrawal cards styled like Finance Breakdown
class FundWithdrawalScreen extends StatefulWidget {
  const FundWithdrawalScreen({super.key});

  @override
  State<FundWithdrawalScreen> createState() => _FundWithdrawalScreenState();
}

class _FundWithdrawalScreenState extends State<FundWithdrawalScreen> {
  String _selectedFilter = 'Today';

  // Sample withdrawal data. In real use this will be replaced with data from the API.
  final List<Map<String, dynamic>> _allWithdrawals = [
    {
      'title': 'Venue Booking',
      'date': DateTime.now(),
      'amount': 'Rs. 140,000',
      'status': 'Pending',
      'statusColor': Colors.orange,
    },
    {
      'title': 'Staff Payment',
      'date': DateTime.now(),
      'amount': 'Rs. 40,000',
      'status': 'Transferred',
      'statusColor': Colors.green,
    },
    {
      'title': 'Facebook Ads',
      'date': DateTime.now().subtract(const Duration(days: 1)),
      'amount': 'Rs. 12,000',
      'status': 'Transferred',
      'statusColor': Colors.green,
    },
    {
      'title': 'Sound & Lighting',
      'date': DateTime.now().subtract(const Duration(days: 2)),
      'amount': 'Rs. 220,000',
      'status': 'Rejected',
      'statusColor': Colors.red,
    },
    {
      'title': 'Equipment Rental',
      'date': DateTime.now().subtract(const Duration(days: 3)),
      'amount': 'Rs. 18,500',
      'status': 'Transferred',
      'statusColor': Colors.green,
    },
  ];

  List<Map<String, dynamic>> get _filteredWithdrawals {
    final now = DateTime.now();
    if (_selectedFilter == 'Today') {
      // Include today's and the previous 3 days so users can quickly
      // view recent withdrawals (Today, Yesterday, 2 days ago, 3 days ago).
      return _allWithdrawals.where((w) {
        final d = w['date'] as DateTime;
        final diff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
        return diff >= 0 && diff <= 3;
      }).toList();
    }
    if (_selectedFilter == 'Last 7 days') {
      final cutoff = now.subtract(const Duration(days: 7));
      return _allWithdrawals.where((w) {
        final d = w['date'] as DateTime;
        return d.isAfter(cutoff) || d.isAtSameMomentAs(cutoff);
      }).toList();
    }
    if (_selectedFilter == 'Last 30 days') {
      final cutoff = now.subtract(const Duration(days: 30));
      return _allWithdrawals.where((w) {
        final d = w['date'] as DateTime;
        return d.isAfter(cutoff) || d.isAtSameMomentAs(cutoff);
      }).toList();
    }
    if (_selectedFilter == 'Last Month') {
      // Previous calendar month: from the 1st of last month to the start of this month (exclusive)
      final startOfThisMonth = DateTime(now.year, now.month, 1);
      final startOfLastMonth = DateTime(now.year, now.month - 1, 1);
      return _allWithdrawals.where((w) {
        final d = w['date'] as DateTime;
        return !d.isBefore(startOfLastMonth) && d.isBefore(startOfThisMonth);
      }).toList();
    }
    if (_selectedFilter == 'Last 3 Month') {
      // Previous 3 full calendar months (not including current month)
      final startOfThisMonth = DateTime(now.year, now.month, 1);
      final startOfThreeMonthsAgo = DateTime(now.year, now.month - 3, 1);
      return _allWithdrawals.where((w) {
        final d = w['date'] as DateTime;
        return !d.isBefore(startOfThreeMonthsAgo) && d.isBefore(startOfThisMonth);
      }).toList();
    }
    // Default: return all
    return _allWithdrawals;
  }

  // Group by day label (Today / Yesterday / dd MMM yyyy)
  Map<String, List<Map<String, dynamic>>> _groupByDay(List<Map<String, dynamic>> list) {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    final now = DateTime.now();
    for (var item in list) {
      final d = item['date'] as DateTime;
      String key;
      final diff = DateTime(now.year, now.month, now.day).difference(DateTime(d.year, d.month, d.day)).inDays;
      if (diff == 0) {
        key = 'Today';
      } else if (diff == 1) {
        key = 'Yesterday';
      } else {
        key = DateFormat('dd MMM yyyy').format(d);
      }
      groups.putIfAbsent(key, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredWithdrawals;
    final groups = _groupByDay(filtered);
    // Prepare sorted entries (date-descending) for rendering.
    final entries = groups.entries.toList();
    DateTime _keyToDate(String key) {
      final now = DateTime.now();
      if (key == 'Today') return DateTime(now.year, now.month, now.day);
      if (key == 'Yesterday') return DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));
      try {
        return DateFormat('dd MMM yyyy').parse(key);
      } catch (_) {
        return DateTime(1970);
      }
    }
    entries.sort((a, b) => _keyToDate(b.key).compareTo(_keyToDate(a.key)));

    return Container(
      decoration: backgroundGradient(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Title row with dropdown
          Row(
            children: [
              const Expanded(
                child: Text('Fund Withdrawal', style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.deepPurple.shade300.withValues(alpha: 0.4)),
                ),
                // DropdownButton requires a Material ancestor for the menu overlay.
                // Wrap with a transparent Material so the widget can be used anywhere.
                child: Material(
                  color: Colors.transparent,
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    underline: const SizedBox.shrink(),
                    dropdownColor: const Color(0xFF1A1A2E),
          items: ['Today', 'Last 7 days', 'Last 30 days', 'Last Month', 'Last 3 Month', 'All']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: textColor))))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        _selectedFilter = v;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // If no results show message
          if (filtered.isEmpty) ...[
            const SizedBox(height: 24),
            Center(
              child: Opacity(opacity: 0.7, child: Text('No withdrawals for selected range', style: TextStyle(color: hintTextColor.withValues(alpha: 0.9))))
            ),
          ] else ...[
            for (var entry in entries) ...[
              const SizedBox(height: 12),
              Text(entry.key, style: const TextStyle(color: hintTextColor, fontSize: 13)),
              const SizedBox(height: 8),
              Column(
                children: entry.value.map((w) => _buildWithdrawalCard(w)).toList(),
              ),
            ],
          ],
          ],
        ),
      ),
    );
  }

  Widget _buildWithdrawalCard(Map<String, dynamic> data) {
    final String title = data['title'] as String;
    final DateTime date = data['date'] as DateTime;
    final String amount = data['amount'] as String;
    final String status = data['status'] as String;
    final Color statusColor = data['statusColor'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                Text(DateFormat('dd MMM yyyy').format(date), style: TextStyle(color: hintTextColor.withValues(alpha: 0.8), fontSize: 11)),
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
