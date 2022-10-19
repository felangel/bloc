import 'package:equatable/equatable.dart';
import '../type/authentication_status_type.dart';

/// authentication event.
abstract class AuthenticationEvent extends Equatable {
  /// create authentication event
  const AuthenticationEvent();

  @override
  List<Object> get props => <Object>[];
}

/// change authentication status
class AuthenticationStatusChanged extends AuthenticationEvent {
  /// create event for change authentication
  const AuthenticationStatusChanged(this.status, {this.name});

  /// authentication status
  final AuthenticationStatusType status;

  /// user name
  final String? name;

  @override
  List<Object> get props => <Object>[status, name!];
}
