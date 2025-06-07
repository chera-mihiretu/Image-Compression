import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/domain/repository/image_repository.dart';

class CompressImageUseCase {
  final ImageRepository repository;
  const CompressImageUseCase(this.repository);

  Future<Either<Failure, CompressedImage>> call({required String filePath}) {
    return repository.compressAndSave(filePath: filePath);
  }
}
