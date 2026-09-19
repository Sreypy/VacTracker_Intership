class VaccinationScheduleSummary {
  final List<dynamic> overdue;
  final List<dynamic> dueSoon;
  final List<dynamic> upcoming;
  final List<dynamic> dueToday;

  const VaccinationScheduleSummary({
    required this.overdue,
    required this.dueSoon,
    required this.upcoming,
    required this.dueToday,
  });

  int get overdueCount => overdue.length;
  int get dueSoonCount => dueSoon.length;
  int get upcomingCount => upcoming.length;
  int get dueTodayCount => dueToday.length;

  factory VaccinationScheduleSummary.fromRecords(List<dynamic> records) {
    final overdue = <dynamic>[];
    final dueSoon = <dynamic>[];
    final upcoming = <dynamic>[];
    final dueToday = <dynamic>[];

    final today = VaccinationScheduleService.calendarDate(DateTime.now());

    // Each log predicts a "next dose" via next_vaccine/next_due_date. Keep
    // only predictions that (a) haven't already been fulfilled by a later
    // log for that same vaccine, and (b) are the single latest prediction
    // per flock+vaccine (older/duplicate logs for the same upcoming dose
    // are dropped).
    final candidates = <String, dynamic>{};
    for (final record in records) {
      final dueDate = VaccinationScheduleService.dueDateFor(record);
      if (dueDate == null) continue;
      if (VaccinationScheduleService.isNextDoseAlreadyGiven(record, records)) {
        continue;
      }

      final flockId = VaccinationScheduleService.flockIdFor(record);
      final nextVaccineId = VaccinationScheduleService.nextVaccineIdFor(record);
      final key = '$flockId-$nextVaccineId';
      final existing = candidates[key];
      final recordDateGiven = VaccinationScheduleService.dateGivenFor(record);
      final existingDateGiven = existing == null
          ? null
          : VaccinationScheduleService.dateGivenFor(existing);

      if (existing == null ||
          (recordDateGiven != null &&
              (existingDateGiven == null ||
                  recordDateGiven.isAfter(existingDateGiven)))) {
        candidates[key] = record;
      }
    }

    for (final record in candidates.values) {
      final dueDate = VaccinationScheduleService.dueDateFor(record)!;
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
      } else {
        dueToday.add(record);
      }
    }

    return VaccinationScheduleSummary(
      overdue: overdue,
      dueSoon: dueSoon,
      upcoming: upcoming,
      dueToday: dueToday,
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

  static DateTime? dateGivenFor(dynamic raw) {
    if (raw is! Map) return null;
    final record = Map<String, dynamic>.from(raw);
    final rawDate = record['date_given'] ?? record['dateGiven'];
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

  static int? vaccineIdFor(dynamic raw) {
    if (raw is! Map) return null;
    final record = Map<String, dynamic>.from(raw);
    final vaccine = record['vaccine'];
    final id = vaccine is Map
        ? (vaccine['vaccine_id'] ?? vaccine['vaccineId'])
        : null;
    return id is num ? id.toInt() : int.tryParse(id?.toString() ?? '');
  }

  static int? nextVaccineIdFor(dynamic raw) {
    if (raw is! Map) return null;
    final record = Map<String, dynamic>.from(raw);
    final nextVaccine = record['next_vaccine'] ?? record['nextVaccine'];
    final id = nextVaccine is Map
        ? (nextVaccine['vaccine_id'] ?? nextVaccine['vaccineId'])
        : null;
    return id is num ? id.toInt() : int.tryParse(id?.toString() ?? '');
  }

  /// True if some other log for the same flock shows the predicted
  /// "next vaccine" was actually given on or after this record's own
  /// date_given — meaning this record's schedule prediction is stale.
  static bool isNextDoseAlreadyGiven(dynamic record, List<dynamic> allRecords) {
    final flockId = flockIdFor(record);
    final nextVaccineId = nextVaccineIdFor(record);
    final dateGiven = dateGivenFor(record);
    if (flockId == null || nextVaccineId == null || dateGiven == null) {
      return false;
    }
    for (final other in allRecords) {
      if (identical(other, record)) continue;
      if (flockIdFor(other) != flockId) continue;
      if (vaccineIdFor(other) != nextVaccineId) continue;
      final otherDateGiven = dateGivenFor(other);
      if (otherDateGiven == null) continue;
      if (!otherDateGiven.isBefore(dateGiven)) {
        return true;
      }
    }
    return false;
  }
}
