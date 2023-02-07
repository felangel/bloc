// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'json_serializable_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      json['name'] as String,
      json['age'] as int,
      $enumDecode(_$ColorEnumMap, json['favoriteColor']),
      (json['todos'] as List<dynamic>)
          .map((e) => Todo.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'name': instance.name,
      'age': instance.age,
      'favoriteColor': _$ColorEnumMap[instance.favoriteColor]!,
      'todos': instance.todos.map((e) => e.toJson()).toList(),
    };

const _$ColorEnumMap = {
  Color.red: 'red',
  Color.green: 'green',
  Color.blue: 'blue',
};

Todo _$TodoFromJson(Map<String, dynamic> json) => Todo(
      json['id'] as String,
      json['task'] as String,
    );

Map<String, dynamic> _$TodoToJson(Todo instance) => <String, dynamic>{
      'id': instance.id,
      'task': instance.task,
    };
