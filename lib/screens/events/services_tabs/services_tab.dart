import 'package:flutter/material.dart';
import 'package:spotseeker_app/screens/events/services_tabs/access_pro_services_tab.dart';
class ServicesTab extends StatefulWidget {
  const ServicesTab({Key? key}) : super(key: key);

  @override
  State<ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<ServicesTab> {
  bool _showAccessPro = false;

  void _openAccessPro() {
    setState(() {
      _showAccessPro = true;
    });
  }

  void _closeAccessPro() {
    setState(() {
      _showAccessPro = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(12),
        child: _showAccessPro
            ? AccessProServicesTab(onBack: _closeAccessPro)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Spotseeker Services',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ServiceItem(
                        title: 'Access Pro',
                        subtitle: 'Smart entry & attendee management made effortless.',
                        onTap: _openAccessPro,
                      ),
                      const SizedBox(height: 16),
                      const _ServiceItem(
                        title: 'Spot Pay',
                        subtitle: 'Secure, flexible, and reliable event payment system.',
                      ),
                      const SizedBox(height: 16),
                      const _ServiceItem(
                        title: 'Spotseeker Xpos',
                        subtitle: 'Create, customize, and send professional invitations with ease.',
                      ),
                      const SizedBox(height: 16),
                      const _ServiceItem(
                        title: 'Add Ambulance',
                        subtitle: 'Ensure safety and emergency readiness at every event.',
                      ),
                      const SizedBox(height: 16),
                      const _ServiceItem(
                        title: 'Face Painting',
                        subtitle: 'Add color, creativity, and fun to your event experience.',
                      ),
                      const SizedBox(height: 16),
                      const _ServiceItem(
                        title: 'Perfume Vending Machine',
                        subtitle: 'Bring a fresh and luxurious experience to your guests.',
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}

class _ServiceItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ServiceItem({required this.title, required this.subtitle, this.onTap});

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: ShapeDecoration(
        color: Colors.black.withOpacity(0.10),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1.0, color: Colors.white.withOpacity(0.12)),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Opacity(
                  opacity: 0.6,
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.south_east, color: Colors.white),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
