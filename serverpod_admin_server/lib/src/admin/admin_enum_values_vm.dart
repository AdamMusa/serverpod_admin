import 'dart:mirrors';

List<String> discoverReflectedEnumValues(Type enumType) {
  final mirror = reflectType(enumType);
  if (mirror is! ClassMirror || !mirror.isEnum) return const [];

  try {
    final values = mirror.getField(#values).reflectee;
    if (values is! Iterable) return const [];
    return List.unmodifiable(
      values.whereType<Enum>().map((value) => value.name),
    );
  } catch (_) {
    return const [];
  }
}
