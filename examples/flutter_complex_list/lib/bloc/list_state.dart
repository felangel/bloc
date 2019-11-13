import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'package:flutter_complex_list/models/models.dart';

abstract class ListState extends Equatable {
  const ListState();

  @override
  List<Object> get props => [];
}

class Loading extends ListState {}

class Loaded extends ListState {
  final List<Item> items;

  const Loaded({@required this.items});

  @override
  List<Object> get props => [items];

  @override
  String toString() => 'Loaded { items: ${items.length} }';
}

class Failure extends ListState {}
