import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/profile_tab_screen.dart';

class CoordinatorsTab extends StatelessWidget {
  const CoordinatorsTab({super.key});

  final List<Map<String, String>> _coordinators = const [
    {'name': 'Ayesha Fernando', 'subtitle': 'Live Stat'},
    {'name': 'Dilani Weerasinghe', 'subtitle': 'Achievements'},
    {'name': 'Harith Jayasuriya', 'subtitle': 'Sales'},
    {'name': 'Sanduni Abeysekara', 'subtitle': 'Finance Breakdown'},
    {'name': 'Nuwan Bandara', 'subtitle': 'Withdraw Funds'},
    {'name': 'Maleesha Rathnayake', 'subtitle': 'QR Scan'},
    {'name': 'Kavindu Senanayake', 'subtitle': 'QR Scan'},
    {'name': 'Tharushi Gunawardena', 'subtitle': 'Create Invitation'},
    {'name': 'Isuru Liyanage', 'subtitle': 'Bulk Upload'},
    {'name': 'Shenali Silva', 'subtitle': 'SMS Campaign & Email Campaign'},
    {'name': 'Thisara Madushanka', 'subtitle': 'Services'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: -918,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 3345,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(0.50, 0.99),
                  end: const Alignment(0.50, 0.96),
                  colors: [Colors.black, Colors.black.withOpacity(0.0)],
                ),
              ),
            ),
          ),

          Positioned(
            left: -138,
            top: -249,
            child: Opacity(
              opacity: 0.15,
              child: Container(
                width: 653,
                height: 142,
                decoration: const ShapeDecoration(
                  color: Color(0xFF653BFF),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),
          Positioned(
            left: 69,
            top: -209,
            child: Opacity(
              opacity: 0.50,
              child: Container(
                width: 238,
                height: 53,
                decoration: const ShapeDecoration(
                  color: Color(0xFF653BFF),
                  shape: OvalBorder(),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 1),
                const Text(
                  'Coordinators',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProfileTabScreen(
                                  initialView: ProfileInitialView.addcoordinators,
                                ),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 54,
                    padding: const EdgeInsets.only(left: 8, right: 16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.3),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Opacity(
                          opacity: 0.60,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: Icon(Icons.add, color: Colors.white, size: 20),
                          ),
                        ),
                        SizedBox(width: 12),
                        Opacity(
                          opacity: 0.60,
                          child: Text(
                            'Add New Coordinator',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Coordinator List',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Expanded(
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: _coordinators.length,
                      separatorBuilder: (context, index) => Divider(
                        color: Colors.white.withOpacity(0.10),
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final item = _coordinators[index];
                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
                            title: Text(
                              item['name']!,
                              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w400),
                            ),
                            subtitle: Opacity(
                              opacity: 0.60,
                              child: Text(
                                item['subtitle']!,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
