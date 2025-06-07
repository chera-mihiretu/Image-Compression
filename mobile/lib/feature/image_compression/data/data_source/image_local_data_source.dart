import 'package:hive/hive.dart';
import 'package:mobile/cores/constants/hive_constants.dart';
import 'package:mobile/feature/image_compression/data/model/compressed_image_model.dart';

class ImageLocalDataSource {
  Future<Box<CompressedImageModel>> _openBox() async {
    return Hive.openBox<CompressedImageModel>(
      HiveConstants.compressedImagesBox,
    );
  }

  Future<void> saveImage(CompressedImageModel model) async {
    final box = await _openBox();
    await box.put(model.id, model);
  }

  Future<List<CompressedImageModel>> getAllImages() async {
    final box = await _openBox();
    return box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
