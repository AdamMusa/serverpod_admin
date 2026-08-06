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
import 'package:serverpod_admin_server/src/generated/protocol.dart' as _i2;

abstract class AdminColumn
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  AdminColumn._({
    required this.name,
    required this.dataType,
    required this.hasDefault,
    required this.isPrimary,
    this.foreignKeyTable,
    this.defaultValue,
    this.enumValues,
    this.enumSerializedByName,
    this.isNullable,
  });

  factory AdminColumn({
    required String name,
    required String dataType,
    required bool hasDefault,
    required bool isPrimary,
    String? foreignKeyTable,
    String? defaultValue,
    List<String>? enumValues,
    bool? enumSerializedByName,
    bool? isNullable,
  }) = _AdminColumnImpl;

  factory AdminColumn.fromJson(Map<String, dynamic> jsonSerialization) {
    return AdminColumn(
      name: jsonSerialization['name'] as String,
      dataType: jsonSerialization['dataType'] as String,
      hasDefault: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['hasDefault'],
      ),
      isPrimary: _i1.BoolJsonExtension.fromJson(jsonSerialization['isPrimary']),
      foreignKeyTable: jsonSerialization['foreignKeyTable'] as String?,
      defaultValue: jsonSerialization['defaultValue'] as String?,
      enumValues: jsonSerialization['enumValues'] == null
          ? null
          : _i2.Protocol().deserialize<List<String>>(
              jsonSerialization['enumValues'],
            ),
      enumSerializedByName: jsonSerialization['enumSerializedByName'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(
              jsonSerialization['enumSerializedByName'],
            ),
      isNullable: jsonSerialization['isNullable'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isNullable']),
    );
  }

  String name;

  String dataType;

  bool hasDefault;

  bool isPrimary;

  String? foreignKeyTable;

  String? defaultValue;

  List<String>? enumValues;

  bool? enumSerializedByName;

  bool? isNullable;

  /// Returns a shallow copy of this [AdminColumn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AdminColumn copyWith({
    String? name,
    String? dataType,
    bool? hasDefault,
    bool? isPrimary,
    String? foreignKeyTable,
    String? defaultValue,
    List<String>? enumValues,
    bool? enumSerializedByName,
    bool? isNullable,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'serverpod_admin.AdminColumn',
      'name': name,
      'dataType': dataType,
      'hasDefault': hasDefault,
      'isPrimary': isPrimary,
      if (foreignKeyTable != null) 'foreignKeyTable': foreignKeyTable,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (enumValues != null) 'enumValues': enumValues?.toJson(),
      if (enumSerializedByName != null)
        'enumSerializedByName': enumSerializedByName,
      if (isNullable != null) 'isNullable': isNullable,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'serverpod_admin.AdminColumn',
      'name': name,
      'dataType': dataType,
      'hasDefault': hasDefault,
      'isPrimary': isPrimary,
      if (foreignKeyTable != null) 'foreignKeyTable': foreignKeyTable,
      if (defaultValue != null) 'defaultValue': defaultValue,
      if (enumValues != null) 'enumValues': enumValues?.toJson(),
      if (enumSerializedByName != null)
        'enumSerializedByName': enumSerializedByName,
      if (isNullable != null) 'isNullable': isNullable,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AdminColumnImpl extends AdminColumn {
  _AdminColumnImpl({
    required String name,
    required String dataType,
    required bool hasDefault,
    required bool isPrimary,
    String? foreignKeyTable,
    String? defaultValue,
    List<String>? enumValues,
    bool? enumSerializedByName,
    bool? isNullable,
  }) : super._(
         name: name,
         dataType: dataType,
         hasDefault: hasDefault,
         isPrimary: isPrimary,
         foreignKeyTable: foreignKeyTable,
         defaultValue: defaultValue,
         enumValues: enumValues,
         enumSerializedByName: enumSerializedByName,
         isNullable: isNullable,
       );

  /// Returns a shallow copy of this [AdminColumn]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AdminColumn copyWith({
    String? name,
    String? dataType,
    bool? hasDefault,
    bool? isPrimary,
    Object? foreignKeyTable = _Undefined,
    Object? defaultValue = _Undefined,
    Object? enumValues = _Undefined,
    Object? enumSerializedByName = _Undefined,
    Object? isNullable = _Undefined,
  }) {
    return AdminColumn(
      name: name ?? this.name,
      dataType: dataType ?? this.dataType,
      hasDefault: hasDefault ?? this.hasDefault,
      isPrimary: isPrimary ?? this.isPrimary,
      foreignKeyTable: foreignKeyTable is String?
          ? foreignKeyTable
          : this.foreignKeyTable,
      defaultValue: defaultValue is String? ? defaultValue : this.defaultValue,
      enumValues: enumValues is List<String>?
          ? enumValues
          : this.enumValues?.map((e0) => e0).toList(),
      enumSerializedByName: enumSerializedByName is bool?
          ? enumSerializedByName
          : this.enumSerializedByName,
      isNullable: isNullable is bool? ? isNullable : this.isNullable,
    );
  }
}
