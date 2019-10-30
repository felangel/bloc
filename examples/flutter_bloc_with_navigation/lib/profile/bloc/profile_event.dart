import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object> get props => const <Object>[];
}

class Increment extends ProfileEvent {
  const Increment();
}
