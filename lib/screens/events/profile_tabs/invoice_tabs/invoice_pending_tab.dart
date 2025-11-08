import 'package:flutter/material.dart';

class InvoiceTabPending extends StatelessWidget {
  const InvoiceTabPending({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              child: Image.asset(
                'assets/invoice_banner.png',
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 150,
              height: 128,
              child: Image.asset(
                'assets/agreement.gif',
                width: 150,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Pending',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Onest',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Hang tight!\nWe\'re generating your event invoice.\nYou\'ll be notified once it\'s ready.',
              textAlign: TextAlign.center,
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
    );
  }
}
