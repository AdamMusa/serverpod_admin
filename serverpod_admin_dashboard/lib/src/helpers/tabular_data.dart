import 'dart:convert';
import 'dart:typed_data';

import 'package:csv/csv.dart' as csv_lib;
import 'package:excel/excel.dart' hide Border;
import 'package:file_selector/file_selector.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

enum TabularFileFormat {
  csv('csv', 'text/csv'),
  xlsx(
    'xlsx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
  );

  const TabularFileFormat(this.extension, this.mimeType);

  final String extension;
  final String mimeType;
}

class TabularImportResult {
  const TabularImportResult({
    required this.created,
    required this.updated,
    required this.skipped,
  });

  final int created;
  final int updated;
  final int skipped;

  int get imported => created + updated;
}

class TabularDataFile {
  const TabularDataFile({
    required this.format,
    required this.rows,
  });

  final TabularFileFormat format;
  final List<Map<String, String>> rows;
}

class TabularDataHelper {
  static const _csvTypeGroup = XTypeGroup(
    label: 'CSV',
    extensions: ['csv'],
    mimeTypes: ['text/csv'],
  );

  static const _xlsxTypeGroup = XTypeGroup(
    label: 'Excel workbook',
    extensions: ['xlsx'],
    mimeTypes: [
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    ],
  );

  static Future<TabularDataFile?> pickImportFile() async {
    final file = await openFile(
      acceptedTypeGroups: const [_csvTypeGroup, _xlsxTypeGroup],
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    final format = _formatFromPath(file.name);
    final rows = format == TabularFileFormat.xlsx
        ? decodeXlsx(bytes)
        : decodeCsv(utf8.decode(bytes));

    return TabularDataFile(format: format, rows: rows);
  }

  static Future<bool> saveExportFile({
    required AdminResource resource,
    required List<Map<String, String>> records,
    required TabularFileFormat format,
  }) async {
    final safeName =
        resource.tableName.replaceAll(RegExp(r'[^a-zA-Z0-9_-]+'), '_');
    final fileName = '$safeName.${format.extension}';
    final bytes = format == TabularFileFormat.xlsx
        ? encodeXlsx(resource, records)
        : Uint8List.fromList(utf8.encode(encodeCsv(resource, records)));

    final location = await getSaveLocation(
      suggestedName: fileName,
      acceptedTypeGroups: [
        format == TabularFileFormat.xlsx ? _xlsxTypeGroup : _csvTypeGroup,
      ],
    );
    if (location == null) return false;

    await XFile.fromData(
      bytes,
      name: fileName,
      mimeType: format.mimeType,
    ).saveTo(location.path);
    return true;
  }

  static String encodeCsv(
    AdminResource resource,
    List<Map<String, String>> records,
  ) {
    final headers = _headersFor(resource);
    final table = <List<String>>[
      headers,
      for (final record in records)
        [for (final header in headers) record[header] ?? ''],
    ];
    return const csv_lib.ListToCsvConverter().convert(table);
  }

  static Uint8List encodeXlsx(
    AdminResource resource,
    List<Map<String, String>> records,
  ) {
    final headers = _headersFor(resource);
    final excel = Excel.createExcel();
    final sheet = excel['Records'];

    sheet.appendRow([for (final header in headers) TextCellValue(header)]);
    for (final record in records) {
      sheet.appendRow([
        for (final header in headers) TextCellValue(record[header] ?? ''),
      ]);
    }

    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    return Uint8List.fromList(excel.encode() ?? const <int>[]);
  }

  static List<Map<String, String>> decodeCsv(String content) {
    final rows = const csv_lib.CsvToListConverter(
      shouldParseNumbers: false,
    ).convert(content.trim());
    return _rowsToMaps(rows);
  }

  static List<Map<String, String>> decodeXlsx(Uint8List bytes) {
    final workbook = Excel.decodeBytes(bytes);
    if (workbook.tables.isEmpty) return const [];

    final sheet = workbook.tables.values.first;
    final rows = sheet.rows
        .map((row) => row.map((cell) => _cellToString(cell?.value)).toList())
        .toList();

    return _rowsToMaps(rows);
  }

  static List<String> _headersFor(AdminResource resource) {
    return resource.columns
        .map((column) => column.name)
        .toList(growable: false);
  }

  static List<Map<String, String>> _rowsToMaps(List<List<dynamic>> rows) {
    if (rows.isEmpty) return const [];

    final headers = rows.first.map(_cellToString).toList(growable: false);
    final result = <Map<String, String>>[];
    for (final row in rows.skip(1)) {
      final record = <String, String>{};
      var hasValue = false;

      for (var index = 0; index < headers.length; index++) {
        final header = headers[index].trim();
        if (header.isEmpty) continue;

        final value = index < row.length ? _cellToString(row[index]) : '';
        if (value.trim().isNotEmpty) hasValue = true;
        record[header] = value;
      }

      if (hasValue) result.add(record);
    }

    return result;
  }

  static String _cellToString(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) return value.toUtc().toIso8601String();
    return value.toString();
  }

  static TabularFileFormat _formatFromPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.xlsx')) return TabularFileFormat.xlsx;
    return TabularFileFormat.csv;
  }
}
