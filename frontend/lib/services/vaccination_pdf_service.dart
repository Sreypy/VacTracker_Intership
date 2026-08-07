import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class VaccinationPdfService {
  Future<String?> exportHistoryPdf({
    required String flockId,
    required String flockName,
    required String languageCode,
    required List<Map<String, dynamic>> records,
    required BuildContext context,
  }) async {
    try {
      final filePath = await _createPdfFile(
        flockId: flockId,
        flockName: flockName,
        languageCode: languageCode,
        records: records,
      );

      if (filePath == null) {
        return null;
      }

      if (!context.mounted) {
        return filePath;
      }

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(filePath)],
          subject: 'Vaccination History',
          sharePositionOrigin: Rect.fromLTWH(0, 0, 0, 0),
        ),
      );

      return filePath;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _createPdfFile({
    required String flockId,
    required String flockName,
    required String languageCode,
    required List<Map<String, dynamic>> records,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${dir.path}/vaccination_history_$timestamp.pdf');

    final content = buildPdfContent(
      flockId: flockId,
      flockName: flockName,
      languageCode: languageCode,
      records: records,
    );

    await file.writeAsString(content);
    return file.path;
  }

  String buildPdfContent({
    required String flockId,
    required String flockName,
    required String languageCode,
    required List<Map<String, dynamic>> records,
  }) {
    final title = languageCode == 'km'
        ? 'ប្រវត្តិការចាក់វ៉ាក់សាំង'
        : 'Vaccination History';
    final lines = <String>[
      title,
      '',
      languageCode == 'km' ? 'លេខសម្គាល់ហ្វូង: $flockId' : 'Flock ID: $flockId',
      languageCode == 'km'
          ? 'ឈ្មោះហ្វូង: $flockName'
          : 'Flock Name: $flockName',
      '',
    ];

    for (final record in records) {
      final titleText = record['title']?.toString() ?? '';
      final subtitle = record['subtitle']?.toString() ?? '';
      final date = record['date']?.toString() ?? '';
      final status = record['status']?.toString() ?? '';

      lines.add(titleText);
      if (subtitle.isNotEmpty) {
        lines.add('  $subtitle');
      }
      if (date.isNotEmpty) {
        lines.add('  Date: $date');
      }
      if (status.isNotEmpty) {
        lines.add('  Status: $status');
      }
      lines.add('');
    }

    return lines.join('\n');
  }
}
