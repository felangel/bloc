import 'package:collection/collection.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:json_annotation/json_annotation.dart';

part 'json_serializable_cubit.g.dart';

class JsonSerializableCubit extends HydratedCubit<User> {
  JsonSerializableCubit() : super(const User.initial());

  void updateFavoriteColor(Color color) =>
      emit(state.copyWith(favoriteColor: color));

  @override
  User fromJson(Map<String, dynamic> json) => User.fromJson(json);

  @override
  Map<String, dynamic> toJson(User state) => state.toJson();
}

@JsonSerializable(explicitToJson: true)
class User {
  const User(this.name, this.age, this.favoriteColor, this.todos);

  const User.initial()
      : this(
          'John Doe',
          42,
          Color.green,
          const <Todo>[Todo('0', 'wash car'), Todo('1', 'dishes')],
        );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  final String name;
  final int age;
  final Color favoriteColor;
  final List<Todo> todos;

  User copyWith({
    String? name,
    int? age,
    Color? favoriteColor,
    List<Todo>? todos,
  }) {
    return User(
      name ?? this.name,
      age ?? this.age,
      favoriteColor ?? this.favoriteColor,
      todos ?? this.todos,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return o is User &&
        o.name == name &&
        o.age == age &&
        o.favoriteColor == favoriteColor &&
        listEquals(o.todos, todos);
  }

  @override
  int get hashCode {
    return name.hashCode ^
        age.hashCode ^
        favoriteColor.hashCode ^
        todos.hashCode;
  }

  @override
  String toString() {
    return '''User(name: $name, age: $age, favoriteColor: $favoriteColor, todos: $todos)''';
  }
}

enum Color { red, green, blue }

@JsonSerializable(explicitToJson: true)
class Todo {
  const Todo(this.id, this.task);
  factory Todo.fromJson(Map<String, dynamic> json) => _$TodoFromJson(json);
  Map<String, dynamic> toJson() => _$TodoToJson(this);

  final String id;
  final String task;

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is Todo && o.id == id && o.task == task;
  }

  @override
  int get hashCode => id.hashCode ^ task.hashCode;
}
