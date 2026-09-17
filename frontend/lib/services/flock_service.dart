import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/flock.dart';
import 'package:frontend/services/storage_service.dart';

class FlockService {
  Future<List<Flock>> fetchFlocks() async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/flocks');
    http.Response response;
    try {
      response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      throw Exception('Network error when calling $url: $e');
    }

    // Helpful debug info when things fail
    if (response.statusCode != 200) {
      final bodySnippet = response.body.length > 100
          ? response.body.substring(0, 100)
          : response.body;
      throw Exception(
        'Failed to load flocks: ${response.statusCode} - $bodySnippet',
      );
    }
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded
          .map((item) => Flock.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }

  Future<void> deleteFlock(int id) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/flocks/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete flock: ${response.statusCode}');
    }
  }

  Future<void> updateFlock(int id, Map<String, dynamic> data) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/flocks/$id');
    final response = await http.patch(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update flock: ${response.statusCode}');
    }
  }

  Future<Flock> fetchFlockById(int id) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/flocks/$id');
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load flock $id: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return Flock.fromJson(decoded);
    }

    throw Exception('Unexpected flock response format');
  }
}
