import 'package:flutter/material.dart';
import 'dart:ui' as ui; // Needed for the ui.Gradient

class GlowLinePainter extends CustomPainter {
  const GlowLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    // The path remains the same, as it correctly matches the clipper
    final Path path = Path();
    path.moveTo(0, 30);
    path.quadraticBezierTo(size.width / 2, -20, size.width, 30);

    // --- THE FIX IS IN THIS PAINT OBJECT ---

    // We will draw the glow in two passes for a high-quality effect.

    // 1. First Pass: A wide, soft, blurred glow
    final Paint glowPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.2, 0), // Start fading in
        Offset(size.width * 0.8, 0), // End fading out
        [
          Colors.transparent,
          primaryColor.withValues(alpha: 1.0), // Full opacity for more visibility
          Colors.transparent,
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0; // Wider stroke for the glow
    glowPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0); // Heavy blur

    // 2. Second Pass: A sharper, brighter core line on top
    final Paint linePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(size.width * 0.3, 0),
        Offset(size.width * 0.7, 0),
        [
          Colors.transparent,
          primaryColor,
          Colors.transparent,
        ],
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0; // Thinner stroke for the core
    linePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Lighter blur

    // Draw the glow first, then the sharp line on top of it
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Make sure you have this color defined in your colors.dart file
const Color primaryColor = Color(0xFFE50914);