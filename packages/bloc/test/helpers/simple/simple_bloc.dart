import 'dart:async';

import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(dynamic event) {
    return Stream.value('data');
  }
}
