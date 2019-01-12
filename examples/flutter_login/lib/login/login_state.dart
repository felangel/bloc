import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isLoginButtonEnabled;
  final String error;

  LoginState({
    @required this.isLoading,
    @required this.isLoginButtonEnabled,
    @required this.error,
  }) : super([isLoading, isLoginButtonEnabled, error]);

  factory LoginState.initial() {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: '',
    );
  }

  factory LoginState.loading() {
    return LoginState(
      isLoading: true,
      isLoginButtonEnabled: false,
      error: '',
    );
  }

  factory LoginState.failure(String error) {
    return LoginState(
      isLoading: false,
      isLoginButtonEnabled: true,
      error: error,
    );
  }

  @override
  String toString() =>
      'LoginState { isLoading: $isLoading, isLoginButtonEnabled: $isLoginButtonEnabled, error: $error }';
}
