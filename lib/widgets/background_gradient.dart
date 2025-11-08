import 'package:flutter/material.dart';

BoxDecoration backgroundGradient() {
  return const BoxDecoration(
    image: DecorationImage(
      image: AssetImage('assets/background_2.png'),
      fit: BoxFit.cover,
      alignment: Alignment(0.0, -0.6),
    ),
  );
}
