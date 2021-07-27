import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:flutter_firestore_todos/blocs/authentication_bloc/bloc.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({required UserRepository userRepository})
      : _userRepository = userRepository,
        super(Uninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _userRepository.isAuthenticated();
      if (!isSignedIn) await _userRepository.authenticate();
      final userId = _userRepository.getUserId();
      yield userId == null ? Unauthenticated() : Authenticated(userId);
    } catch (_) {
      yield Unauthenticated();
    }
  }
}
