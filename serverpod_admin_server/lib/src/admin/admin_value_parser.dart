import 'package:serverpod/serverpod.dart';

/// Converts string form values into the JSON representation expected by a
/// generated Serverpod model.
dynamic parseAdminColumnValue(Column column, String? raw) {
  if (raw == null) return null;
  final value = raw.trim();
  if (value.isEmpty) return null;

  if (column is ColumnInt || column is ColumnBigInt) {
    return int.tryParse(value);
  }
  if (column is ColumnDouble) {
    return double.tryParse(value);
  }
  if (column is ColumnBool) {
    final lowered = value.toLowerCase();
    if (lowered == 'true' || lowered == '1' || lowered == 'yes') return true;
    if (lowered == 'false' || lowered == '0' || lowered == 'no') return false;
    return null;
  }
  if (column is ColumnDateTime) {
    return DateTime.tryParse(value)?.toUtc().toIso8601String();
  }
  if (column is ColumnEnumExtended &&
      column.serialized == EnumSerialization.byIndex) {
    return int.tryParse(value);
  }
  return value;
}
