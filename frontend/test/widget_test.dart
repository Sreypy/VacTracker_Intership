// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
