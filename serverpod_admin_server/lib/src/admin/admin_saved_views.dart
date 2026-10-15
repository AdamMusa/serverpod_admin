import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'admin_entry_base.dart';

/// Views administrators save for a table: a name for a set of filters, a
/// sort, a search and the columns shown. Each administrator sees only their
/// own.
class AdminSavedViews {
  const AdminSavedViews._();

  static const maxNameLength = 100;

  /// [owner]'s views of [resourceKey], by name.
  static Future<List<AdminSavedView>> list(
    Session session, {
    required String owner,
    required String resourceKey,
  }) => AdminSavedView.db.find(
    session,
    where: (t) => t.owner.equals(owner) & t.resourceKey.equals(resourceKey),
    orderBy: (t) => t.name,
  );

  /// Saves [query]'s search, sort and filters and the shown [columns] as
  /// [owner]'s view [name] of [entry], replacing their view of that name.
  static Future<AdminSavedView> save(
    Session session, {
    required String owner,
    required AdminEntryBase entry,
    required String name,
    required AdminQuery query,
    List<String>? columns,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw AdminValidationException(field: 'name', message: 'Name the view.');
    }
    if (trimmed.length > maxNameLength) {
      throw AdminValidationException(
        field: 'name',
        message: 'Use at most $maxNameLength characters for the name.',
      );
    }
    // Only columns the dashboard may see can be saved.
    final known = {for (final column in entry.metadata.columns) column.name};
    for (final name in [
      for (final filter in query.filters) filter.column,
      ?query.sortColumn,
      ...?columns,
    ]) {
      if (!known.contains(name)) {
        throw AdminValidationException(
          field: name,
          message: 'Unknown column $name.',
        );
      }
    }
    final search = query.search?.trim() ?? '';
    final values = AdminSavedView(
      owner: owner,
      resourceKey: entry.resourceKey,
      name: trimmed,
      search: search.isEmpty ? null : search,
      sortColumn: query.sortColumn,
      sortDescending: query.sortColumn != null && query.sortDescending,
      filters: query.filters,
      shownColumns: columns,
      updatedAt: DateTime.now().toUtc(),
    );
    final existing = await AdminSavedView.db.findFirstRow(
      session,
      where: (t) =>
          t.owner.equals(owner) &
          t.resourceKey.equals(entry.resourceKey) &
          t.name.equals(trimmed),
    );
    if (existing == null) return AdminSavedView.db.insertRow(session, values);
    return AdminSavedView.db.updateRow(
      session,
      values.copyWith(id: existing.id),
    );
  }

  /// Deletes [owner]'s view [id]; false when they have no such view.
  static Future<bool> delete(
    Session session, {
    required String owner,
    required int id,
  }) async {
    final deleted = await AdminSavedView.db.deleteWhere(
      session,
      where: (t) => t.id.equals(id) & t.owner.equals(owner),
    );
    return deleted.isNotEmpty;
  }
}
