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
import '../comment/comment.dart' as _i2;
import 'package:example_client/src/protocol/protocol.dart' as _i3;

/// Our AI generated post
abstract class Post implements _i1.SerializableModel {
  Post._({
    this.id,
    required this.title,
    this.comments,
    required this.description,
    required this.date,
    bool? isPublished,
  }) : isPublished = isPublished ?? false;

  factory Post({
    int? id,
    required String title,
    List<_i2.Comment>? comments,
    required String description,
    required DateTime date,
    bool? isPublished,
  }) = _PostImpl;

  factory Post.fromJson(Map<String, dynamic> jsonSerialization) {
    return Post(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      comments: jsonSerialization['comments'] == null
          ? null
          : _i3.Protocol().deserialize<List<_i2.Comment>>(
              jsonSerialization['comments'],
            ),
      description: jsonSerialization['description'] as String,
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      isPublished: jsonSerialization['isPublished'] == null
          ? null
          : _i1.BoolJsonExtension.fromJson(jsonSerialization['isPublished']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The title of the  post
  String title;

  /// post has multiple comments
  List<_i2.Comment>? comments;

  /// The description text
  String description;

  /// The date the  was created
  DateTime date;

  /// If the post is published
  bool isPublished;

  /// Returns a shallow copy of this [Post]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Post copyWith({
    int? id,
    String? title,
    List<_i2.Comment>? comments,
    String? description,
    DateTime? date,
    bool? isPublished,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Post',
      if (id != null) 'id': id,
      'title': title,
      if (comments != null)
        'comments': comments?.toJson(valueToJson: (v) => v.toJson()),
      'description': description,
      'date': date.toJson(),
      'isPublished': isPublished,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PostImpl extends Post {
  _PostImpl({
    int? id,
    required String title,
    List<_i2.Comment>? comments,
    required String description,
    required DateTime date,
    bool? isPublished,
  }) : super._(
         id: id,
         title: title,
         comments: comments,
         description: description,
         date: date,
         isPublished: isPublished,
       );

  /// Returns a shallow copy of this [Post]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Post copyWith({
    Object? id = _Undefined,
    String? title,
    Object? comments = _Undefined,
    String? description,
    DateTime? date,
    bool? isPublished,
  }) {
    return Post(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      comments: comments is List<_i2.Comment>?
          ? comments
          : this.comments?.map((e0) => e0.copyWith()).toList(),
      description: description ?? this.description,
      date: date ?? this.date,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
