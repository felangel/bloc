import 'dart:async';

import 'package:bloc/bloc.dart';

import './async.dart';

class AsyncBloc extends Bloc<AsyncEvent, AsyncState> {
  @override
  AsyncState get initialState => AsyncState.initial();

  @override
  Stream<AsyncState> mapEventToState(AsyncEvent event) async* {
    yield currentState.copyWith(isLoading: true);
    await Future<void>.delayed(Duration(milliseconds: 500));
    yield currentState.copyWith(isLoading: false, isSuccess: true);
  }
}
