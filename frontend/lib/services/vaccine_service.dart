import 'package:dio/dio.dart';
import 'package:frontend/config/api_config.dart';
import 'package:frontend/models/vaccine.dart';

class VaccineService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<Vaccine>> fetchVaccines() async {
    final resp = await _dio.get('/vaccines');
    final data = resp.data;
    if (data is List) {
      return data
          .map((e) => Vaccine.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Unexpected vaccines response');
  }

  Future<Vaccine> fetchVaccine(int id) async {
    final resp = await _dio.get('/vaccines/$id');
    final data = resp.data;
    if (data is Map<String, dynamic>) {
      return Vaccine.fromJson(data);
    }
    throw Exception('Unexpected vaccine response');
  }
}
