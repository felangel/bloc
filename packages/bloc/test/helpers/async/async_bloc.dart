import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'async_event.dart';
part 'async_state.dart';

class AsyncBloc extends Bloc<AsyncEvent, AsyncState> {
  AsyncBloc() : super(AsyncState.initial());

  @override
  Stream<AsyncState> mapEventToState(AsyncEvent event) async* {
    yield state.copyWith(isLoading: true);
    await Future<void>.delayed(Duration(milliseconds: 500));
    yield state.copyWith(isLoading: false, isSuccess: true);
  }
}
