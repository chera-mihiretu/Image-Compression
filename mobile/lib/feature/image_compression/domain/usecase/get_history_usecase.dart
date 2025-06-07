import 'package:dartz/dartz.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/domain/repository/image_repository.dart';

class GetHistoryUseCase {
  final ImageRepository repository;
  const GetHistoryUseCase(this.repository);

  Future<Either<Failure, List<CompressedImage>>> call() =>
      repository.getHistory();
}
