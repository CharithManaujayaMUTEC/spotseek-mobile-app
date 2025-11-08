import 'dart:ui';
import 'package:flutter/material.dart';
class CustomerInfo {
  final String name;
  final String nic;
  final String email;
  final String phone;

  CustomerInfo({
    required this.name,
    required this.nic,
    required this.email,
    required this.phone,
  });
}

class OrderInfo {
  final String orderId;
  final String amount;

  OrderInfo({
    required this.orderId,
    required this.amount,
  });
}

class TierInfo {
  final String name;
  final String id;
  final int ticketCount;

  TierInfo({
    required this.name,
    required this.id,
    required this.ticketCount,
  });
}

class TicketOnboardingData {
  final CustomerInfo customer;
  final OrderInfo order;
  final List<TierInfo> tiers;
  final List<String>? history;

  TicketOnboardingData({
    required this.customer,
    required this.order,
    required this.tiers,
    this.history,
  });
}

class TicketOnboardingSheet extends StatefulWidget {
  final TicketOnboardingData data;
  final Function(Map<String, dynamic>)? onRefresh;

  const TicketOnboardingSheet({
    super.key,
    required this.data,
    this.onRefresh,
  });

  @override
  State<TicketOnboardingSheet> createState() => _TicketOnboardingSheetState();
}

class _TicketOnboardingSheetState extends State<TicketOnboardingSheet> {
  int _selectedTab = 0;
  late Map<String, List<int>> _selectedTickets;

  @override
  void initState() {
    super.initState();
    
    _selectedTickets = {};
    for (var tier in widget.data.tiers) {
      _selectedTickets[tier.id] = [];
    }
  }

  void _toggleTicket(String tier, int number) {
    setState(() {
      if (_selectedTickets[tier]!.contains(number)) {
        _selectedTickets[tier]!.remove(number);
      } else {
        _selectedTickets[tier]!.add(number);
      }
    });
  }

  int get _totalSelected {
    return _selectedTickets.values.fold(0, (sum, list) => sum + list.length);
  }

  @override
  Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final sheetHeight = screenHeight * 0.75;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: sheetHeight,
          decoration: const BoxDecoration(
            color: Color(0xFF12B013),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Verified Purchase!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.white.withValues(alpha: 0.20),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    _buildTab('Tickets', 0),
                    _buildTab('More Info.', 1),
                    _buildTab('History', 2),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                  child: _selectedTab == 0
                      ? _buildTicketsContent()
                      : _selectedTab == 1
                          ? _buildMoreInfoContent()
                          : _buildHistoryContent(),
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 48),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _totalSelected > 0 ? () {
                          Navigator.pop(context, {
                            'action': 'selected',
                            'count': _totalSelected,
                            'tickets': _selectedTickets,
                          });
                        } : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: _totalSelected > 0 ? Colors.white : Colors.transparent,
                            border: Border.all(
                              width: 1,
                              color: Colors.white.withValues(alpha: 0.60),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Onboard Selected ($_totalSelected)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _totalSelected > 0 ? const Color(0xFF12B013) : Colors.white,
                              fontSize: 14,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context, {
                            'action': 'all',
                            'tiers': widget.data.tiers,
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFBF0010),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Onboard All',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: 'Onest',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 20,
          top: -65,
          child: GestureDetector(
            onTap: () async {
              if (widget.onRefresh != null) {
                await widget.onRefresh!(_selectedTickets);
              }
            },
            child: SizedBox(
              width: 51,
              height: 51,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 51,
                      height: 51,
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 13.26,
                    top: 13.26,
                    child: SizedBox(
                      width: 24.48,
                      height: 24.48,
                      child: Icon(
                        Icons.refresh,
                        color: Color(0xFF12B013),
                        size: 24.48,
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

  Widget _buildTicketsContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            child: Text(
              'How many onboarding?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
          
          ...widget.data.tiers.asMap().entries.map((entry) {
            final index = entry.key;
            final tier = entry.value;
            return Column(
              children: [
                _buildTierCard(tier.name, tier.id, tier.ticketCount),
                if (index < widget.data.tiers.length - 1) const SizedBox(height: 12),
              ],
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildMoreInfoContent() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Opacity(
                opacity: 0.60,
                child: Text(
                  'Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.customer.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.customer.nic,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.customer.email,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.customer.phone,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 1,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Opacity(
                opacity: 0.60,
                child: Text(
                  'Order ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.order.orderId,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.data.order.amount,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    final hasHistory = widget.data.history != null && widget.data.history!.isNotEmpty;
    
    if (!hasHistory) {
      return Container(
        width: double.infinity,
        height: 200,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'No history available yet.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      );
    }
    
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widget.data.history!.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            item,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w400,
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.80,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
            decoration: BoxDecoration(
              border: isSelected
                  ? const Border(
                      bottom: BorderSide(width: 2, color: Colors.white),
                    )
                  : null,
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTierCard(String tierName, String tierId, int ticketCount) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.white.withValues(alpha: 0.20),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Text(
              tierName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Color(0xFF0B6A0B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: List.generate(
                ticketCount,
                (index) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index > 0 ? 4 : 0,
                      right: index < ticketCount - 1 ? 4 : 0,
                    ),
                    child: _buildTicketButton(tierId, index + 1),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketButton(String tier, int number) {
    final isSelected = _selectedTickets[tier]?.contains(number) ?? false;
    
    return GestureDetector(
      onTap: () => _toggleTicket(tier, number),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : const Color(0xFF328232),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$number',
              style: TextStyle(
                color: isSelected ? const Color(0xFF0B6A0B) : Colors.white,
                fontSize: 18,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              const Icon(
                Icons.done_all,
                color: Color(0xFF0B6A0B),
                size: 18,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>?> showTicketOnboardingSheet(
  BuildContext context, 
  TicketOnboardingData data,
  {Function(Map<String, dynamic>)? onRefresh}
) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.transparent,
    builder: (context) => Stack(
      children: [
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
        TicketOnboardingSheet(data: data, onRefresh: onRefresh),
      ],
    ),
  );
}

TicketOnboardingData mockTicketOnboardingData({
  String customerName = 'Janith Akalanka',
  String nic = '985656895V',
  String email = 'riverside98@gmail.com',
  String phone = '071-1492577',
  String orderId = 'DE156416465CDDSFSF',
  String amount = 'LKR 98,750.00',
  List<int>? ticketsPerTier,
}) {
  ticketsPerTier ??= [3, 2];

  final tiers = <TierInfo>[];
  for (var i = 0; i < ticketsPerTier.length; i++) {
    tiers.add(TierInfo(
      name: 'Tier ${i + 2}',
      id: 'tier${i + 2}',
      ticketCount: ticketsPerTier[i],
    ));
  }

  return TicketOnboardingData(
    customer: CustomerInfo(name: customerName, nic: nic, email: email, phone: phone),
    order: OrderInfo(orderId: orderId, amount: amount),
    tiers: tiers,
    history: null,
  );
}