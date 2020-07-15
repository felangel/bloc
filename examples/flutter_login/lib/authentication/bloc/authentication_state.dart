part of 'authentication_bloc.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState([this.user]);

  final User user;

  @override
  List<Object> get props => [user];
}

class AuthenticationInProgress extends AuthenticationState {
  const AuthenticationInProgress() : super();
}

class AuthenticationAuthenticated extends AuthenticationState {
  const AuthenticationAuthenticated(User user) : super(user);
}

class AuthenticationUnauthenticated extends AuthenticationState {
  const AuthenticationUnauthenticated() : super();
}
