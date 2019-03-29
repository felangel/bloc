import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnErrorBloc extends Bloc<CounterEvent, int> {
  final Function onErrorCallback;
  final Exception exception;

  OnErrorBloc({this.exception, this.onErrorCallback});

  @override
  int get initialState => 0;

  @override
  void onError(Object error, StackTrace stacktrace) {
    onErrorCallback(error, stacktrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw exception;
  }
}
