import 'package:flutter/material.dart';
import 'dart:ui' as ui; // for ui.Gradient

class GlowLinePainter extends CustomPainter {
  const GlowLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // The path remains the same, as it correctly matches the clipper
    final Path path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width / 2, -20, size.width, 30);

    // Draw a red line following the same quadratic curve.
    // Use a soft glow (wider, blurred stroke) underneath, then the sharp 5px line.

    // Build a radial shader that matches the panel gradient from the screen.
    // Colors translated to valid Color constructors (the first entry was
    // originally written with fractional components).
    final List<Color> gradientColors = [
      const Color.fromRGBO(21, 14, 14, 1.0), // approx of 0.082,0.055,0.055
      const Color(0xFFE50914),
      const Color.fromARGB(255, 255, 95, 103),
      const Color(0xFFE50914),
      const Color(0xFF000000),
    ];
    final List<double> stops = [0.0, 0.2, 0.5, 0.8, 1.0];

    // Convert Alignment(0.0, 1.5) into an Offset in the paint box.
    final double centerX = size.width * (0.0 * 0.5 + 0.5); // = 0.5 * width
    final double centerY = size.height * (1.5 * 0.5 + 0.5); // = 1.25 * height
    final Offset shaderCenter = Offset(centerX, centerY);

    // Radius expressed as a fraction of the shortest side in the original
    // BoxDecoration; approximate by multiplying with the shortestSide.
    final double shaderRadius = 1.5 * size.shortestSide;

    final ui.Shader radialShader = ui.Gradient.radial(
      shaderCenter,
      shaderRadius,
      gradientColors,
      stops,
      ui.TileMode.clamp,
    );

    // Core line uses the radial shader (5px) — glow removed per request
    final Paint linePaint = Paint()
      ..shader = radialShader
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    // Draw only the core gradient line (no blurred glow)
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Make sure you have this color defined in your colors.dart file
const Color primaryColor = Color(0xFFE50914);