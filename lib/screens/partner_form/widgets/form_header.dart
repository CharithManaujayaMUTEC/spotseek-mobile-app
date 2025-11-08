import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';

class FormHeader extends StatelessWidget {
  // 1. Add a required callback function to the constructor
  final VoidCallback onBackPressed;

  const FormHeader({
    super.key,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: textColor, size: 20),
                // 2. Change onPressed to call the provided callback
                onPressed: onBackPressed,
                splashRadius: 20,
              ),
            ),
            SizedBox(
              width: 150,
              height: 50,
              child: Image.asset('assets/spotseeker_logo.png'),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Image.asset('assets/partner_banner.png'),
        ),
      ],
    );
  }
}