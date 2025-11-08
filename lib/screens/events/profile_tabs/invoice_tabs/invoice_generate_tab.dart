import 'package:flutter/material.dart';

class InvoiceTabGenerate extends StatelessWidget {
  const InvoiceTabGenerate({Key? key}) : super(key: key);

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
            const Text(
              'Would you like to settle event accounts and generate the final invoice?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 38),
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Generate Final Invoice')),
                );
              },
              child: Container(
                width: 392,
                height: 52,
                decoration: ShapeDecoration(
                  color: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      width: 1,
                      color: Color(0xFFE50914),
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Generate Final Invoice',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Onest',
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
