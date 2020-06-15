import 'dart:async';

import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  SimpleBloc() : super(initialState: '');

  @override
  Stream<String> mapEventToState(dynamic event) async* {
    yield 'data';
  }
}
