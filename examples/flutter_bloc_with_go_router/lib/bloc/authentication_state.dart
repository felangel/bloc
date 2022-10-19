import 'package:equatable/equatable.dart';
import '../type/authentication_status_type.dart';

/// auth state.
abstract class AuthenticationState extends Equatable {
  /// create auth state
  const AuthenticationState({
    required this.status,
    this.name,
  });

  /// authentication status
  final AuthenticationStatusType? status;

  /// user name
  final String? name;
  @override
  List<Object> get props =>
      <Object>[status ?? AuthenticationStatusType.unknown, 'unknown'];
}

/// auth initial state.
class AuthenticationInitial extends AuthenticationState {
  /// create auth initial state.
  const AuthenticationInitial()
      : super(status: AuthenticationStatusType.unknown);
  @override
  List<Object> get props => <Object>[];
}

/// auth authenticated state.
class AuthenticationAuthenticated extends AuthenticationState {
  /// create auth authenticated state.
  const AuthenticationAuthenticated({required String? name})
      : super(status: AuthenticationStatusType.authenticated, name: name);
  @override
  List<Object> get props => <Object>[name!];
}

/// auth unauthenticated state.
class AuthenticationUnAuthenticated extends AuthenticationState {
  /// create auth unauthenticated state.
  const AuthenticationUnAuthenticated()
      : super(status: AuthenticationStatusType.unauthenticated);
  @override
  List<Object> get props => <Object>[];
}

/// auth unknown state.
class AuthenticationUnknown extends AuthenticationState {
  /// create auth unknown state.
  const AuthenticationUnknown()
      : super(status: AuthenticationStatusType.unknown);
  @override
  List<Object> get props => <Object>[];
}

/// error state
class AuthenticationError extends AuthenticationState {
  /// create error state
  const AuthenticationError({
    this.errorMessage = '',
  }) : super(status: AuthenticationStatusType.unknown);

  /// error message
  final String errorMessage;

  @override
  List<Object> get props => <Object>[];
}
