part of 'profile_wizard_bloc.dart';

abstract class ProfileWizardEvent extends Equatable {
  const ProfileWizardEvent();

  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}

class ProfileWizardNameSubmitted extends ProfileWizardEvent {
  const ProfileWizardNameSubmitted(this.name);

  final String name;

  @override
  List<Object> get props => [name];
}

class ProfileWizardAgeSubmitted extends ProfileWizardEvent {
  const ProfileWizardAgeSubmitted(this.age);

  final int age;

  @override
  List<Object> get props => [age];
}
