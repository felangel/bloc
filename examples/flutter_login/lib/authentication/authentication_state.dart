import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class AuthenticationState extends Equatable {
  AuthenticationState([Iterable props]) : super(props);
}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  String toString() => 'AuthenticationUninitialized';
}

class AuthenticationInitialized extends AuthenticationState {
  final bool isLoading;
  final bool isAuthenticated;

  AuthenticationInitialized({
    @required this.isLoading,
    @required this.isAuthenticated,
  }) : super([isLoading, isAuthenticated]);

  factory AuthenticationInitialized.authenticated() {
    return AuthenticationInitialized(
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthenticationInitialized.unauthenticated() {
    return AuthenticationInitialized(
      isAuthenticated: false,
      isLoading: false,
    );
  }

  @override
  String toString() =>
      'AuthenticationInitialized { isLoading: $isLoading, isAuthenticated: $isAuthenticated }';
}
