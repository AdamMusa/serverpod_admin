import 'dart:io';

import 'admin_enum_values_platform.dart';

/// Returns the declared values for an enum type on the Serverpod VM.
List<String> discoverAdminEnumValues(
  Type enumType, {
  String? enumName,
  Iterable<Directory>? searchRoots,
}) {
  final reflected = discoverReflectedEnumValues(enumType);
  if (reflected.isNotEmpty) return reflected;

  final normalizedName = enumName?.split(RegExp(r'[:.]')).last.trim();
  if (normalizedName == null || normalizedName.isEmpty) return const [];

  final roots = searchRoots ?? [Directory('lib')];
  for (final root in roots) {
    if (!root.existsSync()) continue;
    for (final entity in root.listSync(recursive: true, followLinks: false)) {
      if (entity is! File || !entity.path.endsWith('.spy.yaml')) continue;
      final values = _readEnumValues(entity, normalizedName);
      if (values.isNotEmpty) return values;
    }
  }
  return const [];
}

List<String> _readEnumValues(File file, String enumName) {
  final lines = file.readAsLinesSync();
  final declaration = RegExp('^enum:\\s*${RegExp.escape(enumName)}\\s*\$');
  final enumLine = lines.indexWhere((line) => declaration.hasMatch(line));
  if (enumLine < 0) return const [];

  final valuesLine = lines.indexWhere(
    (line) => line.trim() == 'values:',
    enumLine + 1,
  );
  if (valuesLine < 0) return const [];

  final values = <String>[];
  for (final line in lines.skip(valuesLine + 1)) {
    final match = RegExp(r'^\s+-\s+([A-Za-z_$][\w$]*)\s*$').firstMatch(line);
    if (match != null) {
      values.add(match.group(1)!);
      continue;
    }
    if (line.trim().isNotEmpty) break;
  }
  return List.unmodifiable(values);
}
