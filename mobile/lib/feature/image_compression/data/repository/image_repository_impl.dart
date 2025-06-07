import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

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
    required String filePath,
  }) async {
    try {
      final bytes = await remote.compressImage(filePath: filePath);
      final id = uuid.v4();
      final dir = await getApplicationDocumentsDirectory();
      final compressedPath = '${dir.path}/compressed_$id.jpg';
      final file = File(compressedPath);
      await file.writeAsBytes(bytes);

      final entity = CompressedImage(
        id: id,
        originalPath: filePath,
        compressedPath: compressedPath,
        createdAt: DateTime.now(),
      );
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
