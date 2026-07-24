class Vaccine {
  final int vaccineId;
  final String name;
  final String diseaseTarget;
  final int intervalDays;
  final String? notes;

  Vaccine({
    required this.vaccineId,
    required this.name,
    required this.diseaseTarget,
    required this.intervalDays,
    this.notes,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      vaccineId: json['vaccine_id'] as int,
      name: json['name'] as String,
      diseaseTarget: json['disease_target'] as String,
      intervalDays: (json['interval_days'] as num).toInt(),
      notes: json['notes'] as String?,
    );
  }
}
