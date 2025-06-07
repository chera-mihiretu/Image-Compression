part of 'image_bloc.dart';

class ImageState extends Equatable {
  final bool isLoading;
  final Failure? failure;
  final List<CompressedImage> images;

  const ImageState({
    required this.isLoading,
    required this.failure,
    required this.images,
  });

  const ImageState.initial()
    : isLoading = false,
      failure = null,
      images = const [];

  ImageState copyWith({
    bool? isLoading,
    Failure? failure,
    List<CompressedImage>? images,
  }) {
    return ImageState(
      isLoading: isLoading ?? this.isLoading,
      failure: failure,
      images: images ?? this.images,
    );
  }

  @override
  List<Object?> get props => [isLoading, failure, images];
}
