import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

/// A popup widget that represents a fund withdrawal details card.
///
/// This is a direct, faithful translation of the provided Container layout into
/// valid Flutter code. Use it where you want to show the withdrawal details.
class FundWithdrawalPopup extends StatelessWidget {
  const FundWithdrawalPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Make the popup responsive to screen size and place it at the bottom.
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    // Keep a max width similar to the original design, but allow it to shrink
    // on narrow screens with side padding.
    final double maxDesignWidth = 430;
    final double horizontalPadding = 16;
    final double maxWidth = math.min(maxDesignWidth, screenWidth - horizontalPadding * 2);

    // Respect available vertical space (e.g., keyboards) and limit height.
    final double fixedDesignHeight = 476;
    final double maxHeight = screenHeight * 0.9; // don't exceed 90% of the screen
    final double height = math.min(fixedDesignHeight, maxHeight - mq.viewInsets.bottom);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom + 12, left: horizontalPadding, right: horizontalPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Container(
            width: maxWidth,
            height: height,
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
      ),
            child: Stack(
        children: [
          // Shared background decoration from lib/widgets/background_gradient.dart
          Positioned.fill(
            child: Container(
              decoration: backgroundGradient(),
            ),
          ),

          // Amount text
          const Positioned(
            left: 123,
            top: 26,
            child: Text(
              'LKR 133,000.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Placeholder for close/icon at top-right
          const Positioned(
            left: 384,
            top: 28,
            child: SizedBox(
              width: 24,
              height: 24,
            ),
          ),

          // Main content block
          Positioned(
            left: 20,
            top: 81,
            child: SizedBox(
              width: 388,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top divider
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                  const SizedBox(height: 16),

                  // Status row and small card
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: const Text(
                          'Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x19FFC107),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Pending',
                          style: TextStyle(
                            color: Color(0xFFFFC107),
                            fontSize: 12,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                  const SizedBox(height: 16),

                  // Bank details / amounts
                  _labelValueRow('Bank Name', 'Bank Of Ceylon'),
                  const SizedBox(height: 16),
                  _labelValueRow('Account Number', '21345329'),
                  const SizedBox(height: 16),
                  _labelValueRow('Sub Total', 'LKR 140,000'),
                  const SizedBox(height: 16),
                  _labelValueRow('Commission Fee', '5%'),
                  const SizedBox(height: 16),
                  _labelValueRow('Total', 'LKR 133,000'),

                  const SizedBox(height: 16),
                  Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
                  const SizedBox(height: 12),

                  // Note section
                  Opacity(
                    opacity: 0.6,
                    child: const Text(
                      'Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pay event crew or employees',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
          ),
            ),
          ),
        ),
      );
  }

  // Helper that renders a label / value pair aligned at the row ends.
  static Widget _labelValueRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Opacity(
          opacity: 0.6,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Text(
          value,
          textAlign: TextAlign.right,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Onest',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
