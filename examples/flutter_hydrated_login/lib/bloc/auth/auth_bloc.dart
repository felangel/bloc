import 'package:flutter_hydrated_login/models/user.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'bloc.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthEmpty());

  @override
  Stream<AuthState> mapEventToState(AuthEvent event) async* {
    if (event is AuthLogin) {
      final data = {
        'uuid': event.uuid,
        'email': event.email,
        'password': event.password
      };
      yield AuthUser(User.fromJson(data));
    }
  }

  @override
  AuthState fromJson(Map<String, dynamic> json) {
    print('fromjson');
    try {
      return AuthUser(User.fromJson(json));
    } catch (e) {
      return null;
    }
  }

  @override
  Map<String, dynamic> toJson(AuthState state) {
    print('testing');
    if (state is AuthUser) {
      return User.toMap(state.user);
    }
    return null;
  }
}
