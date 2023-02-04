// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'freezed_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
mixin _$Question {
  int? get id => throw _privateConstructorUsedError;
  String? get question => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QuestionCopyWith<Question> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res, Question>;
  @useResult
  $Res call({int? id, String? question});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res, $Val extends Question>
    implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$$_QuestionCopyWith(
          _$_Question value, $Res Function(_$_Question) then) =
      __$$_QuestionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String? question});
}

/// @nodoc
class __$$_QuestionCopyWithImpl<$Res>
    extends _$QuestionCopyWithImpl<$Res, _$_Question>
    implements _$$_QuestionCopyWith<$Res> {
  __$$_QuestionCopyWithImpl(
      _$_Question _value, $Res Function(_$_Question) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_$_Question(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Question implements _Question {
  const _$_Question({this.id, this.question});

  factory _$_Question.fromJson(Map<String, dynamic> json) =>
      _$$_QuestionFromJson(json);

  @override
  final int? id;
  @override
  final String? question;

  @override
  String toString() {
    return 'Question(id: $id, question: $question)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Question &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.question, question) ||
                other.question == question));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, question);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_QuestionCopyWith<_$_Question> get copyWith =>
      __$$_QuestionCopyWithImpl<_$_Question>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_QuestionToJson(
      this,
    );
  }
}

abstract class _Question implements Question {
  const factory _Question({final int? id, final String? question}) =
      _$_Question;

  factory _Question.fromJson(Map<String, dynamic> json) = _$_Question.fromJson;

  @override
  int? get id;
  @override
  String? get question;
  @override
  @JsonKey(ignore: true)
  _$$_QuestionCopyWith<_$_Question> get copyWith =>
      throw _privateConstructorUsedError;
}

Tree _$TreeFromJson(Map<String, dynamic> json) {
  return _QTree.fromJson(json);
}

/// @nodoc
mixin _$Tree {
  Question? get question => throw _privateConstructorUsedError;
  Tree? get left => throw _privateConstructorUsedError;
  Tree? get right => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TreeCopyWith<Tree> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeCopyWith<$Res> {
  factory $TreeCopyWith(Tree value, $Res Function(Tree) then) =
      _$TreeCopyWithImpl<$Res, Tree>;
  @useResult
  $Res call({Question? question, Tree? left, Tree? right});

  $QuestionCopyWith<$Res>? get question;
  $TreeCopyWith<$Res>? get left;
  $TreeCopyWith<$Res>? get right;
}

/// @nodoc
class _$TreeCopyWithImpl<$Res, $Val extends Tree>
    implements $TreeCopyWith<$Res> {
  _$TreeCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = freezed,
    Object? left = freezed,
    Object? right = freezed,
  }) {
    return _then(_value.copyWith(
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as Question?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as Tree?,
      right: freezed == right
          ? _value.right
          : right // ignore: cast_nullable_to_non_nullable
              as Tree?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $QuestionCopyWith<$Res>? get question {
    if (_value.question == null) {
      return null;
    }

    return $QuestionCopyWith<$Res>(_value.question!, (value) {
      return _then(_value.copyWith(question: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TreeCopyWith<$Res>? get left {
    if (_value.left == null) {
      return null;
    }

    return $TreeCopyWith<$Res>(_value.left!, (value) {
      return _then(_value.copyWith(left: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $TreeCopyWith<$Res>? get right {
    if (_value.right == null) {
      return null;
    }

    return $TreeCopyWith<$Res>(_value.right!, (value) {
      return _then(_value.copyWith(right: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$_QTreeCopyWith<$Res> implements $TreeCopyWith<$Res> {
  factory _$$_QTreeCopyWith(_$_QTree value, $Res Function(_$_QTree) then) =
      __$$_QTreeCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Question? question, Tree? left, Tree? right});

  @override
  $QuestionCopyWith<$Res>? get question;
  @override
  $TreeCopyWith<$Res>? get left;
  @override
  $TreeCopyWith<$Res>? get right;
}

/// @nodoc
class __$$_QTreeCopyWithImpl<$Res> extends _$TreeCopyWithImpl<$Res, _$_QTree>
    implements _$$_QTreeCopyWith<$Res> {
  __$$_QTreeCopyWithImpl(_$_QTree _value, $Res Function(_$_QTree) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? question = freezed,
    Object? left = freezed,
    Object? right = freezed,
  }) {
    return _then(_$_QTree(
      question: freezed == question
          ? _value.question
          : question // ignore: cast_nullable_to_non_nullable
              as Question?,
      left: freezed == left
          ? _value.left
          : left // ignore: cast_nullable_to_non_nullable
              as Tree?,
      right: freezed == right
          ? _value.right
          : right // ignore: cast_nullable_to_non_nullable
              as Tree?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_QTree implements _QTree {
  const _$_QTree({this.question, this.left, this.right});

  factory _$_QTree.fromJson(Map<String, dynamic> json) =>
      _$$_QTreeFromJson(json);

  @override
  final Question? question;
  @override
  final Tree? left;
  @override
  final Tree? right;

  @override
  String toString() {
    return 'Tree(question: $question, left: $left, right: $right)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_QTree &&
            (identical(other.question, question) ||
                other.question == question) &&
            (identical(other.left, left) || other.left == left) &&
            (identical(other.right, right) || other.right == right));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, question, left, right);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_QTreeCopyWith<_$_QTree> get copyWith =>
      __$$_QTreeCopyWithImpl<_$_QTree>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_QTreeToJson(
      this,
    );
  }
}

abstract class _QTree implements Tree {
  const factory _QTree(
      {final Question? question,
      final Tree? left,
      final Tree? right}) = _$_QTree;

  factory _QTree.fromJson(Map<String, dynamic> json) = _$_QTree.fromJson;

  @override
  Question? get question;
  @override
  Tree? get left;
  @override
  Tree? get right;
  @override
  @JsonKey(ignore: true)
  _$$_QTreeCopyWith<_$_QTree> get copyWith =>
      throw _privateConstructorUsedError;
}
