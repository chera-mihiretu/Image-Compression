import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/feature/auth/presentation/bloc/auth_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/bloc/image_bloc.dart';
import 'package:mobile/feature/image_compression/presentation/page/preview_page.dart';

class ImageListPage extends StatelessWidget {
  const ImageListPage({super.key});
  static const routeName = '/images';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compressed Images'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const AuthSignOutRequested()),
          ),
        ],
      ),
      body: BlocBuilder<ImageBloc, ImageState>(
        builder: (context, state) {
          if (state.isLoading && state.images.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.images.isEmpty) {
            return Center(
              child: Text(
                'No images yet',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async =>
                context.read<ImageBloc>().add(const ImageHistoryRequested()),
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemCount: state.images.length,
              itemBuilder: (context, index) {
                final item = state.images[index];
                return GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    PreviewPage.routeName,
                    arguments: item.compressedPath,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(item.compressedPath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            onPressed: () => context.read<ImageBloc>().add(
              const ImagePickRequested(fromCamera: true),
            ),
            label: const Text('Camera'),
            icon: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () => context.read<ImageBloc>().add(
              const ImagePickRequested(fromCamera: false),
            ),
            label: const Text('Gallery'),
            icon: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }
}
