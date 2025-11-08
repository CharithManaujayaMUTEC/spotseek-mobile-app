import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Image Compression Utility
/// Compresses images to reduce file size before upload
class ImageCompression {
  /// Compress an image file to reduce its size
  /// 
  /// [file] - The original image file
  /// [targetSizeKB] - Target size in KB (default: 400KB)
  /// [quality] - Compression quality 0-100 (default: 85)
  /// 
  /// Returns the compressed file or original if compression fails/not needed
  static Future<File> compressImage(
    File file, {
    int targetSizeKB = 400,
    int quality = 85,
  }) async {
    try {
      // Check if file is an image
      final extension = path.extension(file.path).toLowerCase();
      if (!['.jpg', '.jpeg', '.png'].contains(extension)) {
        // Not an image, return original (e.g., PDF)
        return file;
      }

      // Check current file size
      final fileSizeInBytes = await file.length();
      final fileSizeInKB = fileSizeInBytes / 1024;

      // If already smaller than target, return original
      if (fileSizeInKB <= targetSizeKB) {
        return file;
      }

      // Generate output path in temp directory
      final tempDir = await getTemporaryDirectory();
      final fileName = path.basenameWithoutExtension(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputPath = path.join(
        tempDir.path,
        '${fileName}_compressed_$timestamp.jpg',
      );

      // Compress the image
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outputPath,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressedFile == null) {
        // Compression failed, return original
        return file;
      }

      // Convert XFile to File
      final compressedFileAsFile = File(compressedFile.path);

      // Check compressed size
      final compressedSize = await compressedFileAsFile.length();
      final compressedSizeInKB = compressedSize / 1024;

      // If still too large, try with lower quality
      if (compressedSizeInKB > targetSizeKB && quality > 50) {
        return await compressImage(
          file,
          targetSizeKB: targetSizeKB,
          quality: quality - 15,
        );
      }

      return compressedFileAsFile;
    } catch (e) {
      print('Image compression error: $e');
      // Return original file if compression fails
      return file;
    }
  }

  /// Compress multiple images
  static Future<List<File>> compressMultiple(
    List<File> files, {
    int targetSizeKB = 400,
    int quality = 85,
  }) async {
    final compressed = <File>[];
    for (final file in files) {
      final compressedFile = await compressImage(
        file,
        targetSizeKB: targetSizeKB,
        quality: quality,
      );
      compressed.add(compressedFile);
    }
    return compressed;
  }

  /// Get readable file size string
  static String getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
