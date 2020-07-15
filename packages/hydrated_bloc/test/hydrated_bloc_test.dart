// ignore_for_file: invalid_use_of_protected_member
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';
import 'package:pedantic/pedantic.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements HydratedStorage {}

class MyUuidHydratedBloc extends HydratedBloc<String, String> {
  MyUuidHydratedBloc() : super(Uuid().v4());

  @override
  Stream<String> mapEventToState(String event) async* {}

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String fromJson(dynamic json) {
    try {
      return json['value'] as String;
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

enum CounterEvent { increment }

class MyCallbackHydratedBloc extends HydratedBloc<CounterEvent, int> {
  MyCallbackHydratedBloc({this.onFromJsonCalled}) : super(0);

  final ValueSetter<dynamic> onFromJsonCalled;

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
  int fromJson(dynamic json) {
    onFromJsonCalled?.call(json);
    return json['value'] as int;
  }
}

class MyHydratedBloc extends HydratedBloc<int, int> {
  MyHydratedBloc([this._id]) : super(0);

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
  int fromJson(dynamic json) {
    try {
      return json['value'] as int;
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
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
  int fromJson(dynamic json) {
    try {
      return json['value'] as int;
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

class MyErrorThrowingBloc extends HydratedBloc<Object, int> {
  MyErrorThrowingBloc({this.onErrorCallback, this.superOnError = true})
      : super(0);

  final Function(Object error, StackTrace stackTrace) onErrorCallback;
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
    // ignore: avoid_returning_null
    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HydratedBloc', () {
    MockStorage storage;

    setUp(() {
      storage = MockStorage();
      HydratedBloc.storage = storage;
      when(storage.write(any, any)).thenAnswer((_) async {});
    });

    test('storage getter returns correct storage instance', () {
      final storage = MockStorage();
      HydratedBloc.storage = storage;
      expect(HydratedBloc.storage, storage);
    });

    test('reads from storage once upon initialization', () {
      MyCallbackHydratedBloc();
      verify<dynamic>(storage.read('MyCallbackHydratedBloc')).called(1);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () async {
      when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn(
        {'value': 42},
      );
      final bloc = MyCallbackHydratedBloc();
      expect(bloc.state, 42);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[43]));
      verify<dynamic>(storage.read('MyCallbackHydratedBloc')).called(1);
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () async {
      final fromJsonCalls = <dynamic>[];
      when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn(
        {'value': 42},
      );
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
      when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn(null);
      final bloc = MyCallbackHydratedBloc();
      expect(bloc.state, 0);
      bloc.add(CounterEvent.increment);
      await expectLater(bloc, emitsInOrder(const <int>[1]));
      verify<dynamic>(storage.read('MyCallbackHydratedBloc')).called(1);
    });

    test('does not deserialize state when cache is empty', () async {
      final fromJsonCalls = <dynamic>[];
      when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn(null);
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
      unawaited(runZoned(() async {
        when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn('{');
        MyCallbackHydratedBloc().add(CounterEvent.increment);
      }, onError: (dynamic _) {
        verify<dynamic>(storage.read('MyCallbackHydratedBloc')).called(1);
      }));
    });

    test('does not deserialize state when cache is malformed', () async {
      final fromJsonCalls = <dynamic>[];
      unawaited(runZoned(() async {
        when<dynamic>(storage.read('MyCallbackHydratedBloc')).thenReturn('{');
        MyCallbackHydratedBloc(
          onFromJsonCalled: fromJsonCalls.add,
        ).add(CounterEvent.increment);
        expect(fromJsonCalls, isEmpty);
      }, onError: (dynamic _) {
        expect(fromJsonCalls, isEmpty);
      }));
    });

    group('SingleHydratedBloc', () {
      test('should call storage.write when onChange is called', () {
        const transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        const expected = <String, int>{'value': 0};
        MyHydratedBloc().onChange(transition);
        verify(
          storage.write('MyHydratedBloc', expected),
        ).called(2);
      });

      test('should call storage.write when onChange is called with bloc id',
          () {
        final bloc = MyHydratedBloc('A');
        const transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        const expected = <String, int>{'value': 0};
        bloc.onChange(transition);
        verify(
          storage.write('MyHydratedBlocA', expected),
        ).called(2);
      });

      test('should call onError when storage.write throws', () {
        runZoned(() async {
          final expectedError = Exception('oops');
          const transition = Transition(
            currentState: 0,
            event: 0,
            nextState: 0,
          );
          final bloc = MyHydratedBloc();
          when(storage.write(any, any))
              .thenAnswer((_) => Future.error(expectedError));
          bloc.onChange(transition);
          await Future<void>.delayed(const Duration(milliseconds: 300));
          // ignore: invalid_use_of_protected_member
          verify(bloc.onError(expectedError, any)).called(2);
        }, onError: (dynamic error) {
          expect(
            (error as CubitUnhandledErrorException).error.toString(),
            'Exception: oops',
          );
          expect((error as CubitUnhandledErrorException).stackTrace, isNotNull);
        });
      });

      test('stores initial state when instantiated', () {
        MyHydratedBloc();
        verify<dynamic>(
          storage.write('MyHydratedBloc', {'value': 0}),
        ).called(1);
      });

      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyHydratedBloc')).thenReturn(null);
        expect(MyHydratedBloc().state, 0);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(1);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        when<dynamic>(storage.read('MyHydratedBloc'))
            .thenReturn({'value': 101});
        expect(MyHydratedBloc().state, 101);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(1);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyHydratedBloc().clear();
          verify(storage.delete('MyHydratedBloc')).called(1);
        });
      });
    });

    group('MultiHydratedBloc', () {
      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA')).thenReturn(null);
        expect(MyMultiHydratedBloc('A').state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(1);

        when<dynamic>(storage.read('MyMultiHydratedBlocB')).thenReturn(null);
        expect(MyMultiHydratedBloc('B').state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(1);
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA'))
            .thenReturn({'value': 101});
        expect(MyMultiHydratedBloc('A').state, 101);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(1);

        when<dynamic>(storage.read('MyMultiHydratedBlocB'))
            .thenReturn({'value': 102});
        expect(MyMultiHydratedBloc('B').state, 102);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(1);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyMultiHydratedBloc('A').clear();
          verify(storage.delete('MyMultiHydratedBlocA')).called(1);
          verifyNever(storage.delete('MyMultiHydratedBlocB'));

          await MyMultiHydratedBloc('B').clear();
          verify(storage.delete('MyMultiHydratedBlocB')).called(1);
        });
      });
    });

    group('MyUuidHydratedBloc', () {
      test('stores initial state when instantiated', () {
        MyUuidHydratedBloc();
        verify<dynamic>(storage.write('MyUuidHydratedBloc', any)).called(1);
      });

      test('correctly caches computed initial state', () {
        dynamic cachedState;
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        cachedState = verify(storage.write('MyUuidHydratedBloc', captureAny))
            .captured
            .last;
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        final dynamic initialStateB =
            verify(storage.write('MyUuidHydratedBloc', captureAny))
                .captured
                .last;
        expect(initialStateB, cachedState);
      });
    });

    group('MyErrorThrowingBloc', () {
      test('continues to emit new states when serialization fails', () async {
        unawaited(runZoned(
          () async {
            final bloc = MyErrorThrowingBloc();
            final expectedStates = [0, 1, emitsDone];
            unawaited(expectLater(bloc, emitsInOrder(expectedStates)));
            bloc.add(Object);
            await bloc.close();
          },
          onError: (dynamic _) {},
        ));
      });

      test('calls onError when json decode fails', () async {
        Object lastError;
        StackTrace lastStackTrace;
        unawaited(runZoned(() async {
          when<dynamic>(storage.read(any)).thenReturn('invalid json');
          MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
        }, onError: (dynamic _) {
          expect(lastStackTrace, isNotNull);
          expect(
            lastError.toString().startsWith(
              '''Unhandled error type \'String\' is not a subtype of type \'Map<dynamic, dynamic>\' in type cast''',
            ),
            isTrue,
          );
        }));
      });

      test('returns super.state when json decode fails', () async {
        MyErrorThrowingBloc bloc;
        unawaited(runZoned(() async {
          when<dynamic>(storage.read(any)).thenReturn('invalid json');
          bloc = MyErrorThrowingBloc(superOnError: false);
        }, onError: (dynamic _) {
          expect(bloc.state, 0);
        }));
      });

      test('calls onError when storage.write fails', () async {
        Object lastError;
        StackTrace lastStackTrace;
        final exception = Exception('oops');
        unawaited(runZoned(() async {
          when(storage.write(any, any))
              .thenAnswer((_) => Future.error(exception));
          MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
        }, onError: (dynamic error) {
          expect(lastError, isA<HydratedUnsupportedError>());
          expect(lastStackTrace, isNotNull);
          expect(
            (error as CubitUnhandledErrorException).error.toString(),
            '''Converting object to an encodable object failed: Object''',
          );
          expect(
            (error as CubitUnhandledErrorException).stackTrace,
            isNotNull,
          );
        }));
      });

      test('calls onError when json encode fails', () async {
        unawaited(runZoned(
          () async {
            Object lastError;
            StackTrace lastStackTrace;
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
          onError: (dynamic _) {},
        ));
      });
    });
  });
}
