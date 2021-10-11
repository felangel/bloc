import 'package:meta/meta.dart';
import 'package:uuid/uuid.dart';
import '../entities/entities.dart';

@immutable
class Todo {
  final String id;
  final bool complete;
  final String note;
  final String task;

  Todo({
    required this.task,
    this.complete = false,
    String? id,
    String? note = '',
  })  : this.note = note ?? '',
        this.id = id ?? Uuid().v4();

  Todo copyWith({bool? complete, String? note, String? task}) {
    return Todo(
      id: id,
      task: task ?? this.task,
      complete: complete ?? this.complete,
      note: note ?? this.note,
    );
  }

  @override
  int get hashCode {
    return complete.hashCode ^ task.hashCode ^ note.hashCode ^ id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is Todo &&
            runtimeType == other.runtimeType &&
            complete == other.complete &&
            task == other.task &&
            note == other.note &&
            id == other.id;
  }

  @override
  String toString() {
    return 'Todo{complete: $complete, task: $task, note: $note, id: $id}';
  }

  TodoEntity toEntity() {
    return TodoEntity(
      id: id,
      task: task,
      complete: complete,
      note: note,
    );
  }

  static Todo fromEntity(TodoEntity entity) {
    return Todo(
      id: entity.id,
      task: entity.task,
      complete: entity.complete,
      note: entity.note,
    );
  }
}
