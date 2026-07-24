import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class VaccinationService {
  Future<List<dynamic>> fetchVaccinationsByFlock(int flockId) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/vaccinations/flock/$flockId');
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

    if (response.statusCode != 200) {
      final bodySnippet = response.body.length > 100
          ? response.body.substring(0, 100)
          : response.body;
      throw Exception(
        'Failed to load vaccinations: ${response.statusCode} - $bodySnippet',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }

  Future<List<dynamic>> fetchAllVaccinations() async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/vaccinations');
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

    if (response.statusCode != 200) {
      final bodySnippet = response.body.length > 100
          ? response.body.substring(0, 100)
          : response.body;
      throw Exception(
        'Failed to load vaccinations: ${response.statusCode} - $bodySnippet',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }

  Future<Map<String, dynamic>> createVaccination(
      Map<String, dynamic> data) async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/vaccinations');
    http.Response response;
    try {
      response = await http
          .post(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 8));
    } catch (e) {
      throw Exception('Network error when calling $url: $e');
    }

    if (response.statusCode != 201 && response.statusCode != 200) {
      final bodySnippet = response.body.length > 100
          ? response.body.substring(0, 100)
          : response.body;
      throw Exception(
        'Failed to create vaccination: ${response.statusCode} - $bodySnippet',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }
}
