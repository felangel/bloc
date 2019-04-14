import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:flutter_firebase_authentication/authentication/authentication.dart';
import 'package:flutter_firebase_authentication/form/form.dart';

class RegisterBloc extends Bloc<FormEvent, FormState> {
  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$',
  );
  final RegExp _passwordRegExp = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$',
  );
  final UserRepository _userRepository;
  AuthenticationBloc _authenticationBloc;

  RegisterBloc({
    @required UserRepository userRepository,
    @required AuthenticationBloc authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),
        _userRepository = userRepository,
        _authenticationBloc = authenticationBloc;

  @override
  FormState get initialState => Initial();

  @override
  Stream<FormState> mapEventToState(
    FormEvent event,
  ) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is Submitted) {
      yield* _mapFormSubmittedToState(event.email, event.password);
    }
  }

  Stream<FormState> _mapEmailChangedToState(String email) async* {
    if (currentState is! Editing) {
      yield Editing.empty().copyWith(
        isEmailValid: _isEmailValid(email),
      );
    } else {
      yield (currentState as Editing).update(
        isEmailValid: _isEmailValid(email),
      );
    }
  }

  Stream<FormState> _mapPasswordChangedToState(String password) async* {
    if (currentState is! Editing) {
      yield Editing.empty().copyWith(
        isPasswordValid: _isPasswordValid(password),
      );
    } else {
      yield (currentState as Editing).update(
        isPasswordValid: _isPasswordValid(password),
      );
    }
  }

  Stream<FormState> _mapFormSubmittedToState(
    String email,
    String password,
  ) async* {
    yield Editing.loading();
    try {
      await _userRepository.signUp(
        email: email,
        password: password,
      );
      _authenticationBloc.dispatch(LoggedIn());
      yield Editing.success();
    } catch (_) {
      yield Editing.failure();
    }
  }

  bool _isEmailValid(String email) {
    return _emailRegExp.hasMatch(email);
  }

  bool _isPasswordValid(String password) {
    return _passwordRegExp.hasMatch(password);
  }
}
