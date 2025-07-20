import 'dart:io';
import 'dart:typed_data';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_local_data_source.dart';
import 'package:mobile/feature/image_compression/data/data_source/image_remote_data_source.dart';
import 'package:mobile/feature/image_compression/data/model/compressed_image_model.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/domain/repository/image_repository.dart';

class ImageRepositoryImpl implements ImageRepository {
  final ImageRemoteDataSource remote;
  final ImageLocalDataSource local;
  final Uuid uuid;

  ImageRepositoryImpl({required this.remote, required this.local, Uuid? uuid})
    : uuid = uuid ?? const Uuid();

  @override
  Future<Either<Failure, CompressedImage>> compressAndSave({
    required Uint8List imageBytes,
    String? originalPath,
  }) async {
    try {
      // Get compression quality from settings
      final prefs = await SharedPreferences.getInstance();
      final compressionQuality = prefs.getDouble('compression_quality') ?? 0.8;

      // Convert from 0.0-1.0 scale to 60-100 scale for backend
      final finalQuality = (compressionQuality * 100).round();
      final clampedQuality = finalQuality < 60
          ? 60
          : (finalQuality > 100 ? 100 : finalQuality);

      // Create a timestamp-based filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final imageName = 'image_$timestamp.jpg';

      // Compress the image with the specified quality
      final compressedBytes = await remote.compressImage(
        imageBytes: imageBytes,
        imageName: imageName,
        compressionQuality: clampedQuality,
      );

      final id = uuid.v4();
      final dir = await getApplicationDocumentsDirectory();

      // Create a unique filename for the compressed image
      final fileName = 'compressed_${timestamp}_$id.jpg';
      final compressedPath = '${dir.path}/$fileName';
      final file = File(compressedPath);

      // Save the compressed image locally
      await file.writeAsBytes(compressedBytes);

      // Verify the file was saved successfully
      if (!await file.exists()) {
        throw Exception('Failed to save compressed image locally');
      }

      // Verify file size is not zero
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Compressed image file is empty');
      }

      // Create the entity with local path
      final entity = CompressedImage(
        id: id,
        originalPath: originalPath ?? 'unknown',
        compressedPath: compressedPath, // This is the local path
        createdAt: DateTime.now(),
      );

      // Save the metadata to local storage (Hive database)
      await local.saveImage(CompressedImageModel.fromEntity(entity));

      return right(entity);
    } catch (e) {
      return left(NetworkFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompressedImage>>> getHistory() async {
    try {
      final list = await local.getAllImages();
      return right(list.map((e) => e.toEntity()).toList());
    } catch (e) {
      return left(StorageFailure(e.toString()));
    }
  }
}
