import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnExceptionBloc extends Bloc<CounterEvent, int> {
  final Function onErrorCallback;
  final Exception exception;

  OnExceptionBloc({this.exception, this.onErrorCallback}) : super(0);

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw exception;
  }
}
