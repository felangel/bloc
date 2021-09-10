import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:stream_transform/stream_transform.dart';

abstract class RestartableStreamEvent {}

class ForEach extends RestartableStreamEvent {}

class ForEachOnError extends RestartableStreamEvent {}

class ForEachTryCatch extends RestartableStreamEvent {}

class ForEachCatchError extends RestartableStreamEvent {}

class UnawaitedForEach extends RestartableStreamEvent {}

class OnEach extends RestartableStreamEvent {}

class OnEachOnError extends RestartableStreamEvent {}

class OnEachTryCatch extends RestartableStreamEvent {}

class OnEachTryCatchAbort extends RestartableStreamEvent {}

class OnEachCatchError extends RestartableStreamEvent {}

class UnawaitedOnEach extends RestartableStreamEvent {}

const _delay = Duration(milliseconds: 100);

class RestartableStreamBloc extends Bloc<RestartableStreamEvent, int> {
  RestartableStreamBloc(Stream<int> stream) : super(0) {
    on<ForEach>(
      (_, emit) async {
        await emit.forEach<int>(
          stream,
          onData: (i) => i,
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<ForEachOnError>(
      (_, emit) async {
        try {
          await emit.forEach<int>(
            stream,
            onData: (i) => i,
            onError: (_, __) => -1,
          );
        } catch (_) {
          emit(-1);
        }
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<ForEachTryCatch>(
      (_, emit) async {
        try {
          await emit.forEach<int>(
            stream,
            onData: (i) => i,
          );
        } catch (_) {
          emit(-1);
        }
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<ForEachCatchError>(
      (_, emit) => emit
          .forEach<int>(
            stream,
            onData: (i) => i,
          )
          .catchError((dynamic _) => emit(-1)),
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<UnawaitedForEach>(
      (_, emit) {
        emit.forEach<int>(
          stream,
          onData: (i) => i,
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEach>(
      (_, emit) async {
        await emit.onEach<int>(
          stream,
          onData: (i) => Future<void>.delayed(_delay, () => emit(i)),
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEachOnError>(
      (_, emit) async {
        await emit.onEach<int>(
          stream,
          onData: (i) => Future<void>.delayed(_delay, () => emit(i)),
          onError: (_, __) => emit(-1),
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEachTryCatch>(
      (_, emit) async {
        try {
          await emit.onEach<int>(
            stream,
            onData: (i) => Future<void>.delayed(_delay, () => emit(i)),
          );
        } catch (_) {
          emit(-1);
        }
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEachTryCatchAbort>(
      (_, emit) async {
        try {
          await emit.onEach<int>(
            stream,
            onData: (i) => Future<void>.delayed(_delay, () {
              if (emit.isDone) return;
              emit(i);
            }),
          );
        } catch (_) {
          emit(-1);
        }
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<OnEachCatchError>(
      (_, emit) => emit
          .onEach<int>(
            stream,
            onData: (i) => Future<void>.delayed(_delay, () => emit(i)),
          )
          .catchError((dynamic _) => emit(-1)),
      transformer: (events, mapper) => events.switchMap(mapper),
    );

    on<UnawaitedOnEach>(
      (_, emit) {
        emit.onEach<int>(
          stream,
          onData: (i) => Future<void>.delayed(_delay, () => emit(i)),
        );
      },
      transformer: (events, mapper) => events.switchMap(mapper),
    );
  }
}
