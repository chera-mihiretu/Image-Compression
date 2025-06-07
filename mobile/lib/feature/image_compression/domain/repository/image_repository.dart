import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';

abstract class ImageRepository {
  Future<Either<Failure, CompressedImage>> compressAndSave({
    required String filePath,
  });
  Future<Either<Failure, List<CompressedImage>>> getHistory();
}
