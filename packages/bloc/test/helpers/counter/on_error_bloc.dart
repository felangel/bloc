import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnErrorBloc extends Bloc<CounterEvent, int> {
  final Function onErrorCallback;
  final Error error;

  OnErrorBloc({this.error, this.onErrorCallback});

  @override
  int get initialState => 0;

  @override
  void onError(Object error, StackTrace stacktrace) {
    super.onError(error, stacktrace);
    onErrorCallback(error, stacktrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw error;
  }
}
