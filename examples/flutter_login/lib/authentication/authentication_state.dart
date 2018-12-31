import 'package:meta/meta.dart';

abstract class AuthenticationState {}

class AuthenticationUninitialized extends AuthenticationState {
  @override
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AuthenticationUninitialized && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'AuthenticationUninitialized';
}

class AuthenticationInitialized extends AuthenticationState {
  final bool isLoading;
  final bool isAuthenticated;

  AuthenticationInitialized({
    @required this.isLoading,
    @required this.isAuthenticated,
  });

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
  bool operator ==(
    Object other,
  ) =>
      identical(
        this,
        other,
      ) ||
      other is AuthenticationInitialized &&
          runtimeType == other.runtimeType &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading;

  @override
  int get hashCode => isAuthenticated.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'AuthenticationInitialized { isLoading: $isLoading, isAuthenticated: $isAuthenticated }';
}
