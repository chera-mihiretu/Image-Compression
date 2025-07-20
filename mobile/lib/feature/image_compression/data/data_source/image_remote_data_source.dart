import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/cores/constants/env_keys.dart';

class ImageRemoteDataSource {
  Future<Uint8List> compressImage({
    required Uint8List imageBytes,
    required String imageName,
    int compressionQuality = 70,
  }) async {
    final endpoint = dotenv.env[EnvKeys.lambdaEndpoint];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception('LAMBDA_ENDPOINT not configured');
    }

    // Validate compression quality
    if (compressionQuality < 60 || compressionQuality > 100) {
      throw Exception('Compression quality must be between 60 and 100');
    }

    final uri = Uri.parse(endpoint);

    try {
      final request = http.MultipartRequest('POST', uri);

      // Check if the image bytes are valid
      if (imageBytes.isEmpty) {
        throw Exception('Image bytes are empty');
      }

      // Create multipart file with the image bytes directly
      final multipartFile = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
      );
      request.files.add(multipartFile);

      // Add the compression quality parameter to form data
      request.fields['compress_size'] = compressionQuality.toString();

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        // Parse error response
        final errorBody = response.body;
        log('Error response: $errorBody');
        throw Exception('Backend error: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      log('Exception during image compression: $e');
      rethrow;
    }
  }
}
