import 'dart:io';
import 'dart:math';

import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';

class FileUtils {
  /// Calculate file size in bytes
  static Future<int> getFileSize(String filePath) async {
    try {
      if (filePath.isEmpty) return 0;

      final file = File(filePath);
      if (await file.exists()) {
        return await file.length();
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Format bytes to human readable string
  static String formatBytes(int bytes) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();

    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  /// Calculate total storage saved (original - compressed)
  static Future<String> calculateStorageSaved(
    String originalPath,
    String compressedPath,
  ) async {
    try {
      if (originalPath.isEmpty || compressedPath.isEmpty) return '0 B';

      final originalSize = await getFileSize(originalPath);
      final compressedSize = await getFileSize(compressedPath);
      final saved = originalSize - compressedSize;

      if (saved <= 0) return '0 B';
      return formatBytes(saved);
    } catch (e) {
      return '0 B';
    }
  }

  /// Calculate total storage used by compressed images
  static Future<String> calculateTotalStorageUsed(
    List<String> compressedPaths,
  ) async {
    try {
      if (compressedPaths.isEmpty) return '0 B';

      int totalSize = 0;
      for (final path in compressedPaths) {
        if (path.isNotEmpty) {
          totalSize += await getFileSize(path);
        }
      }
      return formatBytes(totalSize);
    } catch (e) {
      return '0 B';
    }
  }

  /// Calculate total storage saved across all images
  static Future<String> calculateTotalStorageSaved(
    List<Map<String, String>> imagePaths,
  ) async {
    try {
      if (imagePaths.isEmpty) return '0 B';

      int totalSaved = 0;
      for (final image in imagePaths) {
        final originalPath = image['originalPath'] ?? '';
        final compressedPath = image['compressedPath'] ?? '';

        if (originalPath.isNotEmpty && compressedPath.isNotEmpty) {
          final originalSize = await getFileSize(originalPath);
          final compressedSize = await getFileSize(compressedPath);
          totalSaved += (originalSize - compressedSize);
        }
      }

      if (totalSaved <= 0) return '0 B';
      return formatBytes(totalSaved);
    } catch (e) {
      return '0 B';
    }
  }

  /// Calculate storage saved percentage
  static Future<String> calculateStorageSavedPercentage(
    String originalPath,
    String compressedPath,
  ) async {
    try {
      if (originalPath.isEmpty || compressedPath.isEmpty) return '0%';

      final originalSize = await getFileSize(originalPath);
      final compressedSize = await getFileSize(compressedPath);

      if (originalSize <= 0) return '0%';

      final percentage = ((originalSize - compressedSize) / originalSize * 100);
      return '${percentage.round()}%';
    } catch (e) {
      return '0%';
    }
  }

  /// Calculate average storage saved percentage across all images
  static Future<String> calculateAverageStorageSavedPercentage(
    List<CompressedImage> images,
  ) async {
    try {
      if (images.isEmpty) return '0%';

      double totalPercentage = 0;
      int validImages = 0;

      for (final image in images) {
        if (image.originalPath.isNotEmpty && image.compressedPath.isNotEmpty) {
          final originalSize = await getFileSize(image.originalPath);
          final compressedSize = await getFileSize(image.compressedPath);

          if (originalSize > 0) {
            final percentage =
                ((originalSize - compressedSize) / originalSize * 100);
            totalPercentage += percentage;
            validImages++;
          }
        }
      }

      if (validImages == 0) return '0%';

      final averagePercentage = totalPercentage / validImages;
      return '${averagePercentage.round()}%';
    } catch (e) {
      return '0%';
    }
  }
}
