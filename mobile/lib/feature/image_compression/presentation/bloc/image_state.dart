part of 'image_bloc.dart';

class ImageState extends Equatable {
  final bool isLoadingHistory;
  final bool isCompressing;
  final Failure? failure;
  final List<CompressedImage> images;
  final String? selectedImagePath;
  final bool showPreview;

  const ImageState({
    required this.isLoadingHistory,
    required this.isCompressing,
    required this.failure,
    required this.images,
    this.selectedImagePath,
    this.showPreview = false,
  });

  const ImageState.initial()
    : isLoadingHistory = false,
      isCompressing = false,
      failure = null,
      images = const [],
      selectedImagePath = null,
      showPreview = false;

  ImageState copyWith({
    bool? isLoadingHistory,
    bool? isCompressing,
    Failure? failure,
    List<CompressedImage>? images,
    String? selectedImagePath,
    bool? showPreview,
  }) {
    return ImageState(
      isLoadingHistory: isLoadingHistory ?? this.isLoadingHistory,
      isCompressing: isCompressing ?? this.isCompressing,
      failure: failure,
      images: images ?? this.images,
      selectedImagePath: selectedImagePath ?? this.selectedImagePath,
      showPreview: showPreview ?? this.showPreview,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingHistory,
    isCompressing,
    failure,
    images,
    selectedImagePath,
    showPreview,
  ];
}
