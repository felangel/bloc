import 'package:meta/meta.dart';

class AuthenticationState {
  final bool isLoading;
  final bool isInitializing;
  final bool isAuthenticated;

  const AuthenticationState({
    @required this.isInitializing,
    @required this.isLoading,
    @required this.isAuthenticated,
  });

  factory AuthenticationState.initializing() {
    return AuthenticationState(
        isInitializing: true, isAuthenticated: false, isLoading: false);
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
}
