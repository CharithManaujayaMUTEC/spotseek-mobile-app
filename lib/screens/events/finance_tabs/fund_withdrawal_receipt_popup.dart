import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';

/// A popup widget showing a fund withdrawal receipt with a download button.
class FundWithdrawalReceiptPopup extends StatelessWidget {
  const FundWithdrawalReceiptPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final double maxDesignWidth = 430;
    final double horizontalPadding = 16;
    final double maxWidth = math.min(maxDesignWidth, screenWidth - horizontalPadding * 2);

    final double fixedDesignHeight = 605;
    final double maxHeight = screenHeight * 0.9;
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

          // Amount
          const Positioned(
            left: 128,
            top: 26,
            child: Text(
              'LKR 33,000.00',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Placeholder top-right icon
          const Positioned(
            left: 384,
            top: 28,
            child: SizedBox(width: 24, height: 24),
          ),

          // Top divider
          Positioned(
            left: 20,
            top: 81,
            child: SizedBox(
              width: 388,
              child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            ),
          ),

          // Status row
          Positioned(
            left: 20,
            top: 104,
            child: SizedBox(
              width: 388,
              child: Row(
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
                      color: const Color(0x333AF15D),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Transfered',
                      style: TextStyle(
                        color: Color(0xFF3AF15D),
                        fontSize: 12,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // mid divider
          Positioned(
            left: 20,
            top: 154,
            child: SizedBox(
              width: 388,
              child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            ),
          ),

          // Bank/transaction details
          Positioned(
            left: 20,
            top: 177,
            child: SizedBox(
              width: 388,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction Receipt ID row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: const Text(
                          'Transaction Receipt ID',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontFamily: 'Onest',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Row(
                        children: const [
                          SizedBox(
                            width: 84,
                            child: Text(
                              'F4H2K0X7',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontFamily: 'Onest',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                          SizedBox(width: 7),
                          SizedBox(width: 18, height: 18),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  _labelValueRow('Bank Name', 'Bank Of Ceylon'),
                  const SizedBox(height: 16),
                  _labelValueRow('Account Number', '21345329'),
                  const SizedBox(height: 16),
                  _labelValueRow('Sub Total', 'LKR 40,000'),
                  const SizedBox(height: 16),
                  _labelValueRow('Commission Fee', '5%'),
                  const SizedBox(height: 16),
                  _labelValueRow('Total', 'LKR 33,000'),
                ],
              ),
            ),
          ),

          // lower divider
          Positioned(
            left: 20,
            top: 400,
            child: SizedBox(
              width: 388,
              child: Divider(color: Colors.white.withOpacity(0.1), thickness: 1),
            ),
          ),

          // Note section
          Positioned(
            left: 20,
            top: 423,
            child: SizedBox(
              width: 388,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Opacity(
                    opacity: 0.6,
                    child: Text(
                      'Note',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
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

          // Download Receipt button
          Positioned(
            left: 18,
            top: 511,
            child: SizedBox(
              width: 392,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                onPressed: () {
                  // TODO: wire download functionality
                },
                child: const Text(
                  'Download Receipt',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.32,
                  ),
                ),
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
