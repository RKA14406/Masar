import 'dart:convert';
import 'package:http/http.dart' as http;

class AppDataService {
  AppDataService._internal();
  static final AppDataService _instance = AppDataService._internal();
  factory AppDataService() => _instance;

  static const String _url = 'https://vision-career.onrender.com/data';

  List<dynamic>? _cache;

  Future<List<dynamic>> fetchSubjects() async {
    if (_cache != null) return _cache!;

    final response = await http.get(Uri.parse(_url));

    print('AppDataService RAW RESPONSE [${response.statusCode}]: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('AppDataService: HTTP ${response.statusCode}');
    }

    if (response.body.isEmpty) {
      throw Exception('AppDataService: Empty response from server');
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('AppDataService: Invalid JSON response — $e');
    }

    if (body['success'] != true) {
      throw Exception('AppDataService: ${body['error'] ?? 'Unknown error'}');
    }

    final data = body['data'];
    if (data == null || data is! List) {
      throw Exception('AppDataService: Missing or invalid "data" field');
    }

    _cache = data;
    return _cache!;
  }

  void clearCache() => _cache = null;
}
