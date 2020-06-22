import 'dart:async';

import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnErrorBloc extends Bloc<CounterEvent, int> {
  final Function onErrorCallback;
  final Error error;

  OnErrorBloc({this.error, this.onErrorCallback}) : super(0);

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    throw error;
  }
}
