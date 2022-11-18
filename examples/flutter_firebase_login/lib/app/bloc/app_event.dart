part of 'app_bloc.dart';

abstract class AppEvent {
  const AppEvent();
}

class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

class _AppUserChanged extends AppEvent {
  const _AppUserChanged(this.user);

  final User user;
}
