import 'package:flutter/material.dart';

class InvoiceTabGenerated extends StatelessWidget {
  const InvoiceTabGenerated({Key? key}) : super(key: key);

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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: ShapeDecoration(
                color: const Color(0xFF5CD069),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: Image.asset(
                      'assets/generated_icon.png',
                      width: 14,
                      height: 14,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 4),

                  const Text(
                    'Generated',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'All set!\nYou can now view and download your final invoice.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: 393,
              height: 54,
              decoration: ShapeDecoration(
                color: Colors.black.withOpacity(0.10), 
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: 1.30,
                    color: Colors.white.withOpacity(0.16),
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Stack(
                children: [
                  const Positioned(
                    left: 51,
                    top: 17,
                    child: SizedBox(
                      width: 314,
                      height: 23,
                      child: Text(
                        'Final Invoice',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Onest',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 14,
                    top: 12,
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: Image.asset(
                        'assets/pdf_icon.png',
                        width: 30,
                        height: 30,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 349,
                    top: 15,
                    child: Icon(
                      Icons.download,
                      color: Colors.white.withOpacity(0.6),
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('View Invoice')),
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
                      'Contact Support',
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
