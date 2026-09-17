import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class ReminderService {
  Future<List<dynamic>> fetchMyReminders() async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/reminders/me');
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
        'Failed to load reminders: ${response.statusCode} - $bodySnippet',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }
}