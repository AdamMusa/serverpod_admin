import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'admin_entry_base.dart';

/// The overview's numbers for every table, in two queries whatever the
/// number of tables: their row counts in one, their daily activity in the
/// other.
class AdminOverview {
  const AdminOverview._();

  /// Tables with more rows than this show Postgres's estimate, so the
  /// overview never scans a large table.
  static int exactCountLimit = 100000;

  static Future<List<AdminTableSummary>> summarize(
    Session session,
    List<AdminEntryBase> entries, {
    required int days,
  }) async {
    final counts = await _counts(session, entries);
    final activity = await dailyRows(session, entries, days: days);
    return [
      for (final entry in entries)
        AdminTableSummary(
          resourceKey: entry.resourceKey,
          count: counts[entry]?.count ?? -1,
          estimated: counts[entry]?.estimated ?? false,
          activity: activity[entry] ?? const [],
        ),
    ];
  }

  /// Each table's rows: counted up to [exactCountLimit] (reading no more
  /// than that), else estimated, all in one query. Tables read with a
  /// custom listRows are counted from it.
  static Future<Map<AdminEntryBase, ({int count, bool estimated})>> _counts(
    Session session,
    List<AdminEntryBase> entries,
  ) async {
    final counts = <AdminEntryBase, ({int count, bool estimated})>{};
    final stored = [
      for (final entry in entries)
        if (entry.readsInDatabase) entry,
    ];
    if (stored.isNotEmpty) {
      try {
        final rows = await session.db.unsafeQuery(
          [
            for (final (index, entry) in stored.indexed)
              'SELECT $index, '
                  '(SELECT count(*) FROM (SELECT 1 FROM '
                  '${_identifier(entry.tableName)} '
                  'LIMIT ${exactCountLimit + 1}) capped), '
                  '(SELECT reltuples::bigint FROM pg_class '
                  'WHERE oid = to_regclass(${_text(_identifier(entry.tableName))}))',
          ].join(' UNION ALL '),
        );
        for (final row in rows) {
          final entry = stored[row[0] as int];
          final counted = row[1] as int;
          final estimate = row[2] as int? ?? -1;
          counts[entry] = counted <= exactCountLimit
              ? (count: counted, estimated: false)
              : (
                  count: estimate > counted ? estimate : counted,
                  estimated: true,
                );
        }
      } catch (error) {
        session.log(
          'serverpod_admin: overview counts failed ($error)',
          level: LogLevel.warning,
        );
      }
    }
    for (final entry in entries) {
      if (entry.readsInDatabase) continue;
      try {
        counts[entry] = (
          count: (await entry.listRows(session)).length,
          estimated: false,
        );
      } catch (_) {
        // Shown as unknown.
      }
    }
    return counts;
  }

  /// Rows added per day over the last [days] days by each table's chart
  /// column, in one query.
  static Future<Map<AdminEntryBase, List<AdminActivityPoint>>> dailyRows(
    Session session,
    List<AdminEntryBase> entries, {
    required int days,
  }) async {
    final charted = [
      for (final entry in entries)
        if (chartColumn(entry) case final column? when entry.readsInDatabase)
          (entry, column),
    ];
    final activity = <AdminEntryBase, List<AdminActivityPoint>>{};
    if (charted.isEmpty) return activity;
    try {
      final rows = await session.db.unsafeQuery(
        '${[for (final (index, (entry, column)) in charted.indexed) 'SELECT $index, date_trunc(\'day\', ${_identifier(column)}) AS day, '
              'count(*) FROM ${_identifier(entry.tableName)} '
              'WHERE ${_identifier(column)} >= '
              'now() - make_interval(days => @days) GROUP BY 2'].join(' UNION ALL ')} ORDER BY 1, 2',
        parameters: QueryParameters.named({'days': days.clamp(1, 366)}),
      );
      for (final row in rows) {
        final (entry, _) = charted[row[0] as int];
        (activity[entry] ??= []).add(
          AdminActivityPoint(
            day: (row[1] as DateTime).toUtc(),
            count: row[2] as int,
          ),
        );
      }
    } catch (error) {
      session.log(
        'serverpod_admin: overview activity failed ($error)',
        level: LogLevel.warning,
      );
    }
    return activity;
  }

  /// The stored date column [entry]'s overview charts, if any.
  static String? chartColumn(AdminEntryBase entry) {
    final name = entry.metadata.chartColumn;
    return entry.columns
        .where((c) => c.columnName == name && c is ColumnDateTime)
        .firstOrNull
        ?.columnName;
  }

  static String _identifier(String name) => '"${name.replaceAll('"', '""')}"';

  static String _text(String value) => "'${value.replaceAll("'", "''")}'";
}
