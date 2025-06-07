import 'package:hive/hive.dart';
import 'package:mobile/cores/constants/hive_constants.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';

@HiveType(typeId: HiveConstants.compressedImageTypeId)
class CompressedImageModel extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String originalPath;

  @HiveField(2)
  late String compressedPath;

  @HiveField(3)
  late DateTime createdAt;

  CompressedImageModel();

  CompressedImage toEntity() => CompressedImage(
    id: id,
    originalPath: originalPath,
    compressedPath: compressedPath,
    createdAt: createdAt,
  );

  static CompressedImageModel fromEntity(CompressedImage entity) {
    final model = CompressedImageModel()
      ..id = entity.id
      ..originalPath = entity.originalPath
      ..compressedPath = entity.compressedPath
      ..createdAt = entity.createdAt;
    return model;
  }
}

class CompressedImageModelAdapter extends TypeAdapter<CompressedImageModel> {
  @override
  final int typeId = HiveConstants.compressedImageTypeId;

  @override
  CompressedImageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    final model = CompressedImageModel();
    model.id = fields[0] as String;
    model.originalPath = fields[1] as String;
    model.compressedPath = fields[2] as String;
    model.createdAt = fields[3] as DateTime;
    return model;
  }

  @override
  void write(BinaryWriter writer, CompressedImageModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalPath)
      ..writeByte(2)
      ..write(obj.compressedPath)
      ..writeByte(3)
      ..write(obj.createdAt);
  }
}
