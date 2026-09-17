import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/notification_service.dart';

void main() {
  group('NotificationService.parseCreatedAt', () {
    test('reads the camelCase createdAt key', () {
      final parsed = NotificationService.parseCreatedAt({
        'createdAt': '2026-09-14T10:30:00.000Z',
        'created_at': '2026-09-01T00:00:00.000Z',
      });
      expect(parsed, DateTime.utc(2026, 9, 14, 10, 30));
    });

    test('reads the snake_case created_at key as a fallback', () {
      final parsed = NotificationService.parseCreatedAt({
        'created_at': '2026-09-13T16:20:00.000Z',
      });
      expect(parsed, DateTime.utc(2026, 9, 13, 16, 20));
    });

    test('returns null when no timestamp exists', () {
      expect(NotificationService.parseCreatedAt({}), isNull);
      expect(NotificationService.parseCreatedAt({'title': 'x'}), isNull);
    });
  });

  group('NotificationService.compareCreatedAtDesc', () {
    test('sorts newest first', () {
      final latest = DateTime.utc(2026, 9, 14, 10, 30);
      final middle = DateTime.utc(2026, 9, 14, 9, 15);
      final oldest = DateTime.utc(2026, 9, 13, 16, 20);

      final sorted = [oldest, latest, middle]
        ..sort(NotificationService.compareCreatedAtDesc);
      expect(sorted, [latest, middle, oldest]);
    });

    test('pushes entries without a timestamp to the bottom', () {
      final latest = DateTime.utc(2026, 9, 14, 10, 30);
      final oldest = DateTime.utc(2026, 9, 13, 16, 20);

      final sorted = [null, latest, oldest, null]
        ..sort(NotificationService.compareCreatedAtDesc);
      expect(sorted, [latest, oldest, null, null]);
    });
  });

  group('unified notification time order', () {
    // Mirrors the rule on the farmer notification screen: every notification
    // type (vet responses, vaccine due today, older overdue reminders) shares
    // one time order — createdAt, newest first.
    test('vet responses interleave with other types by createdAt', () {
      final notifications = <Map<String, dynamic>>[
        {
          'type': 'vet_response',
          'notification_id': 1,
          'created_at': '2026-09-14T10:30:00.000Z',
        },
        {
          'type': 'vaccine_due_today',
          'notification_id': 2,
          'created_at': '2026-09-14T09:15:00.000Z',
        },
        {
          'type': 'vaccination_overdue',
          'notification_id': 3,
          'created_at': '2026-09-14T08:00:00.000Z',
        },
        {
          'type': 'vet_response',
          'notification_id': 4,
          'created_at': '2026-09-13T16:20:00.000Z',
        },
      ];

      notifications.sort((a, b) {
        final first = NotificationService.parseCreatedAt(a);
        final second = NotificationService.parseCreatedAt(b);
        return NotificationService.compareCreatedAtDesc(first, second);
      });

      expect(
        notifications.map((n) => n['notification_id']).toList(),
        [1, 2, 3, 4],
      );
      expect(notifications.first['type'], 'vet_response');
    });
  });
}
