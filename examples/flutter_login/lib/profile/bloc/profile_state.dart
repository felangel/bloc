part of 'profile_bloc.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object> get props => [];
}

class ProfileEmpty extends ProfileState {}

class ProfileError extends ProfileState {}

class ProfileUser extends ProfileState {
  ProfileUser(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}
