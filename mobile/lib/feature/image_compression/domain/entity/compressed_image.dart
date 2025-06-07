import 'package:equatable/equatable.dart';

class CompressedImage extends Equatable {
  final String id;
  final String originalPath;
  final String compressedPath;
  final DateTime createdAt;

  const CompressedImage({
    required this.id,
    required this.originalPath,
    required this.compressedPath,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, originalPath, compressedPath, createdAt];
}
