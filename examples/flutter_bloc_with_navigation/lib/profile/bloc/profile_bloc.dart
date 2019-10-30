import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  @override
  ProfileState get initialState => ProfileState.initial();

  @override
  Stream<ProfileState> mapEventToState(
    ProfileEvent event,
  ) async* {
    if (event is Increment) {
      yield state.copyWith(count: state.count + 1);
    }
  }
}
