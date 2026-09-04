class VaccinationScheduleSummary {
  final List<dynamic> overdue;
  final List<dynamic> dueSoon;
  final List<dynamic> upcoming;

  const VaccinationScheduleSummary({
    required this.overdue,
    required this.dueSoon,
    required this.upcoming,
  });

  int get overdueCount => overdue.length;
  int get dueSoonCount => dueSoon.length;
  int get upcomingCount => upcoming.length;

  factory VaccinationScheduleSummary.fromRecords(List<dynamic> records) {
    final overdue = <dynamic>[];
    final dueSoon = <dynamic>[];
    final upcoming = <dynamic>[];

    for (final record in records) {
      final dueDate = VaccinationScheduleService.dueDateFor(record);
      if (dueDate == null || VaccinationScheduleService.isCompleted(record)) {
        continue;
      }

      final today = VaccinationScheduleService.calendarDate(DateTime.now());
      final dueDay = VaccinationScheduleService.calendarDate(dueDate);

      if (dueDay.isBefore(today)) {
        overdue.add(record);
      } else if (dueDay.isAfter(today)) {
        final daysUntilDue = dueDay.difference(today).inDays;
        if (daysUntilDue <= 7) {
          dueSoon.add(record);
        } else {
          upcoming.add(record);
        }
      }
    }

    return VaccinationScheduleSummary(
      overdue: overdue,
      dueSoon: dueSoon,
      upcoming: upcoming,
    );
  }
}

class VaccinationScheduleService {
  static DateTime calendarDate(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  static DateTime? dueDateFor(dynamic raw) {
    if (raw is! Map) return null;
    final record = Map<String, dynamic>.from(raw);
    final rawDate = record['next_due_date'] ?? record['nextDueDate'];
    return DateTime.tryParse(rawDate?.toString() ?? '');
  }

  static bool isCompleted(dynamic raw) {
    if (raw is! Map) return false;
    final record = Map<String, dynamic>.from(raw);
    final status = record['status']?.toString().toLowerCase();
    return status == 'completed';
  }

  static int? flockIdFor(dynamic raw) {
    if (raw is! Map) return null;
    final record = Map<String, dynamic>.from(raw);
    final flock = record['flock'];
    final nestedId = flock is Map
        ? flock['flock_id'] ?? flock['flockId']
        : null;
    final value = nestedId ?? record['flock_id'] ?? record['flockId'];
    return value is num ? value.toInt() : int.tryParse(value?.toString() ?? '');
  }
}
