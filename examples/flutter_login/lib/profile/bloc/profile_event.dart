part of 'profile_bloc.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
}

class ProfileStore extends ProfileEvent {
  const ProfileStore(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}
