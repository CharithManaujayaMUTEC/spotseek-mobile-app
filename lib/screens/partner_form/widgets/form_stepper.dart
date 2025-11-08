import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/dashed_line_painter.dart';

class FormStepper extends StatelessWidget {
  final int currentStep;

  const FormStepper({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Row(
        children: [
          _buildStep(
              icon: Icons.corporate_fare, // A better matching icon
              label: 'Company\nProfile',
              stepIndex: 0),
          _buildLine(isActive: currentStep >= 1),
          _buildStep(
              icon: Icons.person_outline, // A better matching icon
              label: 'Organizer\nInfo',
              stepIndex: 1),
          _buildLine(isActive: currentStep >= 2),
          _buildStep(
              icon: Icons.handshake_outlined, // A better matching icon
              label: 'Partnership\nAgreement',
              stepIndex: 2),
        ],
      ),
    );
  }

  Widget _buildLine({required bool isActive}) {
    return Expanded(
      child: isActive
          ? Container(
              height: 1.5,
              color: primaryColor,
            )
          : CustomPaint(
              painter: DashedLinePainter(color: hintTextColor.withValues(alpha: 0.5)),
              child: Container(
                height: 1.5,
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

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            // Use solid color for current step, border for inactive
            color: isCurrent ? primaryColor : Colors.transparent,
            border: Border.all(
              color: isActive ? primaryColor : hintTextColor.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
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
    );
  }
}