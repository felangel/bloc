import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

enum TaskStatus { queued, running, finished, canceled }

class Task extends Equatable {
  Task.queued({required double start, required Duration duration})
    : this._(start: start, duration: duration);

  Task.canceled({
    required double start,
    required double end,
    required Duration duration,
  }) : this._(
         start: start,
         end: end,
         duration: duration,
         status: TaskStatus.canceled,
       );

  Task._({
    required this.start,
    required this.duration,
    this.status = TaskStatus.queued,
    this.end,
    String? id,
  }) : id = id ?? const Uuid().v4();

  final double start;
  final Duration duration;
  final TaskStatus status;
  final double? end;
  final String id;

  bool get isRunning => status == TaskStatus.running;
  bool get isCanceled => status == TaskStatus.canceled;

  Task run() => _copyWith(status: TaskStatus.running);

  Task finish({required double end}) {
    return _copyWith(status: TaskStatus.finished, end: end);
  }

  Task cancel({required double end}) {
    return _copyWith(status: TaskStatus.canceled, end: end);
  }

  Task _copyWith({TaskStatus? status, double? end}) {
    return Task._(
      id: id,
      duration: duration,
      start: start,
      end: end ?? this.end,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [start, end, status];
}
