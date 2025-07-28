part of 'timeline_bloc.dart';

class TimelineState extends Equatable {
  const TimelineState({this.tasks = const {}});

  final Map<String, Task> tasks;

  @override
  List<Object> get props => [tasks];
}
