// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

void unawaited(Future<void>? _) {}

class MockStorage extends Mock implements Storage {}

class MyUuidHydratedBloc extends HydratedBloc<String, String?> {
  MyUuidHydratedBloc() : super(const Uuid().v4());

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

abstract class CounterEvent {}

class Increment extends CounterEvent {}

class MyCallbackHydratedBloc extends HydratedBloc<CounterEvent, int> {
  MyCallbackHydratedBloc({this.onFromJsonCalled}) : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
  }

  final void Function(dynamic)? onFromJsonCalled;

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int? fromJson(Map<String, dynamic> json) {
    onFromJsonCalled?.call(json);
    return json['value'] as int?;
  }
}

class MyHydratedBloc extends HydratedBloc<int, int> {
  MyHydratedBloc([this._id, this._storagePrefix]) : super(0);

  final String? _id;
  final String? _storagePrefix;

  @override
  String get id => _id ?? '';

  @override
  String get storagePrefix => _storagePrefix ?? super.storagePrefix;

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
  Map<String, int> toJson(int state) {
    return {'value': state};
  }

  @override
  int? fromJson(dynamic json) => json['value'] as int?;
}

class MyErrorThrowingBloc extends HydratedBloc<Object, int> {
  MyErrorThrowingBloc({this.onErrorCallback, this.superOnError = true})
      : super(0) {
    on<Object>((event, emit) => emit(state + 1));
  }

  final Function(Object error, StackTrace stackTrace)? onErrorCallback;
  final bool superOnError;

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
  group('HydratedBloc (legacy)', () {
    late Storage storage;

    setUpAll(() {
      registerFallbackValue(StackTrace.empty);
      registerFallbackValue(const <String, String?>{});
    });

    setUp(() {
      storage = MockStorage();
      when<dynamic>(() => storage.read(any())).thenReturn(<String, dynamic>{});
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
    });

    test('storage getter returns correct storage instance', () {
      final storage = MockStorage();
      HydratedBlocOverrides.runZoned(() {
        expect(HydratedBlocOverrides.current!.storage, equals(storage));
      }, storage: storage);
    });

    test('reads from storage once upon initialization', () {
      HydratedBlocOverrides.runZoned(() {
        MyCallbackHydratedBloc();
        verify<dynamic>(() => storage.read('MyCallbackHydratedBloc')).called(1);
      }, storage: storage);
    });

    test(
        'reads from storage once upon initialization w/custom storagePrefix/id',
        () {
      HydratedBlocOverrides.runZoned(() {
        const storagePrefix = '__storagePrefix__';
        const id = '__id__';
        MyHydratedBloc(id, storagePrefix);
        verify<dynamic>(() => storage.read('$storagePrefix$id')).called(1);
      }, storage: storage);
    });

    test('writes to storage when onChange is called w/custom storagePrefix/id',
        () {
      HydratedBlocOverrides.runZoned(() {
        const change = Change(
          currentState: 0,
          nextState: 0,
        );
        const expected = <String, int>{'value': 0};
        const storagePrefix = '__storagePrefix__';
        const id = '__id__';
        MyHydratedBloc(id, storagePrefix).onChange(change);
        verify(() => storage.write('$storagePrefix$id', expected)).called(2);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () async {
      await HydratedBlocOverrides.runZoned(() async {
        when<dynamic>(() => storage.read(any())).thenReturn({'value': 42});
        final bloc = MyCallbackHydratedBloc();
        expect(bloc.state, 42);
        bloc.add(Increment());
        await expectLater(bloc.stream, emitsInOrder(const <int>[43]));
        verify<dynamic>(() => storage.read('MyCallbackHydratedBloc')).called(1);
      }, storage: storage);
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () async {
      await HydratedBlocOverrides.runZoned(() async {
        final fromJsonCalls = <dynamic>[];
        when<dynamic>(() => storage.read(any())).thenReturn({'value': 42});
        final bloc = MyCallbackHydratedBloc(
          onFromJsonCalled: fromJsonCalls.add,
        );
        expect(bloc.state, 42);
        bloc.add(Increment());
        await expectLater(bloc.stream, emitsInOrder(const <int>[43]));
        expect(fromJsonCalls, [
          {'value': 42}
        ]);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is empty', () async {
      await HydratedBlocOverrides.runZoned(() async {
        when<dynamic>(() => storage.read(any())).thenReturn(null);
        final bloc = MyCallbackHydratedBloc();
        expect(bloc.state, 0);
        bloc.add(Increment());
        await expectLater(bloc.stream, emitsInOrder(const <int>[1]));
        verify<dynamic>(() => storage.read('MyCallbackHydratedBloc')).called(1);
      }, storage: storage);
    });

    test('does not deserialize state when cache is empty', () async {
      await HydratedBlocOverrides.runZoned(() async {
        final fromJsonCalls = <dynamic>[];
        when<dynamic>(() => storage.read(any())).thenReturn(null);
        final bloc = MyCallbackHydratedBloc(
          onFromJsonCalled: fromJsonCalls.add,
        );
        expect(bloc.state, 0);
        bloc.add(Increment());
        await expectLater(bloc.stream, emitsInOrder(const <int>[1]));
        expect(fromJsonCalls, isEmpty);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is malformed', () async {
      await HydratedBlocOverrides.runZoned(() async {
        unawaited(runZonedGuarded(() async {
          when<dynamic>(() => storage.read(any())).thenReturn('{');
          MyCallbackHydratedBloc().add(Increment());
        }, (_, __) {
          verify<dynamic>(() => storage.read('MyCallbackHydratedBloc'))
              .called(1);
        }));
      }, storage: storage);
    });

    test('does not deserialize state when cache is malformed', () async {
      await HydratedBlocOverrides.runZoned(() async {
        final fromJsonCalls = <dynamic>[];
        unawaited(runZonedGuarded(() async {
          when<dynamic>(() => storage.read(any())).thenReturn('{');
          MyCallbackHydratedBloc(
            onFromJsonCalled: fromJsonCalls.add,
          ).add(Increment());
          expect(fromJsonCalls, isEmpty);
        }, (_, __) {
          expect(fromJsonCalls, isEmpty);
        }));
      }, storage: storage);
    });

    group('SingleHydratedBloc', () {
      test('should call storage.write when onChange is called', () {
        HydratedBlocOverrides.runZoned(() {
          const change = Change(
            currentState: 0,
            nextState: 0,
          );
          const expected = <String, int>{'value': 0};
          MyHydratedBloc().onChange(change);
          verify(() => storage.write('MyHydratedBloc', expected)).called(2);
        }, storage: storage);
      });

      test('should call storage.write when onChange is called with bloc id',
          () {
        HydratedBlocOverrides.runZoned(() {
          final bloc = MyHydratedBloc('A');
          const change = Change(
            currentState: 0,
            nextState: 0,
          );
          const expected = <String, int>{'value': 0};
          bloc.onChange(change);
          verify(() => storage.write('MyHydratedBlocA', expected)).called(2);
        }, storage: storage);
      });

      test('should call onError when storage.write throws', () {
        HydratedBlocOverrides.runZoned(() {
          runZonedGuarded(() async {
            final expectedError = Exception('oops');
            const change = Change(
              currentState: 0,
              nextState: 0,
            );
            final bloc = MyHydratedBloc();
            when(
              () => storage.write(any(), any<dynamic>()),
            ).thenThrow(expectedError);
            bloc.onChange(change);
            await Future<void>.delayed(const Duration(milliseconds: 300));
            // ignore: invalid_use_of_protected_member
            verify(() => bloc.onError(expectedError, any())).called(2);
          }, (error, _) {
            expect(error.toString(), 'Exception: oops');
          });
        }, storage: storage);
      });

      test('stores initial state when instantiated', () {
        HydratedBlocOverrides.runZoned(() {
          MyHydratedBloc();
          verify(
            () => storage.write('MyHydratedBloc', {'value': 0}),
          ).called(1);
        }, storage: storage);
      });

      test('initial state should return 0 when fromJson returns null', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn(null);
          expect(MyHydratedBloc().state, 0);
          verify<dynamic>(() => storage.read('MyHydratedBloc')).called(1);
        }, storage: storage);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn({'value': 101});
          expect(MyHydratedBloc().state, 101);
          verify<dynamic>(() => storage.read('MyHydratedBloc')).called(1);
        }, storage: storage);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await HydratedBlocOverrides.runZoned(() async {
            await MyHydratedBloc().clear();
            verify(() => storage.delete('MyHydratedBloc')).called(1);
          }, storage: storage);
        });
      });
    });

    group('MultiHydratedBloc', () {
      test('initial state should return 0 when fromJson returns null', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn(null);
          expect(MyMultiHydratedBloc('A').state, 0);
          verify<dynamic>(() => storage.read('MyMultiHydratedBlocA')).called(1);

          expect(MyMultiHydratedBloc('B').state, 0);
          verify<dynamic>(() => storage.read('MyMultiHydratedBlocB')).called(1);
        }, storage: storage);
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(
            () => storage.read('MyMultiHydratedBlocA'),
          ).thenReturn({'value': 101});
          expect(MyMultiHydratedBloc('A').state, 101);
          verify<dynamic>(() => storage.read('MyMultiHydratedBlocA')).called(1);

          when<dynamic>(
            () => storage.read('MyMultiHydratedBlocB'),
          ).thenReturn({'value': 102});
          expect(MyMultiHydratedBloc('B').state, 102);
          verify<dynamic>(() => storage.read('MyMultiHydratedBlocB')).called(1);
        }, storage: storage);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await HydratedBlocOverrides.runZoned(() async {
            await MyMultiHydratedBloc('A').clear();
            verify(() => storage.delete('MyMultiHydratedBlocA')).called(1);
            verifyNever(() => storage.delete('MyMultiHydratedBlocB'));

            await MyMultiHydratedBloc('B').clear();
            verify(() => storage.delete('MyMultiHydratedBlocB')).called(1);
          }, storage: storage);
        });
      });
    });

    group('MyUuidHydratedBloc', () {
      test('stores initial state when instantiated', () async {
        await HydratedBlocOverrides.runZoned(() async {
          when(
            () => storage.write(any<String>(), any<Map<String, String?>>()),
          ).thenAnswer((_) async {});
          MyUuidHydratedBloc();
          await untilCalled(
            () => storage.write(any<String>(), any<Map<String, String?>>()),
          );
          verify(
            () => storage.write(
              'MyUuidHydratedBloc',
              any<Map<String, String?>>(),
            ),
          ).called(1);
        }, storage: storage);
      });

      test('correctly caches computed initial state', () async {
        await HydratedBlocOverrides.runZoned(() async {
          dynamic cachedState;
          when<dynamic>(() => storage.read(any())).thenReturn(cachedState);
          when(
            () => storage.write(any(), any<dynamic>()),
          ).thenAnswer((_) => Future<void>.value());
          MyUuidHydratedBloc();
          final captured = verify(
            () => storage.write('MyUuidHydratedBloc', captureAny<dynamic>()),
          ).captured;
          cachedState = captured.first;
          when<dynamic>(() => storage.read(any())).thenReturn(cachedState);
          MyUuidHydratedBloc();
          final secondCaptured = verify(
            () => storage.write('MyUuidHydratedBloc', captureAny<dynamic>()),
          ).captured;
          final dynamic initialStateB = secondCaptured.first;

          expect(initialStateB, cachedState);
        }, storage: storage);
      });
    });

    group('MyErrorThrowingBloc', () {
      test('continues to emit new states when serialization fails', () async {
        await HydratedBlocOverrides.runZoned(() async {
          await runZonedGuarded(
            () async {
              final bloc = MyErrorThrowingBloc();
              final expectedStates = [0, 1, emitsDone];
              unawaited(expectLater(bloc.stream, emitsInOrder(expectedStates)));
              bloc.add(Object);
              await bloc.close();
            },
            (_, __) {},
          );
        }, storage: storage);
      });

      test('calls onError when json decode fails', () async {
        await HydratedBlocOverrides.runZoned(() async {
          Object? lastError;
          StackTrace? lastStackTrace;
          await runZonedGuarded(() async {
            when<dynamic>(() => storage.read(any())).thenReturn('invalid json');
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
          });
        }, storage: storage);
      });

      test('returns super.state when json decode fails', () async {
        await HydratedBlocOverrides.runZoned(() async {
          MyErrorThrowingBloc? bloc;
          await runZonedGuarded(() async {
            when<dynamic>(() => storage.read(any())).thenReturn('invalid json');
            bloc = MyErrorThrowingBloc(superOnError: false);
          }, (_, __) {
            expect(bloc?.state, 0);
          });
        }, storage: storage);
      });

      test('calls onError when storage.write fails', () async {
        await HydratedBlocOverrides.runZoned(() async {
          Object? lastError;
          StackTrace? lastStackTrace;
          final exception = Exception('oops');
          await runZonedGuarded(() async {
            when(() => storage.write(any(), any<dynamic>()))
                .thenThrow(exception);
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
              error.toString(),
              '''Converting object to an encodable object failed: Object''',
            );
          });
        }, storage: storage);
      });

      test('calls onError when json encode fails', () async {
        await HydratedBlocOverrides.runZoned(() async {
          await runZonedGuarded(
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
          );
        }, storage: storage);
      });
    });
  });
}
