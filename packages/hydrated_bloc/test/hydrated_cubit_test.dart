import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements Storage {}

class MyUuidHydratedCubit extends HydratedCubit<String> {
  MyUuidHydratedCubit() : super(const Uuid().v4());

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String? fromJson(Map<String, dynamic> json) => json['value'] as String?;
}

class MyCallbackHydratedCubit extends HydratedCubit<int> {
  MyCallbackHydratedCubit({this.onFromJsonCalled}) : super(0);

  final void Function(dynamic)? onFromJsonCalled;

  void increment() => emit(state + 1);

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int? fromJson(dynamic json) {
    onFromJsonCalled?.call(json);
    return json['value'] as int?;
  }

  @override
  // ignore: must_call_super
  void onError(Object error, StackTrace stackTrace) {}
}

class MyHydratedCubit extends HydratedCubit<int> {
  MyHydratedCubit([this._id, this._callSuper = true]) : super(0);

  final String? _id;
  final bool _callSuper;

  @override
  String get id => _id ?? '';

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int? fromJson(dynamic json) => json['value'] as int?;

  @override
  void onError(Object error, StackTrace stackTrace) {
    if (_callSuper) super.onError(error, stackTrace);
  }
}

class MyMultiHydratedCubit extends HydratedCubit<int> {
  MyMultiHydratedCubit(String id)
      : _id = id,
        super(0);

  final String _id;

  @override
  String get id => _id;

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int? fromJson(dynamic json) => json['value'] as int?;
}

void main() {
  group('HydratedCubit', () {
    late Storage storage;

    setUp(() {
      storage = MockStorage();
      when(() => storage.write(any(), any<dynamic>())).thenAnswer((_) async {});
      when<dynamic>(() => storage.read(any())).thenReturn(<String, dynamic>{});
      when(() => storage.delete(any())).thenAnswer((_) async {});
      when(() => storage.clear()).thenAnswer((_) async {});
    });

    test('reads from storage once upon initialization', () {
      HydratedBlocOverrides.runZoned(() {
        MyCallbackHydratedCubit();
        verify<dynamic>(
          () => storage.read('MyCallbackHydratedCubit'),
        ).called(1);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () {
      HydratedBlocOverrides.runZoned(() {
        when<dynamic>(() => storage.read(any())).thenReturn({'value': 42});
        final cubit = MyCallbackHydratedCubit();
        expect(cubit.state, 42);
        cubit.increment();
        expect(cubit.state, 43);
        verify<dynamic>(() => storage.read('MyCallbackHydratedCubit'))
            .called(1);
      }, storage: storage);
    });

    test('reads from storage with support for legacy storage token', () {
      final legacyStorageToken = 'MyCallbackHydratedCubit';
      when<dynamic>(() => storage.read(legacyStorageToken)).thenReturn(null);
      HydratedBlocOverrides.runZoned(() {
        final cubit = MyCallbackHydratedCubit();
        final storageToken = identityHashCode(cubit);
        verify<dynamic>(
          () => storage.read('MyCallbackHydratedCubit'),
        ).called(1);
        verify<dynamic>(() => storage.read('$storageToken')).called(1);
      }, storage: storage);
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () {
      HydratedBlocOverrides.runZoned(() {
        final fromJsonCalls = <dynamic>[];
        when<dynamic>(() => storage.read(any())).thenReturn({'value': 42});
        final cubit = MyCallbackHydratedCubit(
          onFromJsonCalled: fromJsonCalls.add,
        );
        expect(cubit.state, 42);
        cubit.increment();
        expect(cubit.state, 43);
        expect(fromJsonCalls, [
          {'value': 42}
        ]);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is empty', () {
      HydratedBlocOverrides.runZoned(() {
        when<dynamic>(() => storage.read(any())).thenReturn(null);
        final cubit = MyCallbackHydratedCubit();
        expect(cubit.state, 0);
        cubit.increment();
        expect(cubit.state, 1);
        verify<dynamic>(() => storage.read('MyCallbackHydratedCubit'))
            .called(1);
      }, storage: storage);
    });

    test('does not deserialize state when cache is empty', () {
      HydratedBlocOverrides.runZoned(() {
        final fromJsonCalls = <dynamic>[];
        when<dynamic>(() => storage.read(any())).thenReturn(null);
        final cubit = MyCallbackHydratedCubit(
          onFromJsonCalled: fromJsonCalls.add,
        );
        expect(cubit.state, 0);
        cubit.increment();
        expect(cubit.state, 1);
        expect(fromJsonCalls, isEmpty);
      }, storage: storage);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is malformed', () {
      HydratedBlocOverrides.runZoned(() {
        when<dynamic>(() => storage.read(any())).thenReturn('{');
        final cubit = MyCallbackHydratedCubit();
        expect(cubit.state, 0);
        cubit.increment();
        expect(cubit.state, 1);
        verify<dynamic>(() => storage.read('MyCallbackHydratedCubit'))
            .called(1);
      }, storage: storage);
    });

    test('does not deserialize state when cache is malformed', () {
      HydratedBlocOverrides.runZoned(() {
        final fromJsonCalls = <dynamic>[];
        runZonedGuarded(
          () {
            when<dynamic>(() => storage.read(any())).thenReturn('{');
            MyCallbackHydratedCubit(onFromJsonCalled: fromJsonCalls.add);
          },
          (_, __) {
            expect(fromJsonCalls, isEmpty);
          },
        );
      }, storage: storage);
    });

    group('SingleHydratedCubit', () {
      test('should throw StorageNotFound when storage is null', () {
        expect(
          () => MyHydratedCubit(),
          throwsA(isA<StorageNotFound>()),
        );
      });

      test('should throw StorageNotFound when storage is default', () {
        HydratedBlocOverrides.runZoned(() {
          expect(
            () => MyHydratedCubit(),
            throwsA(isA<StorageNotFound>()),
          );
        });
      });

      test('StorageNotFound overrides toString', () {
        expect(
          // ignore: prefer_const_constructors
          StorageNotFound().toString(),
          'Storage was accessed before it was initialized.\n'
          'Please ensure that storage has been initialized.\n\n'
          'For example:\n\n'
          'final storage = await HydratedStorage.build();\n'
          'HydratedBlocOverrides.runZoned(\n'
          '  () => runApp(MyApp()),\n'
          '  storage: storage,\n'
          ');',
        );
      });

      test('storage getter returns correct storage instance', () {
        final storage = MockStorage();
        HydratedBlocOverrides.runZoned(() {
          expect(HydratedBlocOverrides.current!.storage, equals(storage));
        }, storage: storage);
      });

      test('should call storage.write when onChange is called', () {
        HydratedBlocOverrides.runZoned(() {
          final transition = const Change<int>(
            currentState: 0,
            nextState: 0,
          );
          final expected = <String, int>{'value': 0};
          final cubit = MyHydratedCubit()..onChange(transition);
          final storageToken = '${identityHashCode(cubit)}';
          verify(() => storage.write(storageToken, expected)).called(2);
        }, storage: storage);
      });

      test('should call storage.write when onChange is called with cubit id',
          () {
        HydratedBlocOverrides.runZoned(() {
          final id = 'A';
          final cubit = MyHydratedCubit(id);
          final transition = const Change<int>(
            currentState: 0,
            nextState: 0,
          );
          final expected = <String, int>{'value': 0};
          cubit.onChange(transition);
          final storageToken = '${identityHashCode(cubit)}$id';
          verify(() => storage.write(storageToken, expected)).called(2);
        }, storage: storage);
      });

      test('should throw BlocUnhandledErrorException when storage.write throws',
          () {
        HydratedBlocOverrides.runZoned(() {
          runZonedGuarded(
            () async {
              final expectedError = Exception('oops');
              final transition = const Change<int>(
                currentState: 0,
                nextState: 0,
              );
              when(
                () => storage.write(any(), any<dynamic>()),
              ).thenThrow(expectedError);
              MyHydratedCubit().onChange(transition);
              await Future<void>.delayed(const Duration(seconds: 300));
              fail('should throw');
            },
            (error, _) {
              expect(error.toString(), 'Exception: oops');
            },
          );
        }, storage: storage);
      });

      test('stores initial state when instantiated', () {
        HydratedBlocOverrides.runZoned(() {
          final cubit = MyHydratedCubit();
          verify(
            () => storage.write(cubit.storageToken, {'value': 0}),
          ).called(1);
        }, storage: storage);
      });

      test('initial state should return 0 when fromJson returns null', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn(null);
          final cubit = MyHydratedCubit();
          expect(cubit.state, 0);
          verify<dynamic>(() => storage.read(cubit.storageToken)).called(1);
        }, storage: storage);
      });

      test('initial state should return 0 when deserialization fails', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenThrow(Exception('oops'));
          expect(MyHydratedCubit('', false).state, 0);
        }, storage: storage);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn({'value': 101});
          when<dynamic>(() => storage.read('MyHydratedCubit')).thenReturn(null);
          final cubit = MyHydratedCubit();
          expect(cubit.state, 101);
          verify<dynamic>(() => storage.read(cubit.storageToken)).called(1);
        }, storage: storage);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await HydratedBlocOverrides.runZoned(() async {
            final cubit = MyHydratedCubit();
            await cubit.clear();
            verify(() => storage.delete(cubit.storageToken)).called(1);
          }, storage: storage);
        });
      });
    });

    group('MultiHydratedCubit', () {
      test('initial state should return 0 when fromJson returns null', () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn(null);
          final idA = 'A';
          final cubitA = MyMultiHydratedCubit(idA);
          final storageTokenA = '${identityHashCode(cubitA)}$idA';
          expect(cubitA.state, 0);
          verify<dynamic>(() => storage.read(storageTokenA)).called(1);

          final idB = 'B';
          final cubitB = MyMultiHydratedCubit(idB);
          final storageTokenB = '${identityHashCode(cubitB)}$idB';
          expect(cubitB.state, 0);
          verify<dynamic>(() => storage.read(storageTokenB)).called(1);
        }, storage: storage);
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        HydratedBlocOverrides.runZoned(() {
          when<dynamic>(() => storage.read(any())).thenReturn({'value': 101});
          when<dynamic>(
            () => storage.read('MyMultiHydratedCubitA'),
          ).thenReturn(null);
          final cubitA = MyMultiHydratedCubit('A');
          expect(cubitA.state, 101);
          verify<dynamic>(() => storage.read(cubitA.storageToken)).called(1);

          when<dynamic>(() => storage.read(any())).thenReturn({'value': 102});
          when<dynamic>(
            () => storage.read('MyMultiHydratedCubitB'),
          ).thenReturn(null);
          final cubitB = MyMultiHydratedCubit('B');
          expect(cubitB.state, 102);
          verify<dynamic>(() => storage.read(cubitB.storageToken)).called(1);
        }, storage: storage);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await HydratedBlocOverrides.runZoned(() async {
            final cubitA = MyMultiHydratedCubit('A');
            final cubitB = MyMultiHydratedCubit('B');
            await cubitA.clear();
            verify(() => storage.delete(cubitA.storageToken)).called(1);
            verifyNever(() => storage.delete(cubitB.storageToken));

            await cubitB.clear();
            verify(() => storage.delete(cubitB.storageToken)).called(1);
          }, storage: storage);
        });
      });
    });

    group('MyUuidHydratedCubit', () {
      test('stores initial state when instantiated', () {
        HydratedBlocOverrides.runZoned(() {
          final cubit = MyUuidHydratedCubit();
          verify(
            () => storage.write(cubit.storageToken, any<dynamic>()),
          ).called(1);
        }, storage: storage);
      });

      test('correctly caches computed initial state', () {
        HydratedBlocOverrides.runZoned(() {
          dynamic cachedState;
          when<dynamic>(() => storage.read(any())).thenReturn(cachedState);
          when(
            () => storage.write(any(), any<dynamic>()),
          ).thenAnswer((_) => Future<void>.value());
          final cubitA = MyUuidHydratedCubit();
          final captured = verify(
            () => storage.write(cubitA.storageToken, captureAny<dynamic>()),
          ).captured;
          cachedState = captured.first;
          when<dynamic>(() => storage.read(any())).thenReturn(cachedState);
          final cubitB = MyUuidHydratedCubit();
          final secondCaptured = verify(
            () => storage.write(cubitB.storageToken, captureAny<dynamic>()),
          ).captured;
          final dynamic initialStateB = secondCaptured.first;

          expect(initialStateB, cachedState);
        }, storage: storage);
      });
    });
  });
}
