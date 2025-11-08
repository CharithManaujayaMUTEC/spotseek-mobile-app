import 'package:flutter/material.dart';

class AppPermissionsTab extends StatefulWidget {
  const AppPermissionsTab({Key? key}) : super(key: key);

  static const List<Map<String, String>> _permissions = [
    {'label': 'Camera Access', 'icon': 'assets/camera.png'},
    {'label': 'Gallery Access', 'icon': 'assets/gallery.png'},
    {'label': 'Storage Access', 'icon': 'assets/storage.png'},
    {'label': 'WhatsApp Access', 'icon': 'assets/whatsapp.png'},
  ];

  @override
  State<AppPermissionsTab> createState() => _AppPermissionsTabState();
}

class _AppPermissionsTabState extends State<AppPermissionsTab>
    with SingleTickerProviderStateMixin {
  late final List<bool> _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = List<bool>.filled(AppPermissionsTab._permissions.length, true);
  }

  void _toggle(int index) {
    setState(() {
      _enabled[index] = !_enabled[index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: -1208,
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
            top: -253,
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
            top: -213,
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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Permission',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withOpacity(0.12), width: 1),
                  ),
                  child: Column(
                    children: List.generate(
                      AppPermissionsTab._permissions.length * 2 - 1,
                      (index) {
                        if (index.isOdd) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Divider(color: Colors.white.withOpacity(0.10), height: 1),
                              const SizedBox(height: 12),
                            ],
                          );
                        }
                        final int i = index ~/ 2;
                        final bool isOn = _enabled[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 20,
                                    height: 20,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: Image.asset(
                                        AppPermissionsTab._permissions[i]['icon']!,
                                        width: 20,
                                        height: 20,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    AppPermissionsTab._permissions[i]['label']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontFamily: 'Onest',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),

                              GestureDetector(
                                onTap: () => _toggle(i),
                                child: SizedBox(
                                  width: 33,
                                  height: 20,
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 180),
                                        width: 33,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: isOn
                                              ? const Color(0xFFE50914)
                                              : Colors.white.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                      ),
                                      AnimatedPositioned(
                                        duration: const Duration(milliseconds: 180),
                                        left: isOn ? 14.24 : 1.29,
                                        top: 1.29,
                                        child: Container(
                                          width: 17.47,
                                          height: 17.42,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Color(0x1E000000),
                                                blurRadius: 7,
                                                offset: Offset(0, 3),
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
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
