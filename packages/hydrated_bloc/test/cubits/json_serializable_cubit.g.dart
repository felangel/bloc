// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'json_serializable_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['name'] as String,
    json['age'] as int,
    _$enumDecode(_$ColorEnumMap, json['favoriteColor']),
    (json['todos'] as List<dynamic>)
        .map((dynamic e) => Todo.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'favoriteColor': _$ColorEnumMap[instance.favoriteColor],
      'todos': instance.todos.map((e) => e.toJson()).toList(),
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
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
