// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes, lines_longer_than_80_chars, prefer_file_naming_conventions, avoid_public_fields
import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

abstract class CounterEvent {}

class Increment extends CounterEvent {
  @override
  bool operator ==(Object value) {
    if (identical(this, value)) return true;
    return value is Increment;
  }

  @override
  int get hashCode => 0;
}

const delay = Duration(milliseconds: 30);

Future<void> wait() => Future.delayed(delay);
Future<void> tick() => Future.delayed(Duration.zero);

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc(EventTransformer<Increment> transformer) : super(0) {
    on<Increment>(
      (event, emit) {
        onCalls.add(event);
        return Future<void>.delayed(delay, () {
          if (emit.isDone) return;
          onEmitCalls.add(event);
          emit(state + 1);
        });
      },
      transformer: transformer,
    );
  }

  final onCalls = <CounterEvent>[];
  final onEmitCalls = <CounterEvent>[];
}

class GatedBloc extends Bloc<int, int> {
  GatedBloc(EventTransformer<int> transformer, this.gates) : super(0) {
    on<int>(
      (event, emit) async {
        log.add('start $event');
        await gates[event]!.future;
        log.add('end $event, isDone: ${emit.isDone}');
        if (!emit.isDone) emit(event);
      },
      transformer: transformer,
    );
  }

  final Map<int, Completer<void>> gates;
  final log = <String>[];
}

abstract class TwoHandlerEvent {}

class SlowEvent extends TwoHandlerEvent {}

class FastEvent extends TwoHandlerEvent {}

class TwoHandlerBloc extends Bloc<TwoHandlerEvent, int> {
  TwoHandlerBloc(this.release) : super(0) {
    on<SlowEvent>(
      (event, emit) async {
        log.add('slow start');
        await release;
        log.add('slow end');
      },
      transformer: sequential(),
    );
    on<FastEvent>((event, emit) => log.add('fast'), transformer: sequential());
  }

  final Future<void> release;
  final log = <String>[];
}
