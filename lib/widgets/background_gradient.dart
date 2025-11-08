import 'package:flutter/material.dart';

BoxDecoration backgroundGradient() {
  return const BoxDecoration(
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
  );
}
