/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

/// Our AI generated person
abstract class Person implements _i1.SerializableModel {
  Person._({
    this.id,
    required this.name,
    required this.fullname,
    required this.sexe,
    required this.age,
  });

  factory Person({
    int? id,
    required String name,
    required String fullname,
    required String sexe,
    required int age,
  }) = _PersonImpl;

  factory Person.fromJson(Map<String, dynamic> jsonSerialization) {
    return Person(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      fullname: jsonSerialization['fullname'] as String,
      sexe: jsonSerialization['sexe'] as String,
      age: jsonSerialization['age'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The title of the  person
  String name;

  /// The fullname
  String fullname;

  /// The sexe
  String sexe;

  /// The date the  was created
  int age;

  /// Returns a shallow copy of this [Person]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Person copyWith({
    int? id,
    String? name,
    String? fullname,
    String? sexe,
    int? age,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'fullname': fullname,
      'sexe': sexe,
      'age': age,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PersonImpl extends Person {
  _PersonImpl({
    int? id,
    required String name,
    required String fullname,
    required String sexe,
    required int age,
  }) : super._(
          id: id,
          name: name,
          fullname: fullname,
          sexe: sexe,
          age: age,
        );

  /// Returns a shallow copy of this [Person]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Person copyWith({
    Object? id = _Undefined,
    String? name,
    String? fullname,
    String? sexe,
    int? age,
  }) {
    return Person(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      fullname: fullname ?? this.fullname,
      sexe: sexe ?? this.sexe,
      age: age ?? this.age,
    );
  }
}
