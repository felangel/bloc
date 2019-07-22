import 'package:meta/meta.dart';
<<<<<<< HEAD:examples/flutter_firestore_todos/todos_repository/lib/src/models/todo.dart
import '../entities/entities.dart';
=======
import 'package:todos_repository/todos_repository.dart';
>>>>>>> 412891a503583b5b9acc39e16dd5964a156ff7c3:examples/flutter_firestore_todos/lib/models/todo.dart

@immutable
class Todo {
  final bool complete;
  final String id;
  final String note;
  final String task;

  Todo(this.task, {this.complete = false, String note = '', String id})
      : this.note = note ?? '',
<<<<<<< HEAD:examples/flutter_firestore_todos/todos_repository/lib/src/models/todo.dart
        this.id = id;
=======
        this.id = id ?? Uuid().generateV4();
>>>>>>> 412891a503583b5b9acc39e16dd5964a156ff7c3:examples/flutter_firestore_todos/lib/models/todo.dart

  Todo copyWith({bool complete, String id, String note, String task}) {
    return Todo(
      task ?? this.task,
      complete: complete ?? this.complete,
      id: id ?? this.id,
      note: note ?? this.note,
    );
  }

  @override
  int get hashCode =>
      complete.hashCode ^ task.hashCode ^ note.hashCode ^ id.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Todo &&
          runtimeType == other.runtimeType &&
          complete == other.complete &&
          task == other.task &&
          note == other.note &&
          id == other.id;

  @override
  String toString() {
    return 'Todo{complete: $complete, task: $task, note: $note, id: $id}';
  }

  TodoEntity toEntity() {
    return TodoEntity(task, id, note, complete);
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(
      entity.task,
      complete: entity.complete ?? false,
      note: entity.note,
      id: entity.id,
    );
  }
}
