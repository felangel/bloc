import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:user_repository/user_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends HydratedBloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileEmpty());

  @override
  ProfileState fromJson(Map<String, dynamic> json) {
    try {
      return ProfileUser(User(json['id'] as String));
    } catch (e) {
      throw Exception(e);
    }
  }

  @override
  Stream<ProfileState> mapEventToState(ProfileEvent event) async* {
    try {
      switch (event.runtimeType) {
        case ProfileStore:
          final itemEvent = event as ProfileStore;
          yield ProfileUser(itemEvent.user);
          break;
        default:
          throw ArgumentError();
      }
    } catch (e) {
      yield ProfileError();
    }
  }

  @override
  Map<String, dynamic> toJson(ProfileState state) {
    try {
      if (state is ProfileUser) {
        return {'id': state.user.id};
      }
      return null;
    } catch (e) {
      throw Exception(e);
    }
  }
}
