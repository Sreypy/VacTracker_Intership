import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/services/vaccination_pdf_service.dart';

void main() {
  group('VaccinationPdfService', () {
    test('buildPdfContent includes flock and vaccination details', () {
      final service = VaccinationPdfService();

      final content = service.buildPdfContent(
        flockId: '101',
        flockName: 'Layer Batch A',
        languageCode: 'en',
        records: [
          {
            'title': 'Newcastle Vaccine',
            'subtitle': 'Newcastle disease',
            'date': 'Apr 10, 2026',
            'status': 'Done',
          },
          {
            'title': 'IBV Vaccine',
            'subtitle': 'Gumboro disease',
            'date': 'Apr 20, 2026',
            'status': 'Missed',
          },
        ],
      );

      expect(content, contains('Vaccination History'));
      expect(content, contains('Flock ID: 101'));
      expect(content, contains('Layer Batch A'));
      expect(content, contains('Newcastle Vaccine'));
      expect(content, contains('IBV Vaccine'));
      expect(content, contains('Gumboro disease'));
    });
  });
}
