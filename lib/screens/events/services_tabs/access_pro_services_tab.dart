import 'package:flutter/material.dart';

class AccessProServicesTab extends StatelessWidget {
  final VoidCallback? onBack;

  const AccessProServicesTab({Key? key, this.onBack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (onBack != null)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBack,
                  splashRadius: 20,
                ),
              const SizedBox(width: 4),
              const Text(
                'Access Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Managing guest entry at large events can often become chaotic, with long queues, duplicate entries, and unverified attendees. AccessPro makes this process seamless by using smart QR code scanning and real-time validation. Every ticket is verified instantly at the gate, ensuring a smooth entry flow and minimizing fraud. Organizers can also monitor the number of attendees who have checked in versus those who haven’t, giving them live insights into crowd size and flow. With AccessPro, the check-in experience is faster, more reliable, and stress-free for both organizers and guests.\n',
            textAlign: TextAlign.justify,
            style: TextStyle(
              color: Colors.white.withOpacity(0.50),
              fontSize: 16,
              fontFamily: 'Onest',
              fontWeight: FontWeight.w300,
              height: 1.50,
            ),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text:
                      'Managing guest entry at large events can often become chaotic, with long queues, duplicate entries, and unverified attendees. AccessPro makes this process seamless by using smart QR code scanning and real-time validation. Every ticket is verified instantly at the gate, ensuring a smooth entry flow and minimizing fraud. Organizers can also monitor the number of attendees who have checked in versus those who haven’t, giving them live insights into crowd size and flow. With AccessPro, the check-in experience is faster, more reliable, and stress-free for both organizers and guests.\n',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w300,
                    height: 1.50,
                  ),
                ),
                const TextSpan(
                  text: '\n\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w300,
                    height: 1.50,
                  ),
                ),
                const TextSpan(
                  text: 'Key Features:\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
                const TextSpan(
                  text: '\n',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w300,
                    height: 1.50,
                  ),
                ),
                TextSpan(
                  text:
                      '• Instant ticket validation using QR codes and digital passes.\n• Real-time tracking of scanned vs. unscanned tickets.\n• Prevents duplicate or fake ticket entries.\n• Reduces long queues and waiting times.\n• Provides live attendee count for better crowd management.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.50),
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w300,
                    height: 1.50,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
