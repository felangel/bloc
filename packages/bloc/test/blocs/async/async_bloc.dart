import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'async_event.dart';
part 'async_state.dart';

class AsyncBloc extends Bloc<AsyncEvent, AsyncState> {
  AsyncBloc() : super(AsyncState.initial()) {
    on<AsyncEvent>(
      (event, emit) async {
        emit(state.copyWith(isLoading: true, isSuccess: false));
        await Future<void>.delayed(Duration.zero);
        emit(state.copyWith(isLoading: false, isSuccess: true));
      },
      transformer: (events, mapper) => events.asyncExpand(mapper),
    );
  }
}
