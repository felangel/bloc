import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();
}

class PageChanged extends AppEvent {
  const PageChanged({@required this.newIndex}) : assert(newIndex != null);

  final int newIndex;

  @override
  List<Object> get props => <Object>[newIndex];

  @override
  String toString() {
    return '$runtimeType $newIndex';
  }
}
