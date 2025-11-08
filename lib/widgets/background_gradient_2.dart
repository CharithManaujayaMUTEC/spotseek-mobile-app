import 'package:flutter/material.dart';

/// Background gradient variant 2
/// Colors provided: #192145 and #200E16
/// Angle: 56 degrees from the horizontal.
BoxDecoration backgroundGradient2() {
  // 56 degrees → vector (cos(56°), sin(56°)) ≈ (0.559, 0.829)
  // Use begin/end alignments so the gradient is oriented at ~56°.
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment(-0.559, -0.829),
      end: Alignment(0.559, 0.829),
      colors: [
        Color(0xFF192145),
        Color(0xFF200E16),
      ],
      stops: [0.0, 1.0],
    ),
  );
}
