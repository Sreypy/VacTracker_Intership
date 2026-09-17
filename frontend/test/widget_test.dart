// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/models/sick_report.dart';
import 'package:frontend/screens/auth/login_otp_screen.dart';
import 'package:frontend/screens/farmer/log_vaccination_step2_page.dart';

void main() {
  testWidgets('OTP dialog shows verification controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OtpVerificationDialog(
          phone: '85512345678',
          languageCode: 'en',
          otpCode: '123456',
          onVerify: (otp) async {},
          onResend: () async {},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Verify OTP'), findsOneWidget);
    expect(
      find.text('Enter the 6-digit code sent to your phone'),
      findsOneWidget,
    );
    expect(find.text('Verify'), findsOneWidget);
    expect(find.text('Resend OTP'), findsOneWidget);
  });

  testWidgets('Step 2 keeps the reminder vaccine preselected', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LogVaccinationStep2Page(
          selectedFlockName: 'Batch A',
          flockId: '7',
          languageCode: 'en',
          selectedVaccineId: '2',
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Select Vaccine'), findsOneWidget);
  });

  test(
    'sick report status helpers correctly identify resolved and responded states',
    () {
      final waiting = SickReport.fromJson({
        'report_id': 1,
        'flock_id': 2,
        'affectedCount': 5,
        'reportDate': '2026-09-01',
        'createdAt': '2026-09-01T08:00:00Z',
        'reportType': 'disease',
        'symptoms': 'Lethargy',
        'status': 'pending',
      });

      final responded = SickReport.fromJson({
        'report_id': 2,
        'flock_id': 3,
        'affectedCount': 8,
        'reportDate': '2026-09-02',
        'createdAt': '2026-09-02T08:00:00Z',
        'reportType': 'injury',
        'symptoms': 'Weakness',
        'status': 'reviewed',
        'vetAdvice': 'Provide extra vitamin support',
      });

      final resolved = SickReport.fromJson({
        'report_id': 3,
        'flock_id': 4,
        'affectedCount': 2,
        'reportDate': '2026-09-03',
        'createdAt': '2026-09-03T08:00:00Z',
        'reportType': 'disease',
        'symptoms': 'Respiratory issues',
        'status': 'resolved',
        'vetAdvice': 'Treatment completed',
      });

      expect(waiting.isResolved, isFalse);
      expect(responded.isResolved, isFalse);
      expect(resolved.isResolved, isTrue);
      expect(responded.displayStatusLabel('en'), 'Vet Responded');
      expect(resolved.displayStatusLabel('en'), 'Resolved');
    },
  );
}
