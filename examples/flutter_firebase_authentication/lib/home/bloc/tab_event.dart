import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_authentication/home/home.dart';

@immutable
abstract class TabEvent extends Equatable {
  TabEvent([List props = const []]) : super(props);
}

class UpdateTab extends TabEvent {
  final HomeTab activeTab;

  UpdateTab({@required this.activeTab});
}
