import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import 'storage_service.dart';

class VetDashboardStats {
  final int connectedFarmers;
  final int totalFlocks;
  final int newSickReports;
  final int totalBirds;
  final int activeCases;
  final int resolvedReports;
  final List<FarmerData> farmers;

  VetDashboardStats({
    required this.connectedFarmers,
    required this.totalFlocks,
    required this.newSickReports,
    required this.farmers,
    required this.totalBirds,
    this.activeCases = 0,
    this.resolvedReports = 0,
  });

  factory VetDashboardStats.fromJson(Map<String, dynamic> json) {
    final farmersList = (json['farmers'] as List)
        .map((farmer) => FarmerData.fromJson(farmer))
        .toList();

    return VetDashboardStats(
      connectedFarmers: json['connectedFarmers'] ?? 0,
      totalFlocks: json['totalFlocks'] ?? 0,
      newSickReports: json['newSickReports'] ?? 0,
      totalBirds: json['totalBirds'] ?? 0,
      farmers: farmersList,
      activeCases: json['activeCases'] ?? 0,
      resolvedReports: json['resolvedReports'] ?? 0,
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
  final int activeCases;
  final int resolvedReports;

  FarmerData({
    required this.farmerId,
    required this.name,
    required this.farmName,
    required this.location,
    required this.status,
    required this.statusText,
    required this.flockCount,
    required this.totalBirds,
    this.activeCases = 0,
    this.resolvedReports = 0,
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
      activeCases: json['activeCases'] ?? 0,
      resolvedReports: json['resolvedReports'] ?? 0,
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

class VetConnectionRequest {
  final int connectionId;
  final String status;
  final String farmerName;
  final String farmerPhone;

  VetConnectionRequest({
    required this.connectionId,
    required this.status,
    required this.farmerName,
    required this.farmerPhone,
  });

  factory VetConnectionRequest.fromJson(Map<String, dynamic> json) {
    final farmer = (json['farmer'] ?? {}) as Map<String, dynamic>;
    return VetConnectionRequest(
      connectionId: json['connection_id'] ?? 0,
      status: json['status'] ?? 'pending',
      farmerName: farmer['name']?.toString() ?? 'Unknown farmer',
      farmerPhone: farmer['phone']?.toString() ?? '',
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

  /// Pending farmer connection requests for the logged-in veterinarian.
  Future<List<VetConnectionRequest>> getConnectionRequests() async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vet/connections/requests'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is List) {
        return data
            .map((item) => VetConnectionRequest.fromJson(item))
            .toList();
      }
      return [];
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Failed to load connection requests';
      throw Exception('Error ${response.statusCode}: $message');
    }
  }

  /// Accepts or rejects a farmer connection request.
  Future<void> respondToConnection(int connectionId, bool accept) async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final action = accept ? 'accept' : 'reject';
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/vet/connections/$connectionId/$action'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Failed to respond to connection request';
      throw Exception('Error ${response.statusCode}: $message');
    }
  }
}
