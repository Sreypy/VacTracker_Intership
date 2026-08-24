import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_service.dart';

class FarmerDetail {
  final FarmerInfo farmer;
  final String farmName;
  final FarmSummary summary;
  final List<FlockData> flocks;
  final List<VaccinationData> vaccinations;
  final List<SickReportData> sickReports;

  FarmerDetail({
    required this.farmer,
    required this.farmName,
    required this.summary,
    required this.flocks,
    required this.vaccinations,
    required this.sickReports,
  });

  factory FarmerDetail.fromJson(Map<String, dynamic> json) {
    return FarmerDetail(
      farmer: FarmerInfo.fromJson(json['farmer']),
      farmName: json['farmName'] ?? '',
      summary: FarmSummary.fromJson(json['summary']),
      flocks: (json['flocks'] as List)
          .map((flock) => FlockData.fromJson(flock))
          .toList(),
      vaccinations: (json['vaccinations'] as List)
          .map((vax) => VaccinationData.fromJson(vax))
          .toList(),
      sickReports: (json['sickReports'] as List)
          .map((report) => SickReportData.fromJson(report))
          .toList(),
    );
  }
}

class FarmerInfo {
  final int farmerId;
  final String name;
  final String phone;
  final String village;
  final String province;

  FarmerInfo({
    required this.farmerId,
    required this.name,
    required this.phone,
    required this.village,
    required this.province,
  });

  factory FarmerInfo.fromJson(Map<String, dynamic> json) {
    return FarmerInfo(
      farmerId: json['farmerId'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      village: json['village'] ?? '',
      province: json['province'] ?? '',
    );
  }
}

class FarmSummary {
  final int totalChickens;
  final int totalFlocks;
  final int activeSickReports;
  final int vaccinationsDue;

  FarmSummary({
    required this.totalChickens,
    required this.totalFlocks,
    required this.activeSickReports,
    required this.vaccinationsDue,
  });

  factory FarmSummary.fromJson(Map<String, dynamic> json) {
    return FarmSummary(
      totalChickens: json['totalChickens'] ?? 0,
      totalFlocks: json['totalFlocks'] ?? 0,
      activeSickReports: json['activeSickReports'] ?? 0,
      vaccinationsDue: json['vaccinationsDue'] ?? 0,
    );
  }
}

class FlockData {
  final int flockId;
  final String batchName;
  final int birdCount;
  final String breed;
  final DateTime createdAt;

  FlockData({
    required this.flockId,
    required this.batchName,
    required this.birdCount,
    required this.breed,
    required this.createdAt,
  });

  factory FlockData.fromJson(Map<String, dynamic> json) {
    return FlockData(
      flockId: json['flockId'] ?? 0,
      batchName: json['batchName'] ?? '',
      birdCount: json['birdCount'] ?? 0,
      breed: json['breed'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class VaccinationData {
  final int vaccinationId;
  final int flockId;
  final String flockName;
  final String vaccineName;
  final DateTime dateGiven;
  final DateTime? nextDueDate;
  final String status;

  VaccinationData({
    required this.vaccinationId,
    required this.flockId,
    required this.flockName,
    required this.vaccineName,
    required this.dateGiven,
    this.nextDueDate,
    required this.status,
  });

  factory VaccinationData.fromJson(Map<String, dynamic> json) {
    return VaccinationData(
      vaccinationId: json['vaccinationId'] ?? 0,
      flockId: json['flockId'] ?? 0,
      flockName: json['flockName'] ?? '',
      vaccineName: json['vaccineName'] ?? '',
      dateGiven: DateTime.parse(json['dateGiven'] ?? DateTime.now().toIso8601String()),
      nextDueDate: json['nextDueDate'] != null ? DateTime.parse(json['nextDueDate']) : null,
      status: json['status'] ?? '',
    );
  }
}

class SickReportData {
  final int reportId;
  final int flockId;
  final String flockName;
  final String reportType;
  final int affectedCount;
  final String symptoms;
  final String reportDate;
  final String status;
  final DateTime createdAt;

  SickReportData({
    required this.reportId,
    required this.flockId,
    required this.flockName,
    required this.reportType,
    required this.affectedCount,
    required this.symptoms,
    required this.reportDate,
    required this.status,
    required this.createdAt,
  });

  factory SickReportData.fromJson(Map<String, dynamic> json) {
    return SickReportData(
      reportId: json['report_id'] ?? json['reportId'] ?? 0,
      flockId: json['flock_id'] ?? json['flockId'] ?? 0,
      flockName: json['flockName'] ?? json['batch_name'] ?? 'Unknown',
      reportType: json['reportType'] ?? '',
      affectedCount: json['affectedCount'] ?? 0,
      symptoms: json['symptoms'] ?? '',
      reportDate: json['reportDate'] ?? json['report_date'] ?? '',
      status: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class FarmerDetailService {
  Future<FarmerDetail> getFarmerDetail(int farmerId) async {
    final token = await StorageService.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Authentication token is missing. Please log in again.');
    }

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/vet/farmer/$farmerId'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return FarmerDetail.fromJson(data);
    } else {
      final message = response.body.isNotEmpty
          ? response.body
          : 'Failed to load farmer details';
      throw Exception('Error ${response.statusCode}: $message');
    }
  }
}