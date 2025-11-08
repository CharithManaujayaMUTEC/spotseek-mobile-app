import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/events_board_screen.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/about_us_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/add_new_coordinator.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/app_permissions_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/invoice_tabs/invoice_generate_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/invoice_tabs/invoice_generated_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/invoice_tabs/invoice_rejected_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/invoice_tabs/invoice_tab.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/logo_and_assets_tab.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
import 'package:spotseeker_app/screens/events/profile_settings_screen.dart';
import 'package:spotseeker_app/screens/events/profile_tabs/coordinators_tab.dart';

enum ProfileInitialView { coordinators, rateCard, addcoordinators, invoicePending, invoiceRejected, invoiceGenerated, invoiceGenerate, invoice, logoandassets, apppermissions, notifications, aboutus }

class ProfileTabScreen extends StatelessWidget {
  const ProfileTabScreen({
    super.key,
    this.initialView = ProfileInitialView.coordinators,
  });

  final ProfileInitialView initialView;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: _buildBody(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (initialView) {
      case ProfileInitialView.rateCard:
        return Center(
          child: Image.asset(
            'assets/coming-soon-banner.png',
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
        );
      case ProfileInitialView.coordinators:
        return const CoordinatorsTab();
      case ProfileInitialView.addcoordinators:
        return const AddNewCoordinator();
      case ProfileInitialView.logoandassets:
        return const LogoAndAssetsTab();
      case ProfileInitialView.notifications:
        return Center(
          child: Image.asset(
            'assets/coming-soon-banner.png',
            fit: BoxFit.contain,
            width: MediaQuery.of(context).size.width * 0.8,
          ),
        );
      case ProfileInitialView.apppermissions:
        return const AppPermissionsTab();
      case ProfileInitialView.aboutus:
        return const AboutUs();

      // Invoice Tabs
      case ProfileInitialView.invoiceGenerate:
        return const InvoiceTabGenerate();
      case ProfileInitialView.invoicePending:
        return const InvoiceTab();
      case ProfileInitialView.invoiceRejected:
        return const InvoiceTabRejected();
      case ProfileInitialView.invoiceGenerated:
        return const InvoiceTabGenerated();
      case ProfileInitialView.invoice:
        return const InvoiceTab();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const EventsBoardScreen()),
                              ),
            icon: const Icon(Icons.arrow_back, color: textColor),
          ),
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
                            border: Border.all(color: const Color(0xFF0B0417), width: 1),
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
}
