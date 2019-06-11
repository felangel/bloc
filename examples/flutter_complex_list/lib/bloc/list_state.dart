import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:flutter_complex_list/models/models.dart';

@immutable
abstract class ListState extends Equatable {
  ListState([List props = const []]) : super(props);
}

class Loading extends ListState {
  @override
  String toString() => 'Loading';
}

class Loaded extends ListState {
  final List<Item> items;

  Loaded({@required this.items}) : super([items]);

  @override
  String toString() => 'Loaded { items: ${items.length} }';
}

class Failure extends ListState {
  @override
  String toString() => 'Failure';
}
