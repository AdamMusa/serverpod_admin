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

/// AI Generation or App Configuration
abstract class Setting implements _i1.SerializableModel {
  Setting._({
    this.id,
    required this.theme,
    required this.detailLevel,
    required this.mood,
    required this.language,
    required this.features,
    required this.createdAt,
  });

  factory Setting({
    int? id,
    required String theme,
    required String detailLevel,
    required String mood,
    required String language,
    required List<String> features,
    required DateTime createdAt,
  }) = _SettingImpl;

  factory Setting.fromJson(Map<String, dynamic> jsonSerialization) {
    return Setting(
      id: jsonSerialization['id'] as int?,
      theme: jsonSerialization['theme'] as String,
      detailLevel: jsonSerialization['detailLevel'] as String,
      mood: jsonSerialization['mood'] as String,
      language: jsonSerialization['language'] as String,
      features: (jsonSerialization['features'] as List)
          .map((e) => e as String)
          .toList(),
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  /// The theme or style of the AI-generated content
  String theme;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  String detailLevel;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  String mood;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  String language;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  List<String> features;

  /// The theme or style of the AI-generated content
  /// Level of detail or complexity
  /// Mood or tone for content generation
  /// Language or locale
  /// List of features or options enabled
  /// Timestamp of creation or last update
  DateTime createdAt;

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Setting copyWith({
    int? id,
    String? theme,
    String? detailLevel,
    String? mood,
    String? language,
    List<String>? features,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'theme': theme,
      'detailLevel': detailLevel,
      'mood': mood,
      'language': language,
      'features': features.toJson(),
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _SettingImpl extends Setting {
  _SettingImpl({
    int? id,
    required String theme,
    required String detailLevel,
    required String mood,
    required String language,
    required List<String> features,
    required DateTime createdAt,
  }) : super._(
          id: id,
          theme: theme,
          detailLevel: detailLevel,
          mood: mood,
          language: language,
          features: features,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [Setting]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Setting copyWith({
    Object? id = _Undefined,
    String? theme,
    String? detailLevel,
    String? mood,
    String? language,
    List<String>? features,
    DateTime? createdAt,
  }) {
    return Setting(
      id: id is int? ? id : this.id,
      theme: theme ?? this.theme,
      detailLevel: detailLevel ?? this.detailLevel,
      mood: mood ?? this.mood,
      language: language ?? this.language,
      features: features ?? this.features.map((e0) => e0).toList(),
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
