import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'dart:math' as math;

class FormStepper extends StatelessWidget {
  final int currentStep;

  const FormStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStep(
              icon: Icons.corporate_fare,
              label: 'Company\nProfile',
              stepIndex: 0),
          _buildLine(
            isActive: currentStep >= 1, 
            isCurrent: currentStep == 0 || currentStep == 1,
            showAnimation: currentStep == 0,
            animateFromLeft: true,
          ),
          _buildStep(
              icon: Icons.person_outline,
              label: 'Organizer\nInfo',
              stepIndex: 1),
          _buildLine(
            isActive: currentStep >= 2, 
            isCurrent: currentStep == 1 || currentStep == 2,
            showAnimation: currentStep == 1,
            animateFromLeft: true,
          ),
          _buildStep(
              icon: Icons.handshake_outlined,
              label: 'Partnership\nAgreement',
              stepIndex: 2),
        ],
      ),
    );
  }

  Widget _buildLine({
    required bool isActive, 
    required bool isCurrent,
    required bool showAnimation,
    required bool animateFromLeft,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 23.25),
        child: showAnimation
            ? _AnimatedGradientLine(
                animateFromLeft: animateFromLeft,
                key: ValueKey('line_$currentStep'),
              )
            : Container(
                height: 1.5,
                color: isCurrent 
                    ? Colors.red 
                    : (isActive ? primaryColor : hintTextColor.withValues(alpha: 0.5)),
              ),
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required int stepIndex,
  }) {
    bool isActive = currentStep >= stepIndex;
    bool isCurrent = currentStep == stepIndex;
    bool isPassed = currentStep > stepIndex;

    return SizedBox(
      width: 48,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: isCurrent
                ? _AnimatedGlowingBorder(
                    icon: icon,
                    key: ValueKey('step_$stepIndex'),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isPassed 
                            ? Colors.red 
                            : hintTextColor.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                          border: (isActive && !isPassed)
                              ? Border.all(
                                  color: primaryColor,
                                  width: 1,
                                )
                              : null,
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? textColor : hintTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedGradientLine extends StatefulWidget {
  final bool animateFromLeft;

  const _AnimatedGradientLine({super.key, required this.animateFromLeft});

  @override
  State<_AnimatedGradientLine> createState() => _AnimatedGradientLineState();
}

class _AnimatedGradientLineState extends State<_AnimatedGradientLine>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showLineAnimation = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _startAnimationCycle();
  }

  void _startAnimationCycle() async {
    while (mounted) {
      // Show line animation
      setState(() => _showLineAnimation = true);
      await _controller.forward(from: 0.0);
      
      if (!mounted) break;
      
      // Hide line animation for circle phase
      setState(() => _showLineAnimation = false);
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (!mounted) break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GradientLinePainter(
            progress: _controller.value,
            animateFromLeft: widget.animateFromLeft,
            showAnimation: _showLineAnimation,
          ),
          size: const Size(double.infinity, 1.5),
        );
      },
    );
  }
}

class _GradientLinePainter extends CustomPainter {
  final double progress;
  final bool animateFromLeft;
  final bool showAnimation;

  _GradientLinePainter({
    required this.progress,
    required this.animateFromLeft,
    required this.showAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw base red line
    final basePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.butt;

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      basePaint,
    );

    if (!showAnimation) return;

    // Calculate gradient position with smooth back and forth
    double animProgress;
    if (progress < 0.5) {
      // First half: start to end
      animProgress = _easeInOutCubic(progress * 2);
    } else {
      // Second half: end to start
      animProgress = _easeInOutCubic(1 - ((progress - 0.5) * 2));
    }
    
    final gradientCenter = animateFromLeft 
        ? size.width * animProgress 
        : size.width * (1 - animProgress);

    // Draw gradient segments
    final gradientSpread = size.width * 0.15; // 15% of line width
    const segments = 20;
    const baseRed = Colors.red;

    for (int i = 0; i <= segments; i++) {
      final segmentProgress = i / segments;
      
      // Create gradient on both sides of the center point
      for (int side = -1; side <= 1; side += 2) {
        final offset = side * segmentProgress * gradientSpread;
        final x = gradientCenter + offset;
        
        if (x < 0 || x > size.width) continue;
        
        final lightness = 1.0 - segmentProgress;
        final opacity = lightness * 0.8;
        
        final segmentColor = Color.lerp(
          baseRed,
          Colors.red[100],
          lightness * 0.8,
        )!.withValues(alpha: opacity);
        
        final segmentPaint = Paint()
          ..color = segmentColor
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        final segmentWidth = size.width * 0.02;
        canvas.drawLine(
          Offset(x - segmentWidth / 2, size.height / 2),
          Offset(x + segmentWidth / 2, size.height / 2),
          segmentPaint,
        );
      }
    }
  }

  // Smooth easing function
  double _easeInOutCubic(double t) {
    return t < 0.5 
        ? 4 * t * t * t 
        : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  @override
  bool shouldRepaint(_GradientLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.showAnimation != showAnimation;
  }
}

class _AnimatedGlowingBorder extends StatefulWidget {
  final IconData icon;

  const _AnimatedGlowingBorder({super.key, required this.icon});

  @override
  State<_AnimatedGlowingBorder> createState() => _AnimatedGlowingBorderState();
}

class _AnimatedGlowingBorderState extends State<_AnimatedGlowingBorder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _showCircleAnimation = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _startAnimationCycle();
  }

  void _startAnimationCycle() async {
    // Wait for line animation to complete first
    await Future.delayed(const Duration(milliseconds: 1500));
    
    while (mounted) {
      // Show circle animation
      setState(() => _showCircleAnimation = true);
      await _controller.forward(from: 0.0);
      
      if (!mounted) break;
      
      // Hide circle animation for line phase
      setState(() => _showCircleAnimation = false);
      await Future.delayed(const Duration(milliseconds: 1500));
      
      if (!mounted) break;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowingBorderPainter(
            progress: _controller.value,
            showAnimation: _showCircleAnimation,
          ),
          child: Center(
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primaryColor,
                border: Border.all(
                  color: primaryColor,
                  width: 1,
                ),
              ),
              child: Icon(widget.icon, color: Colors.white, size: 20),
            ),
          ),
        );
      },
    );
  }
}

class _GlowingBorderPainter extends CustomPainter {
  final double progress;
  final bool showAnimation;

  _GlowingBorderPainter({
    required this.progress,
    required this.showAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    const baseRed = Colors.red;
    
    // Draw the base red border circle
    final borderPaint = Paint()
      ..color = baseRed
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, borderPaint);

    if (!showAnimation) return;

    // Simple continuous rotation around the circle
    final currentAngle = progress * 2 * math.pi;

    const gradientSpread = math.pi / 3; // 60 degrees spread on each side
    const segments = 30;
    
    // Draw arc with gradient effect
    for (int side = -1; side <= 1; side += 2) {
      for (int i = 0; i <= segments; i++) {
        final segmentProgress = i / segments;
        final segmentAngle = currentAngle + (side * segmentProgress * gradientSpread);
        
        final lightness = 1.0 - segmentProgress;
        final opacity = lightness;
        
        final segmentColor = Color.lerp(
          baseRed,
          Colors.red[100],
          lightness * 0.8,
        )!.withValues(alpha: opacity);

        final arcPaint = Paint()
          ..color = segmentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round;

        final arcRadius = radius;
        final startAngle = segmentAngle - 0.02;
        const sweepAngle = 0.04;
        
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: arcRadius),
          startAngle,
          sweepAngle,
          false,
          arcPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_GlowingBorderPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.showAnimation != showAnimation;
  }
}