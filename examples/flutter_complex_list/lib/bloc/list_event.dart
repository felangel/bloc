import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ListEvent extends Equatable {
  ListEvent([List props = const []]) : super(props);
}

class Fetch extends ListEvent {
  @override
  String toString() => 'Fetch';
}

class Delete extends ListEvent {
  final String id;

  Delete({@required this.id}) : super([id]);

  @override
  String toString() => 'Delete { id: $id }';
}

class Deleted extends ListEvent {
  final String id;

  Deleted({@required this.id}) : super([id]);

  @override
  String toString() => 'Deleted { id: $id }';
}
