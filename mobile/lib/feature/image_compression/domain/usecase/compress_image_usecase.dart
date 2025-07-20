import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/domain/repository/image_repository.dart';

class CompressImageUseCase {
  final ImageRepository repository;
  const CompressImageUseCase(this.repository);

  Future<Either<Failure, CompressedImage>> call({
    required Uint8List imageBytes,
    String? originalPath,
  }) {
    return repository.compressAndSave(
      imageBytes: imageBytes,
      originalPath: originalPath,
    );
  }
}
