/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../admin/admin_filter.dart' as _i2;
import 'package:serverpod_admin_server/src/generated/protocol.dart' as _i3;

/// Which page of a resource's rows to return, and how to narrow and order
/// them. Paging, sorting, search and filters run in the database.
abstract class AdminQuery
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminQuery._({
    required this.offset,
    required this.limit,
    this.search,
    this.sortColumn,
    required this.sortDescending,
    required this.filters,
  });

  factory AdminQuery({
    required int offset,
    required int limit,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
  }) = _AdminQueryImpl;

  factory AdminQuery.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminQuery(
      offset: jsonSerialization['offset'] as int,
      limit: jsonSerialization['limit'] as int,
      search: jsonSerialization['search'] as String?,
      sortColumn: jsonSerialization['sortColumn'] as String?,
      sortDescending: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['sortDescending'],
      ),
      filters: _i3.Protocol().deserialize<List<_i2.AdminFilter>>(
        jsonSerialization['filters'],
      ),
    );
  }

  int offset;

  int limit;

  /// Text matched against every text-like column.
  String? search;

  String? sortColumn;

  bool sortDescending;

  List<_i2.AdminFilter> filters;

  /// Returns a shallow copy of this [AdminQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminQuery copyWith({
    int? offset,
    int? limit,
    String? search,
    String? sortColumn,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminQuery',
      'offset': offset,
      'limit': limit,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminQuery',
      'offset': offset,
      'limit': limit,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminQueryImpl extends AdminQuery {
  _AdminQueryImpl({
    required int offset,
    required int limit,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
  }) : super._(
         offset: offset,
         limit: limit,
         search: search,
         sortColumn: sortColumn,
         sortDescending: sortDescending,
         filters: filters,
       );

  /// Returns a shallow copy of this [AdminQuery]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminQuery copyWith({
    int? offset,
    int? limit,
    Object? search = _Undefined,
    Object? sortColumn = _Undefined,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
  }) {
    return AdminQuery(
      offset: offset ?? this.offset,
      limit: limit ?? this.limit,
      search: search is String? ? search : this.search,
      sortColumn: sortColumn is String? ? sortColumn : this.sortColumn,
      sortDescending: sortDescending ?? this.sortDescending,
      filters: filters ?? this.filters.map((e0) => e0.copyWith()).toList(),
    );
  }
}
