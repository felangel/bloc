import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class HomeState extends Equatable {
  const HomeState._({@required this.count}) : assert(count != null);

  factory HomeState.initial() => HomeState._(count: 0);

  final int count;
  // Other home props you might need...

  @override
  List<Object> get props => <Object>[count];

  // ? Convenience method if we would have multiple props.
  HomeState copyWith({int count}) => HomeState._(
        count: count ?? this.count,
      );

  @override
  String toString() {
    return '$runtimeType $count';
  }
}
