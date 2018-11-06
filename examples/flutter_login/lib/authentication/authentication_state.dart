import 'package:meta/meta.dart';

class AuthenticationState {
  final bool isInitializing;
  final bool isLoading;
  final bool isAuthenticated;

  const AuthenticationState({
    @required this.isInitializing,
    @required this.isLoading,
    @required this.isAuthenticated,
  });

  factory AuthenticationState.initializing() {
    return AuthenticationState(
      isInitializing: true,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  factory AuthenticationState.authenticated() {
    return AuthenticationState(
      isInitializing: false,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  factory AuthenticationState.unauthenticated() {
    return AuthenticationState(
      isInitializing: false,
      isAuthenticated: false,
      isLoading: false,
    );
  }

  AuthenticationState copyWith({
    bool isInitializing,
    bool isAuthenticated,
    bool isLoading,
  }) {
    return AuthenticationState(
      isInitializing: isInitializing ?? this.isInitializing,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
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
      other is AuthenticationState &&
          runtimeType == other.runtimeType &&
          isInitializing == other.isInitializing &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading;

  @override
  int get hashCode =>
      isInitializing.hashCode ^ isAuthenticated.hashCode ^ isLoading.hashCode;

  @override
  String toString() =>
      'AuthenticationState { isInitializing: $isInitializing, isLoading: $isLoading, isAuthenticated: $isAuthenticated }';
}
