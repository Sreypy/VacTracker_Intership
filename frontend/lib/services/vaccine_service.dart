import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/vaccine.dart';

class VaccineService {
  Future<List<Vaccine>> fetchVaccines() async {
    final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/vaccines'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((json) => Vaccine.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load vaccines");
    }
  }

  Future<Vaccine> createVaccine(Map<String, dynamic> payload) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/vaccines'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return Vaccine.fromJson(data);
    } else {
      throw Exception('Failed to create vaccine');
    }
  }

  Future<Vaccine> fetchVaccineById(int id) async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vaccines/$id'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return Vaccine.fromJson(data);
    } else {
      throw Exception('Failed to load vaccine');
    }
  }
}
