import 'package:flutter/material.dart';
import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// Helper class for building data columns for records table header.
class RecordsDataColumn {
  const RecordsDataColumn._();

  /// Creates a DataColumn for a resource column.
  static DataColumn build(AdminColumn column) {
    return DataColumn(
      label: Row(
        children: [
          const Icon(Icons.view_column_outlined, size: 16),
          const SizedBox(width: 8),
          Text(column.name),
        ],
      ),
    );
  }
}
