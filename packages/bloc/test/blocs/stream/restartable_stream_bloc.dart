import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class RestartableStreamEvent {}

class ForEach extends RestartableStreamEvent {}

class OnEach extends RestartableStreamEvent {}

const _delay = Duration(milliseconds: 100);

class RestartableStreamBloc extends Bloc<RestartableStreamEvent, int> {
  RestartableStreamBloc(Stream<int> stream) : super(0) {
    on<ForEach>(
      (_, emit) async {
        await emit.forEach<int>(
          stream,
          (i) => Future<int>.delayed(_delay, () => i),
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEach>(
      (_, emit) async {
        await emit.onEach<int>(
          stream,
          (i) => Future<void>.delayed(_delay, () => emit(i)),
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );
  }
}
