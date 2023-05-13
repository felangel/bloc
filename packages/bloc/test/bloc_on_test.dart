import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:test/test.dart';

abstract class TestEvent {}

class TestEventA extends TestEvent {}

class TestEventAA extends TestEventA {}

class TestEventB extends TestEvent {}

class TestEventBA extends TestEventB {}

class TestState {}

typedef OnEvent<E, S> = void Function(E event, Emitter<S> emit);

void defaultOnEvent<E, S>(E event, Emitter<S> emit) {}

class TestBloc extends Bloc<TestEvent, TestState> {
  TestBloc({
    this.onTestEvent,
    this.onTestEventA,
    this.onTestEventB,
    this.onTestEventAA,
    this.onTestEventBA,
  }) : super(TestState()) {
    on<TestEventA>(onTestEventA ?? defaultOnEvent);
    on<TestEventB>(onTestEventB ?? defaultOnEvent);
    on<TestEventAA>(onTestEventAA ?? defaultOnEvent);
    on<TestEventBA>(onTestEventBA ?? defaultOnEvent);
    on<TestEvent>(onTestEvent ?? defaultOnEvent);
  }

  final OnEvent<TestEvent, TestState>? onTestEvent;
  final OnEvent<TestEventA, TestState>? onTestEventA;
  final OnEvent<TestEventAA, TestState>? onTestEventAA;
  final OnEvent<TestEventB, TestState>? onTestEventB;
  final OnEvent<TestEventBA, TestState>? onTestEventBA;
}

class DuplicateHandlerBloc extends Bloc<TestEvent, TestState> {
  DuplicateHandlerBloc() : super(TestState()) {
    on<TestEvent>(defaultOnEvent);
    on<TestEvent>(defaultOnEvent);
  }
}

class MissingHandlerBloc extends Bloc<TestEvent, TestState> {
  MissingHandlerBloc() : super(TestState());
}

void main() {
  group('on<Event>', () {
    test('throws StateError when handler is registered more than once', () {
      const expectedMessage = 'on<TestEvent> was called multiple times. '
          'There should only be a single event handler per event type.';
      final expected = throwsA(
        isA<StateError>().having((e) => e.message, 'message', expectedMessage),
      );
      expect(() => DuplicateHandlerBloc(), expected);
    });

    test('throws StateError when handler is missing', () {
      const expectedMessage =
          '''add(TestEventA) was called without a registered event handler.\n'''
          '''Make sure to register a handler via on<TestEventA>((event, emit) {...})''';
      final expected = throwsA(
        isA<StateError>().having((e) => e.message, 'message', expectedMessage),
      );
      expect(() => MissingHandlerBloc().add(TestEventA()), expected);
    });

    test('invokes all on<T> when event E is added where E is T', () async {
      var onEventCallCount = 0;
      var onACallCount = 0;
      var onBCallCount = 0;
      var onAACallCount = 0;
      var onBACallCount = 0;

      final bloc = TestBloc(
        onTestEvent: (_, __) => onEventCallCount++,
        onTestEventA: (_, __) => onACallCount++,
        onTestEventB: (_, __) => onBCallCount++,
        onTestEventAA: (_, __) => onAACallCount++,
        onTestEventBA: (_, __) => onBACallCount++,
      )..add(TestEventA());

      await Future<void>.delayed(Duration.zero);

      expect(onEventCallCount, equals(1));
      expect(onACallCount, equals(1));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(0));
      expect(onBACallCount, equals(0));

      bloc.add(TestEventAA());

      await Future<void>.delayed(Duration.zero);

      expect(onEventCallCount, equals(2));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(0));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      bloc.add(TestEventB());

      await Future<void>.delayed(Duration.zero);

      expect(onEventCallCount, equals(3));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(1));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(0));

      bloc.add(TestEventBA());

      await Future<void>.delayed(Duration.zero);

      expect(onEventCallCount, equals(4));
      expect(onACallCount, equals(2));
      expect(onBCallCount, equals(2));
      expect(onAACallCount, equals(1));
      expect(onBACallCount, equals(1));

      await bloc.close();
    });
  });
}
