import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:bloc/bloc.dart';

class SimpleBloc extends Bloc<dynamic, String> {
  @override
  String get initialState => '';

  @override
  Stream<String> mapEventToState(dynamic event) {
    return Observable.just('data');
  }
}
