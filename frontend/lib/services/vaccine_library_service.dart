import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class VaccineLibraryService {
  Future<List<dynamic>> fetchLibrary({String? search, String? lang}) async {
    var url = '${ApiConfig.baseUrl}/vaccine-library';

    final params = <String>[];
    if (search != null && search.isNotEmpty) {
      params.add('search=${Uri.encodeQueryComponent(search)}');
    }
    if (lang != null && lang.isNotEmpty) {
      params.add('lang=$lang');
    }

    if (params.isNotEmpty) {
      url = '$url?${params.join('&')}';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is List) {
        return decoded;
      }
    }

    throw Exception('Failed to load vaccine library');
  }

  Future<Map<String, dynamic>> fetchArticleById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/vaccine-library/$id');
    final response = await http.get(
      url,
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    }

    throw Exception('Failed to load vaccine library article');
  }
}