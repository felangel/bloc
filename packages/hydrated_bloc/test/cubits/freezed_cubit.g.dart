// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'freezed_cubit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Question _$$_QuestionFromJson(Map<String, dynamic> json) => _$_Question(
      id: json['id'] as int?,
      question: json['question'] as String?,
    );

Map<String, dynamic> _$$_QuestionToJson(_$_Question instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
    };

_$_QTree _$$_QTreeFromJson(Map<String, dynamic> json) => _$_QTree(
      question: json['question'] == null
          ? null
          : Question.fromJson(json['question'] as Map<String, dynamic>),
      left: json['left'] == null
          ? null
          : Tree.fromJson(json['left'] as Map<String, dynamic>),
      right: json['right'] == null
          ? null
          : Tree.fromJson(json['right'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_QTreeToJson(_$_QTree instance) => <String, dynamic>{
      'question': instance.question,
      'left': instance.left,
      'right': instance.right,
    };
