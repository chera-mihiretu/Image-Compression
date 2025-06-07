import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile/cores/failures/failure.dart';
import 'package:mobile/feature/image_compression/domain/entity/compressed_image.dart';
import 'package:mobile/feature/image_compression/domain/usecase/compress_image_usecase.dart';
import 'package:mobile/feature/image_compression/domain/usecase/get_history_usecase.dart';

part 'image_event.dart';
part 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final CompressImageUseCase compressImageUseCase;
  final GetHistoryUseCase getHistoryUseCase;

  ImageBloc({
    required this.compressImageUseCase,
    required this.getHistoryUseCase,
  }) : super(const ImageState.initial()) {
    on<ImagePickRequested>(_onPickRequested);
    on<ImageCompressRequested>(_onCompressRequested);
    on<ImageHistoryRequested>(_onHistoryRequested);
  }

  Future<void> _onPickRequested(
    ImagePickRequested event,
    Emitter<ImageState> emit,
  ) async {
    final picker = ImagePicker();
    final source = event.fromCamera ? ImageSource.camera : ImageSource.gallery;
    final picked = await picker.pickImage(source: source, imageQuality: 100);
    if (picked == null) return;
    add(ImageCompressRequested(picked.path));
  }

  Future<void> _onCompressRequested(
    ImageCompressRequested event,
    Emitter<ImageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final result = await compressImageUseCase(filePath: event.filePath);
    await result.fold(
      (l) async => emit(state.copyWith(isLoading: false, failure: l)),
      (r) async {
        final history = await getHistoryUseCase();
        emit(
          state.copyWith(
            isLoading: false,
            failure: null,
            images: history.getOrElse(() => []),
          ),
        );
      },
    );
  }

  Future<void> _onHistoryRequested(
    ImageHistoryRequested event,
    Emitter<ImageState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, failure: null));
    final res = await getHistoryUseCase();
    res.fold(
      (l) => emit(state.copyWith(isLoading: false, failure: l)),
      (r) => emit(state.copyWith(isLoading: false, images: r)),
    );
  }
}
