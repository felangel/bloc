import 'dart:async';
import 'package:meta/meta.dart';
import 'package:user_repository/user_repository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({@required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(const AuthenticationInProgress()) {
    _userStreamSubscription = _userRepository.userStream().listen((user) {
      add(UserChanged(user));
    });
  }

  final UserRepository _userRepository;
  StreamSubscription<User> _userStreamSubscription;

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is UserChanged) {
      yield _mapUserChangedToState(event);
    } else if (event is LoggedOut) {
      _userRepository.logOut();
    }
  }

  @override
  Future<void> close() {
    _userStreamSubscription?.cancel();
    return super.close();
  }

  AuthenticationState _mapUserChangedToState(UserChanged event) {
    return event.user != null
        ? AuthenticationAuthenticated(event.user)
        : const AuthenticationUnauthenticated();
  }
}
