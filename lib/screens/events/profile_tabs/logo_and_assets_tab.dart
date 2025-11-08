import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class LogoAndAssetsTab extends StatelessWidget {
  const LogoAndAssetsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Logo and Assets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontFamily: 'Onest',
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _assetRow(
              context,
              title: 'Spotseeker Logo',
              subtitle: '18.4 KB',
              imageUrl: 'assets/old_spotseeker_logo.png',
            ),
            const SizedBox(height: 12),

            _assetRow(
              context,
              title: 'Ticket Booking QR',
              subtitle: '18.4 KB',
              imageUrl: 'assets/qr.png',
              thumbnailSize: 20,
            ),
            const SizedBox(height: 12),

            _assetRow(
              context,
              title: 'Koko Logo & Assets',
              subtitle: '18.4 KB',
              imageUrl: 'assets/koko_logo.png',
              thumbnailSize: 40,
            ),
          ],
        ),
      ),
    );
  }

  Widget _assetRow(BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    double thumbnailSize = 40,
  }) {
    return Container(
      width: double.infinity,
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Builder(builder: (context) {
            final double size = thumbnailSize < 40 ? 40 : thumbnailSize;
            final ImageProvider provider = imageUrl.startsWith('http')
                ? NetworkImage(imageUrl)
                : AssetImage(imageUrl) as ImageProvider;

            return Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(2.78),
                border: Border.all(color: Colors.white.withOpacity(0.50), width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.78),
                child: Image(
                  image: provider,
                  fit: BoxFit.contain,
                  width: size,
                  height: size,
                  alignment: Alignment.center,
                ),
              ),
            );
          }),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Onest',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Opacity(
                  opacity: 0.60,
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Onest',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _downloadAsset(imageUrl, context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: ShapeDecoration(
                color: const Color(0xFFE50914),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Download',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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
    );
  }

  Future<void> _downloadAsset(String imageUrl, BuildContext context) async {
    try {
      if (imageUrl.startsWith('http')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Network image download not supported')),
        );
        return;
      }

      final ByteData data = await rootBundle.load(imageUrl);
      final bytes = data.buffer.asUint8List();

      Directory? targetDir;
      try {
        targetDir = await getDownloadsDirectory();
      } catch (_) {
        targetDir = null;
      }

      if (targetDir == null) {
        if (Platform.isAndroid) {
          targetDir = await getExternalStorageDirectory();
        } else {
          targetDir = await getApplicationDocumentsDirectory();
        }
      }

      if (targetDir == null) {
        throw Exception('Unable to find a writable directory');
      }

      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${p.basename(imageUrl)}';
      final File outFile = File(p.join(targetDir.path, fileName));
      await outFile.writeAsBytes(bytes);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved image to: ${outFile.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save image: $e')),
      );
    }
  }
}
