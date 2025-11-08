import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotseeker_app/screens/auth/become_partner_screen.dart';
import 'package:spotseeker_app/screens/auth/login_screen.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/glow_line_painter.dart' hide primaryColor;
import 'package:spotseeker_app/widgets/background_gradient.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
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
  
  // Main intro animation controller
  late AnimationController _introController;
  
  // Layer 1: Logo animation (fastest - center to position)
  final GlobalKey _logoKey = GlobalKey();
  late Animation<Offset> _logoOffsetAnimation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoScale;
  
  // Layer 2: Buttons animation (medium speed - bottom to position)
  late Animation<double> _buttonsOffset;
  late Animation<double> _buttonsOpacity;
  
  // Layer 3: Background + panels animation (slowest - top to position)
  late Animation<double> _backgroundOffset;
  
  bool _showOverlayLogo = true;
  // overlay logo size will be computed relative to screen size at runtime
  // start with a sensible fallback so build can run before the first frame callback
  double _overlayLogoSize = 100.0;

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
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _zoomAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _zoomController, curve: Curves.easeInOut),
    );
    
    _zoomController.forward();

    // Main intro animation controller - longer for layered effect
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    // LAYER 1: Logo - starts earliest
    // Create placeholder; real tweens will be created in _startIntroAnimation
    // IMPORTANT: Use intervals that end at 1.0 so all layers finish together,
    // but start at staggered times so they appear sequentially.
    _logoOffsetAnimation = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic)),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeIn),
      ),
    );

    // LAYER 2: Buttons - start after logo but end at the same time
    _buttonsOffset = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)),
    );
    _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _introController, curve: const Interval(0.25, 1.0, curve: Curves.easeIn)),
    );

    // LAYER 3: Background + Panels - start latest but also end at 1.0
    _backgroundOffset = Tween<double>(begin: -1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _introController.addListener(() => setState(() {}));

    // Start animations after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIntroAnimation());

    // Set up timer to change images
    _slideTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      setState(() {
        _currentImageIndex = (_currentImageIndex + 1) % _backgroundImages.length;
      });
      
      _zoomController.reset();
      _zoomController.forward();
    });
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    _zoomController.dispose();
    _introController.dispose();
    super.dispose();
  }

  void _startIntroAnimation() {
    final Size screenSize = MediaQuery.of(context).size;
    // compute sizes relative to the screen so animation looks consistent across devices
    _overlayLogoSize = (screenSize.shortestSide * 0.18).clamp(56.0, 140.0);
    final Offset begin = Offset(
      (screenSize.width - _overlayLogoSize) / 2,
      (screenSize.height - _overlayLogoSize) / 2,
    );

    // compute panelHeight relative to screen for button offsets
    final double panelHeight = screenSize.height * 0.35;

    final renderObject = _logoKey.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      // Global position (top-left) of the in-panel logo widget
      final Offset targetGlobal = renderObject.localToGlobal(Offset.zero);

      // Adjust this value to move the overlay landing position vertically.
      // Positive -> move downward; negative -> move upward.
      const double endYOffset = -24.5; // change as needed

      // Compute the final offset including the vertical tweak
      final Offset end = Offset(targetGlobal.dx, targetGlobal.dy + endYOffset);

      setState(() {
        _logoOffsetAnimation = Tween<Offset>(begin: begin, end: end).animate(
          CurvedAnimation(
            parent: _introController,
            // logo starts immediately and runs until the controller completes
            curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
          ),
        );
        // Ensure logo opacity also follows the global end time so visuals finish together
        _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _introController, curve: const Interval(0.0, 1.0, curve: Curves.easeIn)),
        );

        // Recreate buttons tween using the actual panelHeight so the slide-in distance scales
        // Buttons start later (stagger) but end together at 1.0
        _buttonsOffset = Tween<double>(begin: panelHeight * 0.6, end: 0.0).animate(
          CurvedAnimation(parent: _introController, curve: const Interval(0.25, 1.0, curve: Curves.easeOutCubic)),
        );
        _buttonsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _introController, curve: const Interval(0.25, 1.0, curve: Curves.easeIn)),
        );
      });

      _introController.forward().whenComplete(() {
        setState(() {
          _showOverlayLogo = false;
        });
      });
    } else {
      setState(() {
        _showOverlayLogo = false;
      });
      _introController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double panelHeight = MediaQuery.of(context).size.height * 0.35;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: backgroundGradient(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // BACKGROUND: static full-screen background image (behind the animated layers)
            Positioned.fill(
              // Radial gradient background behind all animated layers.
              child: Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.0, -0.6),
                    radius: 1.5,
                    colors: [
                      Color(0xFF2E2250),
                      Color(0xFF251A39),
                      Color(0xFF0C0911),
                    ],
                    stops: [0.0, 0.4, 1.0],
                  ),
                ),
              ),
            ),

            // LAYER 3: Background image + panels (slowest - from top)
            Transform.translate(
              offset: Offset(0, screenHeight * _backgroundOffset.value),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image - clipped to show only above the glow line
                  ClipPath(
                    clipper: TopOnlyClipper(panelHeight: panelHeight),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 800),
                      child: AnimatedBuilder(
                        key: ValueKey<int>(_currentImageIndex),
                        animation: _zoomAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _zoomAnimation.value,
                            alignment: Alignment.center,
                            child: ColorFiltered(
                              colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.15),
                                BlendMode.darken,
                              ),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height,
                                child: Image.asset(
                                  _backgroundImages[_currentImageIndex],
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Bottom panels
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // Glow line - ensure it has full available width so painters get correct size
                        SizedBox(
                          height: panelHeight,
                          width: double.infinity,
                          child: const CustomPaint(
                            painter: GlowLinePainter(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 1: Logo (fastest - center to position)
            if (_showOverlayLogo)
              Positioned(
                // Nudge slightly left and up from the animated target so the
                // overlay lands a bit offset visually.
                left: _logoOffsetAnimation.value.dx + 18,
                top: _logoOffsetAnimation.value.dy + 9,
                width: _overlayLogoSize,
                height: _overlayLogoSize,
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: Image.asset('assets/spotseeker_logo.png'),
                ),
              ),

            // In-panel logo (appears when overlay finishes) - positioned higher in panel
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: panelHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(height: panelHeight * 0.12),
                    Hero(
                      tag: 'spotseeker-logo',
                      child: Opacity(
                        opacity: _showOverlayLogo ? 0.0 : 1.0,
                        child: SizedBox(
                          key: _logoKey,
                          width: _overlayLogoSize,
                          child: Image.asset('assets/spotseeker_logo.png'),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),

            // LAYER 2: Buttons (medium speed - from bottom) - positioned lower
            Align(
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: Offset(0, _buttonsOffset.value),
                child: Opacity(
                  opacity: _buttonsOpacity.value,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: panelHeight * 0.15),
                    child: Material(
                      type: MaterialType.transparency,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48.0),
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white, width: 1.5),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  SharedAxisPageRoute(page: const BecomePartnerScreen()),
                                );
                              },
                              child: const Text(
                                'BECOME A PARTNER',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 48.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'ALREADY A PARTNER',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
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

// Clipper to show image only above the glow line
class TopOnlyClipper extends CustomClipper<Path> {
  final double panelHeight;
  
  TopOnlyClipper({required this.panelHeight});
  
  @override
  Path getClip(Size size) {
    final Path path = Path();
    
    // Start from top-left corner
    path.moveTo(0, 0);
    // Go to top-right corner
    path.lineTo(size.width, 0);
    // Go down to where the curve starts (right side)
    path.lineTo(size.width, size.height - panelHeight + 30);
    // Draw the curve (matching OnboardingShapeClipper but inverted)
    path.quadraticBezierTo(
      size.width / 2, 
      size.height - panelHeight - 20, 
      0, 
      size.height - panelHeight + 30
    );
    // Complete the path back to start
    path.lineTo(0, 0);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant TopOnlyClipper oldClipper) => 
    oldClipper.panelHeight != panelHeight;
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