// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('sequentialDroppable', () {
    Future<void> verifyEventsAndStates({
      required CounterBloc bloc,
      required List<Increment> events,
      required List<int> states,
    }) async {
      await tick();

      expect(bloc.onCalls, events);

      await wait();

      expect(bloc.onEmitCalls, events);

      expect(states, equals(states));
    }

    test('create without specified events', () {
      expect(
        () => sequentialDroppable<int>(droppableEvents: []).call(
          const Stream.empty(),
          (_) => const Stream.empty(),
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('processes in sequence', () async {
      final states = <int>[];
      final bloc = CounterBloc(sequentialDroppable(droppableEvents: [_EventA]))
        ..stream.listen(states.add)
        ..add(_EventA())
        ..add(_EventB())
        ..add(_EventC())
        ..add(_EventD());

      await verifyEventsAndStates(
        bloc: bloc,
        events: [_EventA()],
        states: [1],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventA(),
          _EventB(),
        ],
        states: [1, 2],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventA(),
          _EventB(),
          _EventC(),
        ],
        states: [1, 2, 3],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventA(),
          _EventB(),
          _EventC(),
          _EventD(),
        ],
        states: [1, 2, 3, 4],
      );
    });

    test('ignore specified event in sequence', () async {
      final states = <int>[];
      final bloc = CounterBloc(sequentialDroppable(droppableEvents: [_EventA]))
        ..stream.listen(states.add)
        ..add(_EventB())
        ..add(_EventA())
        ..add(_EventA())
        ..add(_EventA())
        ..add(_EventC())
        ..add(_EventC());

      await verifyEventsAndStates(
        bloc: bloc,
        events: [_EventB()],
        states: [1],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
        ],
        states: [1, 2],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
        ],
        states: [1, 2, 3],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
          _EventC(),
        ],
        states: [1, 2, 3, 4],
      );
    });

    test('ignore specified multiple events in sequence', () async {
      final states = <int>[];
      final bloc =
          CounterBloc(sequentialDroppable(droppableEvents: [_EventA, _EventD]))
            ..stream.listen(states.add)
            ..add(_EventB())
            ..add(_EventA())
            ..add(_EventA())
            ..add(_EventA())
            ..add(_EventC())
            ..add(_EventC())
            ..add(_EventD())
            ..add(_EventD())
            ..add(_EventD())
            ..add(_EventB());

      await verifyEventsAndStates(
        bloc: bloc,
        events: [_EventB()],
        states: [1],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
        ],
        states: [1, 2],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
        ],
        states: [1, 2, 3],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
          _EventC(),
        ],
        states: [1, 2, 3, 4],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
          _EventC(),
          _EventD(),
        ],
        states: [1, 2, 3, 4, 5],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventC(),
          _EventC(),
          _EventD(),
          _EventB(),
        ],
        states: [1, 2, 3, 4, 5, 6],
      );
    });

    test('process multiple droppable events in a row with correct sequence',
        () async {
      final states = <int>[];
      final bloc = CounterBloc(
        sequentialDroppable(droppableEvents: [_EventA, _EventD, _EventC]),
      )
        ..stream.listen(states.add)
        ..add(_EventB())
        ..add(_EventA())
        ..add(_EventA())
        ..add(_EventA())
        ..add(_EventD())
        ..add(_EventD())
        ..add(_EventD())
        ..add(_EventC())
        ..add(_EventC())
        ..add(_EventC())
        ..add(_EventB())
        ..add(_EventA());

      await verifyEventsAndStates(
        bloc: bloc,
        events: [_EventB()],
        states: [1],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
        ],
        states: [1, 2],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventD(),
        ],
        states: [1, 2, 3],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventD(),
          _EventC(),
        ],
        states: [1, 2, 3, 4],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventD(),
          _EventC(),
          _EventB(),
        ],
        states: [1, 2, 3, 4, 5],
      );

      await verifyEventsAndStates(
        bloc: bloc,
        events: [
          _EventB(),
          _EventA(),
          _EventD(),
          _EventC(),
          _EventB(),
          _EventA(),
        ],
        states: [1, 2, 3, 4, 5, 6],
      );
    });
  });
}

class _EventA implements Increment {
  @override
  String toString() => 'EventA';

  @override
  bool operator ==(Object value) => identical(this, value) || value is _EventA;

  @override
  int get hashCode => 0;
}

class _EventB implements Increment {
  @override
  String toString() => 'EventB';

  @override
  bool operator ==(Object value) => identical(this, value) || value is _EventB;

  @override
  int get hashCode => 1;
}

class _EventC implements Increment {
  @override
  String toString() => 'EventC';

  @override
  bool operator ==(Object value) => identical(this, value) || value is _EventC;

  @override
  int get hashCode => 3;
}

class _EventD implements Increment {
  @override
  String toString() => 'EventD';

  @override
  bool operator ==(Object value) => identical(this, value) || value is _EventD;

  @override
  int get hashCode => 4;
}
