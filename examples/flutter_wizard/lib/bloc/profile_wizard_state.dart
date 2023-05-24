part of 'profile_wizard_bloc.dart';

final class Profile extends Equatable {
  const Profile({required this.name, required this.age});

  final String? name;
  final int? age;

  Profile copyWith({String? name, int? age}) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }

  @override
  List<Object?> get props => [name, age];
}

final class ProfileWizardState extends Equatable {
  ProfileWizardState({required this.profile}) : lastUpdated = DateTime.now();

  ProfileWizardState.initial()
      : this(profile: const Profile(name: null, age: null));

  final Profile profile;
  final DateTime lastUpdated;

  ProfileWizardState copyWith({Profile? profile}) {
    return ProfileWizardState(
      profile: profile ?? this.profile,
    );
  }

  @override
  List<Object> get props => [profile, lastUpdated];
}
