import 'package:meta/meta.dart';

class LoginState {
  final bool isLoading;
  final bool isLoginButtonEnabled;
  final String error;
  final String token;

  const LoginState({
    @required this.isLoading,
    @required this.isLoginButtonEnabled,
    @required this.error,
    @required this.token,
  });

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: '',
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isLoading: true,
      isLoginButtonEnabled: false,
      error: '',
      token: '',
    );
  }

  factory LoginState.failure(String error) {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: error,
      token: '',
    );
  }

  factory LoginState.success(String token) {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
      token: token,
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
      other is LoginState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          isLoginButtonEnabled == other.isLoginButtonEnabled &&
          error == other.error &&
          token == other.token;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      isLoginButtonEnabled.hashCode ^
      error.hashCode ^
      token.hashCode;

  @override
  String toString() =>
      'LoginState { isLoading: $isLoading, isLoginButtonEnabled: $isLoginButtonEnabled, error: $error, token: $token }';
}
