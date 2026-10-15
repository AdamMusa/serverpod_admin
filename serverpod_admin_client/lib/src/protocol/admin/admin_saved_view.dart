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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../admin/admin_filter.dart' as _i2;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i3;

/// Filters, sort, search and visible columns an administrator saved under a
/// name for one table, to apply again later. Views are personal.
abstract class AdminSavedView
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminSavedView._({
    this.id,
    required this.owner,
    required this.resourceKey,
    required this.name,
    this.search,
    this.sortColumn,
    required this.sortDescending,
    required this.filters,
    this.shownColumns,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  factory AdminSavedView({
    int? id,
    required String owner,
    required String resourceKey,
    required String name,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  }) = _AdminSavedViewImpl;

  factory AdminSavedView.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminSavedView(
      id: jsonSerialization['id'] as int?,
      owner: jsonSerialization['owner'] as String,
      resourceKey: jsonSerialization['resourceKey'] as String,
      name: jsonSerialization['name'] as String,
      search: jsonSerialization['search'] as String?,
      sortColumn: jsonSerialization['sortColumn'] as String?,
      sortDescending: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['sortDescending'],
      ),
      filters: _i3.Protocol().deserialize<List<_i2.AdminFilter>>(
        jsonSerialization['filters'],
      ),
      shownColumns: jsonSerialization['shownColumns'] == null
          ? null
          : _i3.Protocol().deserialize<List<String>>(
              jsonSerialization['shownColumns'],
            ),
      updatedAt: jsonSerialization['updatedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The auth user id of the administrator who saved it.
  String owner;

  String resourceKey;

  String name;

  /// Text matched against the table's searched columns.
  String? search;

  /// The chosen sort; none keeps the table's default order.
  String? sortColumn;

  bool sortDescending;

  List<_i2.AdminFilter> filters;

  /// The columns shown in the table; none keeps the table's defaults.
  List<String>? shownColumns;

  DateTime updatedAt;

  /// Returns a shallow copy of this [AdminSavedView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminSavedView copyWith({
    int? id,
    String? owner,
    String? resourceKey,
    String? name,
    String? search,
    String? sortColumn,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminSavedView',
      if (id != null) 'id': id,
      'owner': owner,
      'resourceKey': resourceKey,
      'name': name,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJson()),
      if (shownColumns != null) 'shownColumns': shownColumns?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminSavedView',
      if (id != null) 'id': id,
      'owner': owner,
      'resourceKey': resourceKey,
      'name': name,
      if (search != null) 'search': search,
      if (sortColumn != null) 'sortColumn': sortColumn,
      'sortDescending': sortDescending,
      'filters': filters.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (shownColumns != null) 'shownColumns': shownColumns?.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminSavedViewImpl extends AdminSavedView {
  _AdminSavedViewImpl({
    int? id,
    required String owner,
    required String resourceKey,
    required String name,
    String? search,
    String? sortColumn,
    required bool sortDescending,
    required List<_i2.AdminFilter> filters,
    List<String>? shownColumns,
    DateTime? updatedAt,
  }) : super._(
         id: id,
         owner: owner,
         resourceKey: resourceKey,
         name: name,
         search: search,
         sortColumn: sortColumn,
         sortDescending: sortDescending,
         filters: filters,
         shownColumns: shownColumns,
         updatedAt: updatedAt,
       );

  /// Returns a shallow copy of this [AdminSavedView]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminSavedView copyWith({
    Object? id = _Undefined,
    String? owner,
    String? resourceKey,
    String? name,
    Object? search = _Undefined,
    Object? sortColumn = _Undefined,
    bool? sortDescending,
    List<_i2.AdminFilter>? filters,
    Object? shownColumns = _Undefined,
    DateTime? updatedAt,
  }) {
    return AdminSavedView(
      id: id is int? ? id : this.id,
      owner: owner ?? this.owner,
      resourceKey: resourceKey ?? this.resourceKey,
      name: name ?? this.name,
      search: search is String? ? search : this.search,
      sortColumn: sortColumn is String? ? sortColumn : this.sortColumn,
      sortDescending: sortDescending ?? this.sortDescending,
      filters: filters ?? this.filters.map((e0) => e0.copyWith()).toList(),
      shownColumns: shownColumns is List<String>?
          ? shownColumns
          : this.shownColumns?.map((e0) => e0).toList(),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
