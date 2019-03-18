import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_todos/models/models.dart';

@immutable
abstract class TabEvent extends Equatable {
  TabEvent([List props = const []]) : super(props);
}

class UpdateTab extends TabEvent {
  final AppTab tab;

  UpdateTab(this.tab) : super([tab]);

  @override
  String toString() => 'UpdateTab { tab: $tab }';
}
