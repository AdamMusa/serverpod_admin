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
import 'comment/comment.dart' as _i2;
import 'greeting.dart' as _i3;
import 'person/person.dart' as _i4;
import 'post/post.dart' as _i5;
import 'setting/setting.dart' as _i6;
import 'package:serverpod_admin_client/serverpod_admin_client.dart' as _i7;
export 'comment/comment.dart';
export 'greeting.dart';
export 'person/person.dart';
export 'post/post.dart';
export 'setting/setting.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Comment) {
      return _i2.Comment.fromJson(data) as T;
    }
    if (t == _i3.Greeting) {
      return _i3.Greeting.fromJson(data) as T;
    }
    if (t == _i4.Person) {
      return _i4.Person.fromJson(data) as T;
    }
    if (t == _i5.Post) {
      return _i5.Post.fromJson(data) as T;
    }
    if (t == _i6.Setting) {
      return _i6.Setting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Comment?>()) {
      return (data != null ? _i2.Comment.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.Greeting?>()) {
      return (data != null ? _i3.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Person?>()) {
      return (data != null ? _i4.Person.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Post?>()) {
      return (data != null ? _i5.Post.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Setting?>()) {
      return (data != null ? _i6.Setting.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    try {
      return _i7.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Comment) {
      return 'Comment';
    }
    if (data is _i3.Greeting) {
      return 'Greeting';
    }
    if (data is _i4.Person) {
      return 'Person';
    }
    if (data is _i5.Post) {
      return 'Post';
    }
    if (data is _i6.Setting) {
      return 'Setting';
    }
    className = _i7.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_admin.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Comment') {
      return deserialize<_i2.Comment>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i3.Greeting>(data['data']);
    }
    if (dataClassName == 'Person') {
      return deserialize<_i4.Person>(data['data']);
    }
    if (dataClassName == 'Post') {
      return deserialize<_i5.Post>(data['data']);
    }
    if (dataClassName == 'Setting') {
      return deserialize<_i6.Setting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_admin.')) {
      data['className'] = dataClassName.substring(16);
      return _i7.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }
}
