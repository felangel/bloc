import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'profile_wizard_event.dart';
part 'profile_wizard_state.dart';

class ProfileWizardBloc extends Bloc<ProfileWizardEvent, ProfileWizardState> {
  ProfileWizardBloc() : super(ProfileWizardState.initial()) {
    on<ProfileWizardNameSubmitted>((event, emit) {
      emit(state.copyWith(profile: state.profile.copyWith(name: event.name)));
    });

    on<ProfileWizardAgeSubmitted>((event, emit) {
      emit(state.copyWith(profile: state.profile.copyWith(age: event.age)));
    });
  }
}
