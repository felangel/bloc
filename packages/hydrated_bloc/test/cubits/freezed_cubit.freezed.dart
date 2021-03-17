// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'freezed_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Question _$QuestionFromJson(Map<String, dynamic> json) {
  return _Question.fromJson(json);
}

/// @nodoc
class _$QuestionTearOff {
  const _$QuestionTearOff();

  _Question call({int? id, String? question}) {
    return _Question(
      id: id,
      question: question,
    );
  }

  Question fromJson(Map<String, Object> json) {
    return Question.fromJson(json);
  }
}

/// @nodoc
const $Question = _$QuestionTearOff();

/// @nodoc
mixin _$Question {
  int? get id;
  String? get question;

  Map<String, dynamic> toJson();
  @JsonKey(ignore: true)
  $QuestionCopyWith<Question> get copyWith;
}

/// @nodoc
abstract class $QuestionCopyWith<$Res> {
  factory $QuestionCopyWith(Question value, $Res Function(Question) then) =
      _$QuestionCopyWithImpl<$Res>;
  $Res call({int? id, String? question});
}

/// @nodoc
class _$QuestionCopyWithImpl<$Res> implements $QuestionCopyWith<$Res> {
  _$QuestionCopyWithImpl(this._value, this._then);

  final Question _value;
  // ignore: unused_field
  final $Res Function(Question) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed ? _value.id : id as int?,
      question: question == freezed ? _value.question : question as String?,
    ));
  }
}

/// @nodoc
abstract class _$QuestionCopyWith<$Res> implements $QuestionCopyWith<$Res> {
  factory _$QuestionCopyWith(_Question value, $Res Function(_Question) then) =
      __$QuestionCopyWithImpl<$Res>;
  @override
  $Res call({int? id, String? question});
}

/// @nodoc
class __$QuestionCopyWithImpl<$Res> extends _$QuestionCopyWithImpl<$Res>
    implements _$QuestionCopyWith<$Res> {
  __$QuestionCopyWithImpl(_Question _value, $Res Function(_Question) _then)
      : super(_value, (v) => _then(v as _Question));

  @override
  _Question get _value => super._value as _Question;

  @override
  $Res call({
    Object? id = freezed,
    Object? question = freezed,
  }) {
    return _then(_Question(
      id: id == freezed ? _value.id : id as int?,
      question: question == freezed ? _value.question : question as String?,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_Question implements _Question {
  const _$_Question({this.id, this.question});

  factory _$_Question.fromJson(Map<String, dynamic> json) =>
      _$_$_QuestionFromJson(json);

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
        (other is _Question &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.question, question) ||
                const DeepCollectionEquality()
                    .equals(other.question, question)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(question);

  @JsonKey(ignore: true)
  @override
  _$QuestionCopyWith<_Question> get copyWith =>
      __$QuestionCopyWithImpl<_Question>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_QuestionToJson(this);
  }
}

abstract class _Question implements Question {
  const factory _Question({int? id, String? question}) = _$_Question;

  factory _Question.fromJson(Map<String, dynamic> json) = _$_Question.fromJson;

  @override
  int? get id;
  @override
  String? get question;
  @override
  @JsonKey(ignore: true)
  _$QuestionCopyWith<_Question> get copyWith;
}

Tree _$TreeFromJson(Map<String, dynamic> json) {
  return _QTree.fromJson(json);
}

/// @nodoc
class _$TreeTearOff {
  const _$TreeTearOff();

  _QTree call({Question? question, Tree? left, Tree? right}) {
    return _QTree(
      question: question,
      left: left,
      right: right,
    );
  }

  Tree fromJson(Map<String, Object> json) {
    return Tree.fromJson(json);
  }
}

/// @nodoc
const $Tree = _$TreeTearOff();

/// @nodoc
mixin _$Tree {
  Question? get question;
  Tree? get left;
  Tree? get right;

  Map<String, dynamic> toJson();
  @JsonKey(ignore: true)
  $TreeCopyWith<Tree> get copyWith;
}

/// @nodoc
abstract class $TreeCopyWith<$Res> {
  factory $TreeCopyWith(Tree value, $Res Function(Tree) then) =
      _$TreeCopyWithImpl<$Res>;
  $Res call({Question? question, Tree? left, Tree? right});

  $QuestionCopyWith<$Res>? get question;
  $TreeCopyWith<$Res>? get left;
  $TreeCopyWith<$Res>? get right;
}

/// @nodoc
class _$TreeCopyWithImpl<$Res> implements $TreeCopyWith<$Res> {
  _$TreeCopyWithImpl(this._value, this._then);

  final Tree _value;
  // ignore: unused_field
  final $Res Function(Tree) _then;

  @override
  $Res call({
    Object? question = freezed,
    Object? left = freezed,
    Object? right = freezed,
  }) {
    return _then(_value.copyWith(
      question: question == freezed ? _value.question : question as Question?,
      left: left == freezed ? _value.left : left as Tree?,
      right: right == freezed ? _value.right : right as Tree?,
    ));
  }

  @override
  $QuestionCopyWith<$Res>? get question {
    if (_value.question == null) {
      return null;
    }

    return $QuestionCopyWith<$Res>(_value.question!, (value) {
      return _then(_value.copyWith(question: value));
    });
  }

  @override
  $TreeCopyWith<$Res>? get left {
    if (_value.left == null) {
      return null;
    }

    return $TreeCopyWith<$Res>(_value.left!, (value) {
      return _then(_value.copyWith(left: value));
    });
  }

  @override
  $TreeCopyWith<$Res>? get right {
    if (_value.right == null) {
      return null;
    }

    return $TreeCopyWith<$Res>(_value.right!, (value) {
      return _then(_value.copyWith(right: value));
    });
  }
}

/// @nodoc
abstract class _$QTreeCopyWith<$Res> implements $TreeCopyWith<$Res> {
  factory _$QTreeCopyWith(_QTree value, $Res Function(_QTree) then) =
      __$QTreeCopyWithImpl<$Res>;
  @override
  $Res call({Question? question, Tree? left, Tree? right});

  @override
  $QuestionCopyWith<$Res>? get question;
  @override
  $TreeCopyWith<$Res>? get left;
  @override
  $TreeCopyWith<$Res>? get right;
}

/// @nodoc
class __$QTreeCopyWithImpl<$Res> extends _$TreeCopyWithImpl<$Res>
    implements _$QTreeCopyWith<$Res> {
  __$QTreeCopyWithImpl(_QTree _value, $Res Function(_QTree) _then)
      : super(_value, (v) => _then(v as _QTree));

  @override
  _QTree get _value => super._value as _QTree;

  @override
  $Res call({
    Object? question = freezed,
    Object? left = freezed,
    Object? right = freezed,
  }) {
    return _then(_QTree(
      question: question == freezed ? _value.question : question as Question?,
      left: left == freezed ? _value.left : left as Tree?,
      right: right == freezed ? _value.right : right as Tree?,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_QTree implements _QTree {
  const _$_QTree({this.question, this.left, this.right});

  factory _$_QTree.fromJson(Map<String, dynamic> json) =>
      _$_$_QTreeFromJson(json);

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
        (other is _QTree &&
            (identical(other.question, question) ||
                const DeepCollectionEquality()
                    .equals(other.question, question)) &&
            (identical(other.left, left) ||
                const DeepCollectionEquality().equals(other.left, left)) &&
            (identical(other.right, right) ||
                const DeepCollectionEquality().equals(other.right, right)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(question) ^
      const DeepCollectionEquality().hash(left) ^
      const DeepCollectionEquality().hash(right);

  @JsonKey(ignore: true)
  @override
  _$QTreeCopyWith<_QTree> get copyWith =>
      __$QTreeCopyWithImpl<_QTree>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_QTreeToJson(this);
  }
}

abstract class _QTree implements Tree {
  const factory _QTree({Question? question, Tree? left, Tree? right}) =
      _$_QTree;

  factory _QTree.fromJson(Map<String, dynamic> json) = _$_QTree.fromJson;

  @override
  Question? get question;
  @override
  Tree? get left;
  @override
  Tree? get right;
  @override
  @JsonKey(ignore: true)
  _$QTreeCopyWith<_QTree> get copyWith;
}
