import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'dart:typed_data';

abstract class ImageRepository {
  Future<Either<Failure, CompressedImage>> compressAndSave({
    required Uint8List imageBytes,
    String? originalPath,
  });
  Future<Either<Failure, List<CompressedImage>>> getHistory();
}
