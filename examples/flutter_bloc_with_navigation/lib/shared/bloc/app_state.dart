import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class AppState extends Equatable {
  const AppState._({
    @required this.activePageIndex,
  }) : assert(activePageIndex != null);

  factory AppState.initial() => AppState._(activePageIndex: 0);

  final int activePageIndex;
  // Other app global props you might need...

  @override
  List<Object> get props => <Object>[activePageIndex];

  // ? Convenience method if we would have multiple props.
  AppState copyWith({int activePageIndex}) => AppState._(
        activePageIndex: activePageIndex ?? this.activePageIndex,
      );

  @override
  String toString() {
    return '$runtimeType $activePageIndex';
  }
}
