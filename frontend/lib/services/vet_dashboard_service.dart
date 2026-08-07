import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class VetDashboardStats {
  final int totalClients;
  final int overdueCount;
  final int dueTodayCount;
  final List<ClientData> clients;
  final List<ConnectedFarmer> connectedFarmers;

  VetDashboardStats({
    required this.totalClients,
    required this.overdueCount,
    required this.dueTodayCount,
    required this.clients,
    required this.connectedFarmers,
  });

  factory VetDashboardStats.fromJson(Map<String, dynamic> json) {
    final clientsList = (json['clients'] as List)
        .map((client) => ClientData.fromJson(client))
        .toList();
    final farmersList = (json['connectedFarmers'] as List? ?? [])
        .map((farmer) => ConnectedFarmer.fromJson(farmer))
        .toList();

    return VetDashboardStats(
      totalClients: json['totalClients'] ?? 0,
      overdueCount: json['overdueCount'] ?? 0,
      dueTodayCount: json['dueTodayCount'] ?? 0,
      clients: clientsList,
      connectedFarmers: farmersList,
    );
  }
}

class ConnectedFarmer {
  final int farmerId;
  final String name;
  final String phone;
  final String village;
  final String province;
  final String status;

  ConnectedFarmer({
    required this.farmerId,
    required this.name,
    required this.phone,
    required this.village,
    required this.province,
    required this.status,
  });

  factory ConnectedFarmer.fromJson(Map<String, dynamic> json) {
    return ConnectedFarmer(
      farmerId: json['farmerId'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      village: json['village'] ?? '',
      province: json['province'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

class ClientData {
  final int flockId;
  final String name;
  final String location;
  final String status;
  final String statusText;
  final int birdCount;
  final LastVaccination? lastVaccination;

  ClientData({
    required this.flockId,
    required this.name,
    required this.location,
    required this.status,
    required this.statusText,
    required this.birdCount,
    this.lastVaccination,
  });

  factory ClientData.fromJson(Map<String, dynamic> json) {
    return ClientData(
      flockId: json['flockId'] ?? 0,
      name: json['name'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? 'compliant',
      statusText: json['statusText'] ?? 'COMPLIANT',
      birdCount: json['birdCount'] ?? 0,
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
