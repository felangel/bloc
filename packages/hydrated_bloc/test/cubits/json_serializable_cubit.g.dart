// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['name'] as String,
    json['age'] as int,
    _$enumDecodeNullable(_$ColorEnumMap, json['favoriteColor']),
    (json['todos'] as List)
        ?.map(
            // ignore: implicit_dynamic_parameter
            (e) => e == null ? null : Todo.fromJson(e as Map<String, dynamic>))
        ?.toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'favoriteColor': _$ColorEnumMap[instance.favoriteColor],
      'todos': instance.todos?.map((e) => e?.toJson())?.toList(),
    };

T _$enumDecode<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    throw ArgumentError('A value must be provided. Supported values: '
        '${enumValues.values.join(', ')}');
  }

  final value = enumValues.entries
      .singleWhere((e) => e.value == source, orElse: () => null)
      ?.key;

  if (value == null && unknownValue == null) {
    throw ArgumentError('`$source` is not one of the supported values: '
        '${enumValues.values.join(', ')}');
  }
  return value ?? unknownValue;
}

T _$enumDecodeNullable<T>(
  Map<T, dynamic> enumValues,
  dynamic source, {
  T unknownValue,
}) {
  if (source == null) {
    return null;
  }
  return _$enumDecode<T>(enumValues, source, unknownValue: unknownValue);
}

const _$ColorEnumMap = {
  Color.red: 'red',
  Color.green: 'green',
  Color.blue: 'blue',
};

Todo _$TodoFromJson(Map<String, dynamic> json) {
  return Todo(
    json['id'] as String,
    json['task'] as String,
  );
}

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'task': instance.task,
    };
