class SickReport {
  final int reportId;
  final int flockId;
  final int affectedCount;
  final DateTime reportDate;
  final DateTime createdAt;
  final String reportType;
  final String symptoms;
  final String status;
  final String? photoUrl;
  final String? flockName;
  final String? vetDiagnosis;
  final String? vetAdvice;
  final String? recommendedAction;
  final DateTime? followUpDate;
  final DateTime? respondedAt;
  final String? veterinarianName;

  const SickReport({
    required this.reportId,
    required this.flockId,
    required this.affectedCount,
    required this.reportDate,
    required this.createdAt,
    required this.reportType,
    required this.symptoms,
    required this.status,
    this.photoUrl,
    this.flockName,
    this.vetDiagnosis,
    this.vetAdvice,
    this.recommendedAction,
    this.followUpDate,
    this.respondedAt,
    this.veterinarianName,
  });

  bool get hasVetResponse =>
      (vetDiagnosis?.trim().isNotEmpty ?? false) ||
      (vetAdvice?.trim().isNotEmpty ?? false);

  factory SickReport.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1970);
    DateTime? parseOptionalDate(dynamic value) =>
        DateTime.tryParse(value?.toString() ?? '');

    int parseInt(dynamic value) => value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;

    return SickReport(
      reportId: parseInt(json['report_id'] ?? json['reportId']),
      flockId: parseInt(json['flock_id'] ?? json['flockId']),
      affectedCount: parseInt(json['affectedCount'] ?? json['affected_count']),
      reportDate: parseDate(json['reportDate'] ?? json['report_date']),
      createdAt: parseDate(json['createdAt'] ?? json['created_at']),
      reportType: (json['reportType'] ?? json['report_type'] ?? '').toString(),
      symptoms: (json['symptoms'] ?? '').toString(),
      status: (json['status'] ?? 'pending').toString(),
      photoUrl: (json['photoUrl'] ?? json['photo_url'])?.toString(),
      flockName: (json['flock'] is Map
              ? json['flock']['batch_name'] ?? json['flock']['batchName']
              : json['flockName'] ?? json['flock_name'])
          ?.toString(),
      vetDiagnosis: (json['vetDiagnosis'] ?? json['vetNotes'])?.toString(),
      vetAdvice: json['vetAdvice']?.toString(),
      recommendedAction: json['recommendedAction']?.toString(),
      followUpDate: parseOptionalDate(json['followUpDate']),
      respondedAt: parseOptionalDate(json['respondedAt'] ?? json['responded_at']),
      veterinarianName: (json['veterinarian'] is Map
              ? json['veterinarian']['name']
              : json['vetName'] ?? json['vet_name'])
          ?.toString(),
    );
  }
}
