part of 'image_bloc.dart';

abstract class ImageEvent extends Equatable {
  const ImageEvent();
  @override
  List<Object?> get props => [];
}

class ImagePickRequested extends ImageEvent {
  final bool fromCamera;
  const ImagePickRequested({required this.fromCamera});
  @override
  List<Object?> get props => [fromCamera];
}

class ImageCompressRequested extends ImageEvent {
  final String filePath;
  const ImageCompressRequested(this.filePath);
  @override
  List<Object?> get props => [filePath];
}

class ImageCompressWithPreviewRequested extends ImageEvent {
  final String filePath;
  final bool skipPreview;
  const ImageCompressWithPreviewRequested({
    required this.filePath,
    this.skipPreview = false,
  });
  @override
  List<Object?> get props => [filePath, skipPreview];
}

class ImageHistoryRequested extends ImageEvent {
  const ImageHistoryRequested();
}
