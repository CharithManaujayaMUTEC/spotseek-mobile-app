import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import 'package:spotseeker_app/utils/colors.dart';

// This function will be called to show the dialog
Future<Uint8List?> showSignaturePad(BuildContext context) async {
  return await showDialog<Uint8List>(
    context: context,
    builder: (context) => const SignaturePad(),
  );
}

class SignaturePad extends StatefulWidget {
  const SignaturePad({super.key});

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  // Controller to manage the signature canvas
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.white,
    exportBackgroundColor: Colors.transparent,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1B2E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Please draw your signature inside the box below. Make sure it’s clear and matches your official documents.',
                    style: TextStyle(color: hintTextColor, fontSize: 14),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: hintTextColor),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // The Signature Canvas
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: hintTextColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 10),
            // Undo and Clear buttons
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.undo, color: hintTextColor, size: 18),
                  label: const Text('Undo', style: TextStyle(color: hintTextColor)),
                  onPressed: () {
                    if (_controller.isNotEmpty) _controller.undo();
                  },
                ),
                const SizedBox(width: 8),
                const Text('|', style: TextStyle(color: hintTextColor)),
                const SizedBox(width: 8),
                TextButton.icon(
                  icon: const Icon(Icons.clear, color: hintTextColor, size: 18),
                  label: const Text('Clear', style: TextStyle(color: hintTextColor)),
                  onPressed: () => _controller.clear(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Confirm button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                if (_controller.isNotEmpty) {
                  final Uint8List? data = await _controller.toPngBytes();
                  if (context.mounted) {
                    Navigator.of(context).pop(data);
                  }
                } else {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              },
              child: const Text(
                'Confirm Signature',
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}