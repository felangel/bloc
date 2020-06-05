import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

@immutable
class Item extends Equatable {
  final int id;
  final String name;
  final Color color;
  final int price = 42;

  Item(this.id, this.name)
      : color = Colors.primaries[id % Colors.primaries.length];

  @override
  List get props => [id, name, color, price];
}
