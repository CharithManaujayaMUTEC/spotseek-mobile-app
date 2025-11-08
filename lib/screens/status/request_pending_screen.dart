import 'package:flutter/material.dart';
import 'package:spotseeker_app/utils/colors.dart';
import 'package:spotseeker_app/widgets/background_gradient.dart';
// Note: For the exact WhatsApp icon, you might consider using a package like `font_awesome_flutter`.
// For this example, we'll use a suitable built-in icon.

class RequestPendingScreen extends StatelessWidget {
  const RequestPendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Implement logic to open WhatsApp or a support chat.
        },
        // 1. Use a color that matches WhatsApp's brand green.
        backgroundColor: const Color(0xFF25D366),
        child: const Icon(
          Icons.chat_bubble, // A suitable built-in alternative to the WhatsApp icon.
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: backgroundGradient(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              // The main axis alignment is removed to allow Spacers to work.
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 2. The main logo is now at the top.
                Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 180,
                    height: 60,
                    child: Image.asset('assets/spotseeker_logo.png'),
                  ),
                ),
                const Spacer(flex: 2), // Provides flexible space

                // 3. The new animated pending icon is added here.
                Image.asset(
                  'assets/pending.gif',
                  height: 80, // Set an appropriate height for the GIF
                ),
                const SizedBox(height: 40),

                // Text content remains the same but is repositioned by the Spacers.
                const Text(
                  'Access Request Pending!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your request to access Copilot is\nunder review.\nAccess credentials will be delivered to\nyour email once approved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: hintTextColor, fontSize: 16, height: 1.5),
                ),
                const Spacer(flex: 3), // Provides more space at the bottom
              ],
            ),
          ),
        ),
      ),
    );
  }
}