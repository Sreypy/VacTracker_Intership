import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/config/api_config.dart';
import 'package:frontend/services/storage_service.dart';

class NotificationService {
  Future<List<dynamic>> fetchMyNotifications() async {
    final token = await StorageService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/notifications/me');
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
        'Failed to load notifications: ${response.statusCode} - $bodySnippet',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded;
    }

    throw Exception('Unexpected response format from server: ${response.body}');
  }

  Future<int> fetchUnreadCount() async {
    final token = await StorageService.getToken();
    if (token == null) return 0;

    final url = Uri.parse('${ApiConfig.baseUrl}/notifications/unread-count');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return 0;
      final decoded = jsonDecode(response.body);
      return (decoded['count'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final token = await StorageService.getToken();
    if (token == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/notifications/$notificationId/read');
    try {
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Silently ignore mark-as-read failures
    }
  }

  Future<void> markAllAsRead() async {
    final token = await StorageService.getToken();
    if (token == null) return;

    final url = Uri.parse('${ApiConfig.baseUrl}/notifications/read-all');
    try {
      await http.patch(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 8));
    } catch (_) {
      // Silently ignore mark-all-as-read failures
    }
  }
}