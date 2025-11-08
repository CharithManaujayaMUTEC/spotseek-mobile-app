import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotseeker_app/screens/auth/become_partner_screen.dart';
import 'package:spotseeker_app/screens/auth/login_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/glow_line_painter.dart' hide primaryColor;

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with SingleTickerProviderStateMixin {
  final List<String> _backgroundImages = [
    'assets/1_spanning_bg.jpg',
    'assets/2_spanning_bg.jpg',
    'assets/3_spanning_bg.jpg',
    'assets/4_spanning_bg.jpg',
  ];
  
  int _currentImageIndex = 0;
  Timer? _slideTimer;
  late AnimationController _zoomController;
  late Animation<double> _zoomAnimation;

  @override
  void initState() {
    super.initState();
    
    // Make status bar transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
    
    // Initialize zoom animation controller
    _zoomController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    // Zoom from 1.0 to 1.18 to create zoom effect while always filling screen
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.18).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
    
    // Start the first zoom animation
    _zoomController.forward();
    
    // Set up timer to change images every 5 seconds
    _slideTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
      });
      
      // Reset and restart zoom animation
      _zoomController.reset();
      _zoomController.forward();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _zoomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double panelHeight = MediaQuery.of(context).size.height * 0.35;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated background slideshow with zoom effect - extends behind status bar
          ClipRect(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 800),
              child: AnimatedBuilder(
                key: ValueKey<int>(_currentImageIndex),
                animation: _zoomAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _zoomAnimation.value,
                    alignment: Alignment.topCenter,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.25), BlendMode.darken),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            width: MediaQuery.of(context).size.width,
                            child: Image.asset(
                              _backgroundImages[_currentImageIndex],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            // This Stack is the key to the fix. It layers the panel and the content.
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // Layer 1: The Panel Hero (now just the background)
                Hero(
                  tag: 'background-panel',
                  child: ClipPath(
                    clipper: OnboardingShapeClipper(),
                    child: Container(
                      height: panelHeight,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0.0, -1.5),
                          radius: 1.5,
                          colors: [Color(0xFF2E2250), Color(0xFF251A39), Color(0xFF0C0911)],
                          stops: [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),

                // Layer 2: The Content (Logo Hero, Buttons) placed ON TOP of the panel
                SizedBox(
                  height: panelHeight,
                  child: Material(
                    type: MaterialType.transparency,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Spacer(flex: 2),
                        // The Logo Hero is now a sibling of the Panel Hero
                        Hero(
                          tag: 'spotseeker-logo',
                          child: SizedBox(
                              width: 140,
                              child: Image.asset('assets/spotseeker_logo.png'),
                            ),
                        ),
                        const Spacer(flex: 2),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white, width: 1.5),
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(SharedAxisPageRoute(page: const BecomePartnerScreen()));
                            },
                            child: const Text('BECOME A PARTNER', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 48.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              minimumSize: const Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                            },
                            child: const Text('ALREADY A PARTNER', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),

                // Layer 3: The Glow Line (on top of everything)
                SizedBox(
                  height: panelHeight,
                  child: const CustomPaint(
                    painter: GlowLinePainter(),
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

class OnboardingShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.lineTo(0.0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 30);
    path.quadraticBezierTo(size.width / 2, -20, 0, 30);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class SharedAxisPageRoute extends PageRouteBuilder {
  final Widget page;
  SharedAxisPageRoute({required this.page})
      : super(
          transitionDuration: const Duration(milliseconds: 600),
          reverseTransitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
}