import 'dart:async';

import 'package:bloc/bloc.dart';

import './async.dart';

class AsyncBloc extends Bloc<AsyncEvent, AsyncState> {
  @override
  AsyncState get initialState => AsyncState.initial();

  @override
  Stream<AsyncState> mapEventToState(AsyncEvent event) async* {
    yield state.copyWith(isLoading: true);
    await Future<void>.delayed(Duration(milliseconds: 500));
    yield state.copyWith(isLoading: false, isSuccess: true);
  }
}
