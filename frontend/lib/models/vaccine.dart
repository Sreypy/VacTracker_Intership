class Vaccine {
  final int id;
  final String nameEn;
  final String nameKm;
  final String diseaseEn;
  final String diseaseKm;
  final int intervalDays;
  final String? notesEn;
  final String? notesKm;

  Vaccine({
    required this.id,
    required this.nameEn,
    required this.nameKm,
    required this.diseaseEn,
    required this.diseaseKm,
    required this.intervalDays,
    this.notesEn,
    this.notesKm,
  });

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
      id: json['vaccine_id'],
      nameEn: json['name_en'],
      nameKm: json['name_km'],
      diseaseEn: json['disease_en'],
      diseaseKm: json['disease_km'],
      intervalDays: json['interval_days'],
      notesEn: json['notes_en'],
      notesKm: json['notes_km'],
    );
  }
}
