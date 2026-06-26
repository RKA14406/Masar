import 'package:flutter_dotenv/flutter_dotenv.dart';

class VertexSearchConfig {
  const VertexSearchConfig._();

  static const String projectId = 'project-31722430-64b6-45ea-a4c';
  static const String dataStoreId = 'visioncareer_1773921415472';

  static String get apiKey {
    final value = dotenv.env['VERTEX_API_KEY']?.trim();
    if (value == null || value.isEmpty) {
      throw StateError(
        'Missing VERTEX_API_KEY in .env. Add VERTEX_API_KEY=your_key and restart the app.',
      );
    }
    return value;
  }
}
