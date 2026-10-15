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
import '../admin/admin_column.dart' as _i2;
import '../admin/admin_action_info.dart' as _i3;
import '../admin/admin_fieldset_info.dart' as _i4;
import 'package:serverpod_admin_client/src/protocol/protocol.dart' as _i5;

abstract class AdminResource
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminResource._({
    required this.key,
    required this.tableName,
    required this.columns,
    this.actions,
    this.label,
    this.group,
    this.listColumns,
    this.sortColumn,
    this.sortDescending,
    this.canCreate,
    this.canEdit,
    this.canDelete,
    this.chartColumn,
    this.fieldsets,
  });

  factory AdminResource({
    required String key,
    required String tableName,
    required List<_i2.AdminColumn> columns,
    List<_i3.AdminActionInfo>? actions,
    String? label,
    String? group,
    List<String>? listColumns,
    String? sortColumn,
    bool? sortDescending,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
    String? chartColumn,
    List<_i4.AdminFieldsetInfo>? fieldsets,
  }) = _AdminResourceImpl;

  factory AdminResource.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminResource(
      key: jsonSerialization['key'] as String,
      tableName: jsonSerialization['tableName'] as String,
      columns: _i5.Protocol().deserialize<List<_i2.AdminColumn>>(
        jsonSerialization['columns'],
      ),
      actions: jsonSerialization['actions'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i3.AdminActionInfo>>(
              jsonSerialization['actions'],
            ),
      label: jsonSerialization['label'] as String?,
      group: jsonSerialization['group'] as String?,
      listColumns: jsonSerialization['listColumns'] == null
          ? null
          : _i5.Protocol().deserialize<List<String>>(
              jsonSerialization['listColumns'],
            ),
      sortColumn: jsonSerialization['sortColumn'] as String?,
      sortDescending: jsonSerialization['sortDescending'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['sortDescending']),
      canCreate: jsonSerialization['canCreate'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['canCreate']),
      canEdit: jsonSerialization['canEdit'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['canEdit']),
      canDelete: jsonSerialization['canDelete'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['canDelete']),
      chartColumn: jsonSerialization['chartColumn'] as String?,
      fieldsets: jsonSerialization['fieldsets'] == null
          ? null
          : _i5.Protocol().deserialize<List<_i4.AdminFieldsetInfo>>(
              jsonSerialization['fieldsets'],
            ),
    );
  }

  String key;

  String tableName;

  List<_i2.AdminColumn> columns;

  /// Custom actions for selected rows.
  List<_i3.AdminActionInfo>? actions;

  /// Shown in place of the table name.
  String? label;

  /// Groups resources in the sidebar.
  String? group;

  /// Columns shown in the table at first; the others can be turned on.
  List<String>? listColumns;

  /// The default sort, when the administrator has not chosen one.
  String? sortColumn;

  bool? sortDescending;

  /// What the signed-in administrator may do here (null means allowed).
  bool? canCreate;

  bool? canEdit;

  bool? canDelete;

  /// A date column whose daily counts the overview charts.
  String? chartColumn;

  /// Groups of fields shown together in forms and details, in order. The
  /// columns no group names (except the primary key) end in a group
  /// named "Other".
  List<_i4.AdminFieldsetInfo>? fieldsets;

  /// Returns a shallow copy of this [AdminResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminResource copyWith({
    String? key,
    String? tableName,
    List<_i2.AdminColumn>? columns,
    List<_i3.AdminActionInfo>? actions,
    String? label,
    String? group,
    List<String>? listColumns,
    String? sortColumn,
    bool? sortDescending,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
    String? chartColumn,
    List<_i4.AdminFieldsetInfo>? fieldsets,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminResource',
      'key': key,
      'tableName': tableName,
      'columns': columns.toJson(valueToJson: (v) => v.toJson()),
      if (actions != null)
        'actions': actions?.toJson(valueToJson: (v) => v.toJson()),
      if (label != null) 'label': label,
      if (group != null) 'group': group,
      if (listColumns != null) 'listColumns': listColumns?.toJson(),
      if (sortColumn != null) 'sortColumn': sortColumn,
      if (sortDescending != null) 'sortDescending': sortDescending,
      if (canCreate != null) 'canCreate': canCreate,
      if (canEdit != null) 'canEdit': canEdit,
      if (canDelete != null) 'canDelete': canDelete,
      if (chartColumn != null) 'chartColumn': chartColumn,
      if (fieldsets != null)
        'fieldsets': fieldsets?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminResource',
      'key': key,
      'tableName': tableName,
      'columns': columns.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (actions != null)
        'actions': actions?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (label != null) 'label': label,
      if (group != null) 'group': group,
      if (listColumns != null) 'listColumns': listColumns?.toJson(),
      if (sortColumn != null) 'sortColumn': sortColumn,
      if (sortDescending != null) 'sortDescending': sortDescending,
      if (canCreate != null) 'canCreate': canCreate,
      if (canEdit != null) 'canEdit': canEdit,
      if (canDelete != null) 'canDelete': canDelete,
      if (chartColumn != null) 'chartColumn': chartColumn,
      if (fieldsets != null)
        'fieldsets': fieldsets?.toJson(
          valueToJson: (v) => v.toJsonForProtocol(),
        ),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminResourceImpl extends AdminResource {
  _AdminResourceImpl({
    required String key,
    required String tableName,
    required List<_i2.AdminColumn> columns,
    List<_i3.AdminActionInfo>? actions,
    String? label,
    String? group,
    List<String>? listColumns,
    String? sortColumn,
    bool? sortDescending,
    bool? canCreate,
    bool? canEdit,
    bool? canDelete,
    String? chartColumn,
    List<_i4.AdminFieldsetInfo>? fieldsets,
  }) : super._(
         key: key,
         tableName: tableName,
         columns: columns,
         actions: actions,
         label: label,
         group: group,
         listColumns: listColumns,
         sortColumn: sortColumn,
         sortDescending: sortDescending,
         canCreate: canCreate,
         canEdit: canEdit,
         canDelete: canDelete,
         chartColumn: chartColumn,
         fieldsets: fieldsets,
       );

  /// Returns a shallow copy of this [AdminResource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminResource copyWith({
    String? key,
    String? tableName,
    List<_i2.AdminColumn>? columns,
    Object? actions = _Undefined,
    Object? label = _Undefined,
    Object? group = _Undefined,
    Object? listColumns = _Undefined,
    Object? sortColumn = _Undefined,
    Object? sortDescending = _Undefined,
    Object? canCreate = _Undefined,
    Object? canEdit = _Undefined,
    Object? canDelete = _Undefined,
    Object? chartColumn = _Undefined,
    Object? fieldsets = _Undefined,
  }) {
    return AdminResource(
      key: key ?? this.key,
      tableName: tableName ?? this.tableName,
      columns: columns ?? this.columns.map((e0) => e0.copyWith()).toList(),
      actions: actions is List<_i3.AdminActionInfo>?
          ? actions
          : this.actions?.map((e0) => e0.copyWith()).toList(),
      label: label is String? ? label : this.label,
      group: group is String? ? group : this.group,
      listColumns: listColumns is List<String>?
          ? listColumns
          : this.listColumns?.map((e0) => e0).toList(),
      sortColumn: sortColumn is String? ? sortColumn : this.sortColumn,
      sortDescending: sortDescending is bool?
          ? sortDescending
          : this.sortDescending,
      canCreate: canCreate is bool? ? canCreate : this.canCreate,
      canEdit: canEdit is bool? ? canEdit : this.canEdit,
      canDelete: canDelete is bool? ? canDelete : this.canDelete,
      chartColumn: chartColumn is String? ? chartColumn : this.chartColumn,
      fieldsets: fieldsets is List<_i4.AdminFieldsetInfo>?
          ? fieldsets
          : this.fieldsets?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
