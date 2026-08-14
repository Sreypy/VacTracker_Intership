import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class VetDashboardStats {
  final int connectedFarmers;
  final int totalFlocks;
  final int newSickReports;
  final int overdueVaccinations;
  final List<FarmerData> farmers;

  VetDashboardStats({
    required this.connectedFarmers,
    required this.totalFlocks,
    required this.newSickReports,
    required this.overdueVaccinations,
    required this.farmers,
  });

  factory VetDashboardStats.fromJson(Map<String, dynamic> json) {
    final farmersList = (json['farmers'] as List)
        .map((farmer) => FarmerData.fromJson(farmer))
        .toList();

    return VetDashboardStats(
      connectedFarmers: json['connectedFarmers'] ?? 0,
      totalFlocks: json['totalFlocks'] ?? 0,
      newSickReports: json['newSickReports'] ?? 0,
      overdueVaccinations: json['overdueVaccinations'] ?? 0,
      farmers: farmersList,
    );
  }
}

class FarmerData {
  final int farmerId;
  final String name;
  final String farmName;
  final String location;
  final String status;
  final String statusText;
  final int flockCount;
  final int totalBirds;
  final LastVaccination? lastVaccination;

  FarmerData({
    required this.farmerId,
    required this.name,
    required this.farmName,
    required this.location,
    required this.status,
    required this.statusText,
    required this.flockCount,
    required this.totalBirds,
    this.lastVaccination,
  });

  factory FarmerData.fromJson(Map<String, dynamic> json) {
    return FarmerData(
      farmerId: json['farmerId'] ?? 0,
      name: json['name'] ?? '',
      farmName: json['farmName'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'healthy',
      statusText: json['statusText'] ?? 'HEALTHY',
      flockCount: json['flockCount'] ?? 0,
      totalBirds: json['totalBirds'] ?? 0,
      lastVaccination: json['lastVaccination'] != null
          ? LastVaccination.fromJson(json['lastVaccination'])
          : null,
    );
  }
}

class LastVaccination {
  final String date;
  final String vaccine;

  LastVaccination({required this.date, required this.vaccine});

  factory LastVaccination.fromJson(Map<String, dynamic> json) {
    return LastVaccination(
      date: json['date'] ?? '',
      vaccine: json['vaccine'] ?? '',
    );
  }
}

class VetDashboardService {
  Future<VetDashboardStats> getDashboardStats() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vet/dashboard/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return VetDashboardStats.fromJson(data);
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Failed to load vet dashboard stats';
      throw Exception('Error ${response.statusCode}: $message');
    }
  }
}