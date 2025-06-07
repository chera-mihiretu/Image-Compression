import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class PreviewPage extends StatelessWidget {
  const PreviewPage({super.key});
  static const routeName = '/preview';

  @override
  Widget build(BuildContext context) {
    final String path = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(title: const Text('Preview')),
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: PhotoView(
            imageProvider: FileImage(File(path)),
            backgroundDecoration: const BoxDecoration(color: Colors.white),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 3,
          ),
        ),
      ),
    );
  }
}
