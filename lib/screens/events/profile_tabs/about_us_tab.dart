import 'package:flutter/material.dart';

class AboutUs extends StatelessWidget {
  const AboutUs({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 1116),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Container(
                      width: 392,
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          width: 1.30,
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 39),
                            SizedBox(
                              width: 136,
                              height: 136,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 136,
                                    height: 136,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 3,
                                        color: const Color(0xFFE50914),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 120,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: const DecorationImage(
                                        image: AssetImage('assets/profile.png'),
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        width: 1,
                                        color: Colors.white.withOpacity(0.10),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 40),
                            const SizedBox(
                              width: 361,
                              child: Text(
                                'The next step in our evolution, an advanced management console that brings together all Spotseeker technologies under one streamlined ecosystem.\n\nWhat began as a late-night idea by a 19-year-old visionary has grown beyond ticketing, evolving into a complete platform built to redefine how events are created, managed, and experienced.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w300,
                                  height: 1.71,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const SizedBox(
                              width: 360,
                              child: Text(
                                'Being built with precision Copilot unites them into one powerful system designed for control, transparency, and performance\n\nThe progress has been overwhelming, yet we believe there is so much more to grow.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w300,
                                  height: 1.71,
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            const SizedBox(
                              width: 361,
                              child: Text(
                                'The Experience That\u00A0Never\u00A0Ends❗',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontFamily: 'Onest',
                                  fontWeight: FontWeight.w500,
                                  height: 1.50,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: SizedBox(
                                width: 350,
                                child: AspectRatio(
                                  aspectRatio: 447 / 559,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      image: const DecorationImage(
                                        image: AssetImage('assets/about_us_banner.png'),
                                        fit: BoxFit.cover,
                                      ),
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
