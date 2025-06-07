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

class ImageHistoryRequested extends ImageEvent {
  const ImageHistoryRequested();
}
