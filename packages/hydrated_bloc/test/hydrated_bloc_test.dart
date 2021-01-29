// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
import 'package:test/test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc/bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements Storage {}

class MyUuidHydratedBloc extends HydratedBloc<String, String?> {
  MyUuidHydratedBloc() : super(Uuid().v4());

  @override
  Stream<String> mapEventToState(String event) async* {}

  @override
  Map<String, String?> toJson(String? state) => {'value': state};

  @override
  String? fromJson(dynamic json) {
    try {
      return json['value'] as String;
    } catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

enum CounterEvent { increment }

class MyCallbackHydratedBloc extends HydratedBloc<CounterEvent, int> {
  MyCallbackHydratedBloc({this.onFromJsonCalled}) : super(0);

  final void Function(dynamic)? onFromJsonCalled;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) {
    onFromJsonCalled?.call(json);
    return json['value'] as int?;
  }
}

class MyHydratedBloc extends HydratedBloc<int, int> {
  MyHydratedBloc([this._id]) : super(0);

  final String? _id;

  @override
  String get id => _id ?? '';

  @override
  Stream<int> mapEventToState(int event) async* {}

  @override
  Map<String, int>? toJson(int state) {
    return {'value': state};
  }

  @override
  int? fromJson(Map<String, dynamic> json) => json['value'] as int?;
}

class MyMultiHydratedBloc extends HydratedBloc<int, int> {
  MyMultiHydratedBloc(String id)
      : _id = id,
        super(0);

  final String _id;

  @override
  String get id => _id;

  @override
  Stream<int> mapEventToState(int event) async* {}

  @override
  Map<String, int> toJson(int state) {
    return {'value': state};
  }

  @override
  int? fromJson(dynamic json) => json['value'] as int?;
}

class MyErrorThrowingBloc extends HydratedBloc<Object, int> {
  MyErrorThrowingBloc({this.onErrorCallback, this.superOnError = true})
      : super(0);

  final Function(Object error, StackTrace stackTrace)? onErrorCallback;
  final bool superOnError;

  @override
  Stream<int> mapEventToState(Object event) async* {
    yield state + 1;
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    if (superOnError) {
      super.onError(error, stackTrace);
    }
  }

  @override
  Map<String, dynamic> toJson(int state) {
    return <String, Object>{'key': Object};
  }

  @override
  int fromJson(dynamic json) {
    return 0;
  }
}

void main() {
  group('HydratedBloc', () {
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(storage).calls(#read).thenReturn(<String, dynamic>{});
      when(storage).calls(#write).thenAnswer((_) async {});
      when(storage).calls(#delete).thenAnswer((_) async {});
      when(storage).calls(#clear).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
    });

    test('storage getter returns correct storage instance', () {
      final storage = MockStorage();
      HydratedBloc.storage = storage;
      expect(HydratedBloc.storage, storage);
    });

    test('reads from storage once upon initialization', () {
      MyCallbackHydratedBloc();
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedBloc']).once();
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () async {
      when(storage).calls(#read).thenReturn({'value': 42});
      final bloc = MyCallbackHydratedBloc();
      expect(bloc.state, 42);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[43]));
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedBloc']).once();
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () async {
      final fromJsonCalls = <dynamic>[];
      when(storage).calls(#read).thenReturn({'value': 42});
      final bloc = MyCallbackHydratedBloc(
        onFromJsonCalled: fromJsonCalls.add,
      );
      expect(bloc.state, 42);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[43]));
      expect(fromJsonCalls, [
        {'value': 42}
      ]);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is empty', () async {
      when(storage).calls(#read).thenReturn(null);
      final bloc = MyCallbackHydratedBloc();
      expect(bloc.state, 0);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[1]));
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedBloc']).once();
    });

    test('does not deserialize state when cache is empty', () async {
      final fromJsonCalls = <dynamic>[];
      when(storage).calls(#read).thenReturn(null);
      final bloc = MyCallbackHydratedBloc(
        onFromJsonCalled: fromJsonCalls.add,
      );
      expect(bloc.state, 0);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[1]));
      expect(fromJsonCalls, isEmpty);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is malformed', () async {
      unawaited(runZonedGuarded(() async {
        when(storage).calls(#read).thenReturn('{');
        MyCallbackHydratedBloc().add(CounterEvent.increment);
      }, (_, __) {
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyCallbackHydratedBloc']).once();
      }));
    });

    test('does not deserialize state when cache is malformed', () async {
      final fromJsonCalls = <dynamic>[];
      unawaited(runZonedGuarded(() async {
        when(storage).calls(#read).thenReturn('{');
        MyCallbackHydratedBloc(
          onFromJsonCalled: fromJsonCalls.add,
        ).add(CounterEvent.increment);
        expect(fromJsonCalls, isEmpty);
      }, (_, __) {
        expect(fromJsonCalls, isEmpty);
      }));
    });

    group('SingleHydratedBloc', () {
      test('should call storage.write when onTransition is called', () {
        const transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        const expected = <String, int>{'value': 0};
        MyHydratedBloc().onTransition(transition);
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyHydratedBloc', expected]).times(2);
      });

      test('should call storage.write when onTransition is called with bloc id',
          () {
        final bloc = MyHydratedBloc('A');
        const transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        const expected = <String, int>{'value': 0};
        bloc.onTransition(transition);
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyHydratedBlocA', expected]).times(2);
      });

      test('should call onError when storage.write throws', () {
        runZonedGuarded(() async {
          final expectedError = Exception('oops');
          const transition = Transition(
            currentState: 0,
            event: 0,
            nextState: 0,
          );
          final bloc = MyHydratedBloc();
          when(storage).calls(#write).thenThrow(expectedError);
          bloc.onTransition(transition);
          await Future<void>.delayed(const Duration(milliseconds: 300));
          verify(bloc)
              .called(#onError)
              .withArgs(positional: [expectedError, any]).times(2);
        }, (error, _) {
          expect(
            (error as BlocUnhandledErrorException).error.toString(),
            'Exception: oops',
          );
          expect((error).stackTrace, isNotNull);
        });
      });

      test('stores initial state when instantiated', () {
        MyHydratedBloc();
        verify(storage).called(#write).withArgs(
          positional: [
            'MyHydratedBloc',
            {'value': 0}
          ],
        ).once();
      });

      test('initial state should return 0 when fromJson returns null', () {
        when(storage).calls(#read).thenReturn(null);
        expect(MyHydratedBloc().state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyHydratedBloc']).once();
      });

      test('initial state should return 101 when fromJson returns 101', () {
        when(storage).calls(#read).thenReturn({'value': 101});
        expect(MyHydratedBloc().state, 101);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyHydratedBloc']).once();
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyHydratedBloc().clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyHydratedBloc']).once();
        });
      });
    });

    group('MultiHydratedBloc', () {
      test('initial state should return 0 when fromJson returns null', () {
        when(storage).calls(#read).thenReturn(null);
        expect(MyMultiHydratedBloc('A').state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedBlocA']).once();

        expect(MyMultiHydratedBloc('B').state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedBlocB']).once();
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        when(storage).calls(#read).withArgs(
          positional: ['MyMultiHydratedBlocA'],
        ).thenReturn({'value': 101});
        expect(MyMultiHydratedBloc('A').state, 101);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedBlocA']).once();

        when(storage).calls(#read).withArgs(
          positional: ['MyMultiHydratedBlocB'],
        ).thenReturn({'value': 102});
        expect(MyMultiHydratedBloc('B').state, 102);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedBlocB']).once();
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyMultiHydratedBloc('A').clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedBlocA']).once();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedBlocB']).never();

          await MyMultiHydratedBloc('B').clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedBlocB']).once();
        });
      });
    });

    group('MyUuidHydratedBloc', () {
      test('stores initial state when instantiated', () {
        MyUuidHydratedBloc();
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedBloc', any]).once();
      });

      test('correctly caches computed initial state', () async {
        dynamic cachedState;
        when(storage).calls(#read).thenReturn(cachedState);
        when(storage).calls(#write).thenReturn(Future<void>.value());
        MyUuidHydratedBloc();
        final captured = verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedBloc', captureAny]).captured;
        cachedState = captured.last.first;
        when(storage).calls(#read).thenReturn(cachedState);
        MyUuidHydratedBloc();
        final secondCaptured = verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedBloc', captureAny]).captured;
        final dynamic initialStateB = secondCaptured.last.first;

        expect(initialStateB, cachedState);
      });
    });

    group('MyErrorThrowingBloc', () {
      test('continues to emit new states when serialization fails', () async {
        unawaited(runZonedGuarded(
          () async {
            final bloc = MyErrorThrowingBloc();
            final expectedStates = [0, 1, emitsDone];
            unawaited(expectLater(bloc, emitsInOrder(expectedStates)));
            bloc.add(Object);
            await bloc.close();
          },
          (_, __) {},
        ));
      });

      test('calls onError when json decode fails', () async {
        Object? lastError;
        StackTrace? lastStackTrace;
        unawaited(runZonedGuarded(() async {
          when(storage).calls(#read).thenReturn('invalid json');
          MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
        }, (_, __) {
          expect(lastStackTrace, isNotNull);
          expect(
            lastError.toString().startsWith(
              '''Unhandled error type \'String\' is not a subtype of type \'Map<dynamic, dynamic>?\' in type cast''',
            ),
            isTrue,
          );
        }));
      });

      test('returns super.state when json decode fails', () async {
        MyErrorThrowingBloc? bloc;
        unawaited(runZonedGuarded(() async {
          when(storage).calls(#read).thenReturn('invalid json');
          bloc = MyErrorThrowingBloc(superOnError: false);
        }, (_, __) {
          expect(bloc?.state, 0);
        }));
      });

      test('calls onError when storage.write fails', () async {
        Object? lastError;
        StackTrace? lastStackTrace;
        final exception = Exception('oops');
        unawaited(runZonedGuarded(() async {
          when(storage).calls(#write).thenThrow(exception);
          MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
        }, (error, _) {
          expect(lastError, isA<HydratedUnsupportedError>());
          expect(lastStackTrace, isNotNull);
          expect(
            (error as BlocUnhandledErrorException).error.toString(),
            '''Converting object to an encodable object failed: Object''',
          );
          expect(error.stackTrace, isNotNull);
        }));
      });

      test('calls onError when json encode fails', () async {
        unawaited(runZonedGuarded(
          () async {
            Object? lastError;
            StackTrace? lastStackTrace;
            final bloc = MyErrorThrowingBloc(
              onErrorCallback: (error, stackTrace) {
                lastError = error;
                lastStackTrace = stackTrace;
              },
            )..add(Object);
            await bloc.close();
            expect(
              '$lastError',
              'Converting object to an encodable object failed: Object',
            );
            expect(lastStackTrace, isNotNull);
          },
          (_, __) {},
        ));
      });
    });
  });
}
