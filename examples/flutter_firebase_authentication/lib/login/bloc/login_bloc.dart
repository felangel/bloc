import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter_firebase_authentication/login/login.dart';
import 'package:flutter_firebase_authentication/form/form.dart';
import 'package:flutter_firebase_authentication/authentication/authentication.dart';
import 'package:flutter_firebase_authentication/validators/validators.dart';

class LoginBloc extends Bloc<MyFormEvent, MyFormState> {
  UserRepository _userRepository;
  AuthenticationBloc _authenticationBloc;

  LoginBloc({
    @required UserRepository userRepository,
    @required AuthenticationBloc authenticationBloc,
  })  : assert(userRepository != null),
        assert(authenticationBloc != null),
        _userRepository = userRepository,
        _authenticationBloc = authenticationBloc;

  @override
  MyFormState get initialState => MyFormState.empty();

  @override
  Stream<MyFormEvent> transform(Stream<MyFormEvent> events) {
    final observableStream = events as Observable<MyFormEvent>;
    final nonDebounceStream = observableStream.where((event) {
      return (event is! EmailChanged && event is! PasswordChanged);
    });
    final debounceStream = (observableStream).where((event) {
      return (event is EmailChanged || event is PasswordChanged);
    }).debounce(Duration(milliseconds: 300));
    return nonDebounceStream.mergeWith([debounceStream]);
  }

  @override
  Stream<MyFormState> mapEventToState(MyFormEvent event) async* {
    if (event is EmailChanged) {
      yield* _mapEmailChangedToState(event.email);
    } else if (event is PasswordChanged) {
      yield* _mapPasswordChangedToState(event.password);
    } else if (event is LoginWithGooglePressed) {
      yield* _mapLoginWithGooglePressedToState();
    } else if (event is LoginWithCredentialsPressed) {
      yield* _mapLoginWithCredentialsPressedToState(
        email: event.email,
        password: event.password,
      );
    }
  }

  Stream<MyFormState> _mapEmailChangedToState(String email) async* {
    yield currentState.update(
      isEmailValid: Validators.isValidEmail(email),
    );
  }

  Stream<MyFormState> _mapPasswordChangedToState(String password) async* {
    yield currentState.update(
      isPasswordValid: Validators.isValidPassword(password),
    );
  }

  Stream<MyFormState> _mapLoginWithGooglePressedToState() async* {
    try {
      await _userRepository.signInWithGoogle();
      _authenticationBloc.dispatch(LoggedIn());
      yield MyFormState.success();
    } catch (_) {
      yield MyFormState.failure();
    }
  }

  Stream<MyFormState> _mapLoginWithCredentialsPressedToState({
    String email,
    String password,
  }) async* {
    yield MyFormState.loading();
    try {
      await _userRepository.signInWithCredentials(email, password);
      _authenticationBloc.dispatch(LoggedIn());
      yield MyFormState.success();
    } catch (_) {
      yield MyFormState.failure();
    }
  }
}
