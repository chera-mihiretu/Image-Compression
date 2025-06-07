import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/cores/constants/env_keys.dart';

class ImageRemoteDataSource {
  Future<Uint8List> compressImage({required String filePath}) async {
    final endpoint = dotenv.env[EnvKeys.lambdaEndpoint];
    if (endpoint == null || endpoint.isEmpty) {
      throw Exception('LAMBDA_ENDPOINT not configured');
    }
    final uri = Uri.parse(endpoint);

    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', filePath));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode != 200) {
      throw Exception('Lambda error: ${response.statusCode}');
    }
    return response.bodyBytes;
  }
}
