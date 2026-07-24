class Flock {
  final int flockId;
  final String batchName;
  final int birdCount;
  final int age;
  final String ageUnit;
  final String? breed;
  final String dateAcquired;
  final String createdAt;

  Flock({
    required this.flockId,
    required this.batchName,
    required this.birdCount,
    required this.age,
    required this.ageUnit,
    required this.breed,
    required this.dateAcquired,
    required this.createdAt,
  });

  factory Flock.fromJson(Map<String, dynamic> json) {
    return Flock(
      flockId: json['flock_id'] as int,
      batchName: json['batch_name'] as String,
      birdCount: json['bird_count'] as int,
      age: (json['age'] as num?)?.toInt() ?? 0,
      ageUnit: json['age_unit'] as String? ?? 'days',
      breed: json['breed'] as String?,
      dateAcquired: json['date_acquired'] as String,
      createdAt: json['created_at'] as String,
    );
  }

  int get ageInDays {
    final parsed = DateTime.tryParse(dateAcquired);
    if (parsed == null) return 0;
    return DateTime.now().difference(parsed).inDays;
  }
}
