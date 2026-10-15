import 'package:serverpod_admin_dashboard/src/helpers/admin_resources.dart';

/// Columns of a resource shown together in forms and details: one of its
/// fieldsets, or all its columns when it has none.
class ColumnGroup {
  const ColumnGroup({
    required this.columns,
    this.name,
    this.description,
    this.collapsed = false,
  });

  /// Shown above the columns; null for an untitled group.
  final String? name;
  final String? description;

  /// Starts folded.
  final bool collapsed;
  final List<AdminColumn> columns;
}

/// [resource]'s columns grouped by its fieldsets, in their order, or one
/// untitled group of every column. Primary keys come first in details
/// ([withPrimary]) and are left out of forms.
List<ColumnGroup> columnGroups(
  AdminResource resource, {
  bool withPrimary = false,
}) {
  final byName = {for (final column in resource.columns) column.name: column};
  final primary = [
    for (final column in resource.columns)
      if (column.isPrimary) column,
  ];
  final fieldsets = resource.fieldsets;
  if (fieldsets == null) {
    return [
      ColumnGroup(
        columns: [
          for (final column in resource.columns)
            if (withPrimary || !column.isPrimary) column,
        ],
      ),
    ];
  }
  final groups = [
    for (final fieldset in fieldsets)
      ColumnGroup(
        name: fieldset.name,
        description: fieldset.description,
        collapsed: fieldset.collapsed,
        columns: [
          for (final name in fieldset.fields)
            if (byName[name] case final column?
                when withPrimary || !column.isPrimary)
              column,
        ],
      ),
  ]..removeWhere((group) => group.columns.isEmpty);
  final placed = {
    for (final group in groups)
      for (final column in group.columns) column.name,
  };
  final unplaced = [
    for (final column in primary)
      if (withPrimary && !placed.contains(column.name)) column,
  ];
  if (unplaced.isEmpty) return groups;
  // The key joins an untitled first group, or comes in its own.
  final first = groups.firstOrNull;
  if (first != null && first.name == null && first.description == null) {
    return [
      ColumnGroup(
        columns: [...unplaced, ...first.columns],
        collapsed: first.collapsed,
      ),
      ...groups.skip(1),
    ];
  }
  return [ColumnGroup(columns: unplaced), ...groups];
}
