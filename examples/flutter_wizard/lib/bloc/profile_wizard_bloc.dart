import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'profile_wizard_event.dart';
part 'profile_wizard_state.dart';

class ProfileWizardBloc extends Bloc<ProfileWizardEvent, ProfileWizardState> {
  ProfileWizardBloc() : super(ProfileWizardState.initial());

  @override
  Stream<ProfileWizardState> mapEventToState(
    ProfileWizardEvent event,
  ) async* {
    if (event is ProfileWizardNameSubmitted) {
      yield state.copyWith(
        profile: state.profile.copyWith(name: event.name),
      );
    } else if (event is ProfileWizardAgeSubmitted) {
      yield state.copyWith(
        profile: state.profile.copyWith(age: event.age),
      );
    }
  }
}
