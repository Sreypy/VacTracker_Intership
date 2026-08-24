import 'dart:convert';

import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/sick_report.dart';
import 'package:frontend/services/storage_service.dart';
import 'package:http/http.dart' as http;

class SickReportService {
  /// The backend scopes this endpoint to the authenticated farmer.
  Future<List<SickReport>> fetchMyReports() async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/sick-reports');
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
    } catch (error) {
      throw Exception('Network error when calling $url: $error');
    }

    if (response.statusCode != 200) {
      throw Exception('Failed to load sick reports: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception(
        'Unexpected response format from server: ${response.body}',
      );
    }

    return decoded
        .whereType<Map>()
        .map((report) => SickReport.fromJson(Map<String, dynamic>.from(report)))
        .toList();
  }

  /// Loads the latest report data, including a veterinarian response when one
  /// has been submitted. The backend verifies that it belongs to the farmer.
  Future<SickReport> fetchReport(int reportId) async {
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Are you logged in?');
    }

    final url = Uri.parse('${ApiConfig.baseUrl}/sick-reports/$reportId');
    final response = await http
        .get(url, headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        })
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Failed to load sick report: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw Exception('Unexpected response format from server.');
    }
    return SickReport.fromJson(Map<String, dynamic>.from(decoded));
  }
}
