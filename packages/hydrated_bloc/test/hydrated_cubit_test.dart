import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements Storage {}

class MyUuidHydratedCubit extends HydratedCubit<String> {
  MyUuidHydratedCubit() : super(Uuid().v4());

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String fromJson(dynamic json) => json['value'] as String;
}

class MyCallbackHydratedCubit extends HydratedCubit<int> {
  MyCallbackHydratedCubit({this.onFromJsonCalled}) : super(0);

  final ValueSetter<dynamic> onFromJsonCalled;

  void increment() => emit(state + 1);

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int fromJson(dynamic json) {
    onFromJsonCalled?.call(json);
    return json['value'] as int;
  }

  @override
  // ignore: must_call_super
  void onError(Object error, StackTrace stackTrace) {}
}

class MyHydratedCubit extends HydratedCubit<int> {
  MyHydratedCubit([this._id, this._callSuper = true]) : super(0);

  final String _id;
  final bool _callSuper;

  @override
  String get id => _id;

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int fromJson(dynamic json) => json['value'] as int;

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
  int fromJson(dynamic json) => json['value'] as int;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('HydratedCubit', () {
    Storage storage;

    setUp(() {
      storage = MockStorage();
      when(storage.write(any, any)).thenAnswer((_) async {});
      HydratedCubit.storage = storage;
    });

    test('reads from storage once upon initialization', () {
      MyCallbackHydratedCubit();
      verify<dynamic>(storage.read('MyCallbackHydratedCubit')).called(1);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () {
      when<dynamic>(storage.read('MyCallbackHydratedCubit')).thenReturn(
        {'value': 42},
      );
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 42);
      cubit.increment();
      expect(cubit.state, 43);
      verify<dynamic>(storage.read('MyCallbackHydratedCubit')).called(1);
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () {
      final fromJsonCalls = <dynamic>[];
      when<dynamic>(storage.read('MyCallbackHydratedCubit')).thenReturn(
        {'value': 42},
      );
      final cubit = MyCallbackHydratedCubit(
        onFromJsonCalled: fromJsonCalls.add,
      );
      expect(cubit.state, 42);
      cubit.increment();
      expect(cubit.state, 43);
      expect(fromJsonCalls, [
        {'value': 42}
      ]);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is empty', () {
      when<dynamic>(storage.read('MyCallbackHydratedCubit')).thenReturn(null);
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 0);
      cubit.increment();
      expect(cubit.state, 1);
      verify<dynamic>(storage.read('MyCallbackHydratedCubit')).called(1);
    });

    test('does not deserialize state when cache is empty', () {
      final fromJsonCalls = <dynamic>[];
      when<dynamic>(storage.read('MyCallbackHydratedCubit')).thenReturn(null);
      final cubit = MyCallbackHydratedCubit(
        onFromJsonCalled: fromJsonCalls.add,
      );
      expect(cubit.state, 0);
      cubit.increment();
      expect(cubit.state, 1);
      expect(fromJsonCalls, isEmpty);
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache is malformed', () {
      when<dynamic>(storage.read('MyCallbackHydratedCubit')).thenReturn('{');
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 0);
      cubit.increment();
      expect(cubit.state, 1);
      verify<dynamic>(storage.read('MyCallbackHydratedCubit')).called(1);
    });

    test('does not deserialize state when cache is malformed', () {
      final fromJsonCalls = <dynamic>[];
      runZoned(
        () {
          when<dynamic>(storage.read('MyCallbackHydratedCubit'))
              .thenReturn('{');
          MyCallbackHydratedCubit(onFromJsonCalled: fromJsonCalls.add);
        },
        onError: (dynamic error, StackTrace stackTrace) {
          expect(fromJsonCalls, isEmpty);
        },
      );
    });

    group('SingleHydratedCubit', () {
      test('should throw StorageNotFound when storage is null', () {
        HydratedCubit.storage = null;
        expect(
          () => MyHydratedCubit(),
          throwsA(isA<StorageNotFound>()),
        );
      });

      test('StorageNotFound overrides toString', () {
        expect(
          // ignore: prefer_const_constructors
          StorageNotFound().toString(),
          'Storage was accessed before it was initialized.\n'
          'Please ensure that storage has been initialized.\n\n'
          'For example:\n\n'
          'HydratedCubit.storage = await HydratedStorage.build();',
        );
      });

      test('storage getter returns correct storage instance', () {
        final storage = MockStorage();
        HydratedCubit.storage = storage;
        expect(HydratedCubit.storage, storage);
      });

      test('should call storage.write when onChange is called', () {
        final transition = const Change(currentState: 0, nextState: 0);
        final expected = <String, int>{'value': 0};
        MyHydratedCubit().onChange(transition);
        verify(storage.write('MyHydratedCubit', expected)).called(2);
      });

      test('should call storage.write when onChange is called with cubit id',
          () {
        final cubit = MyHydratedCubit('A');
        final transition = const Change(currentState: 0, nextState: 0);
        final expected = <String, int>{'value': 0};
        cubit.onChange(transition);
        verify(storage.write('MyHydratedCubitA', expected)).called(2);
      });

      test(
          'should throw CubitUnhandledErrorException when storage.write throws',
          () {
        runZoned(
          () async {
            final expectedError = Exception('oops');
            final transition = const Change(currentState: 0, nextState: 0);
            when(storage.write(any, any))
                .thenAnswer((_) => Future.error(expectedError));
            MyHydratedCubit().onChange(transition);
            await Future<void>.delayed(const Duration(seconds: 300));
            fail('should throw');
          },
          onError: (dynamic error) {
            expect(
              (error as CubitUnhandledErrorException).error.toString(),
              'Exception: oops',
            );
            expect(
              (error as CubitUnhandledErrorException).stackTrace,
              isNotNull,
            );
          },
        );
      });

      test('stores initial state when instantiated', () {
        MyHydratedCubit();
        verify<dynamic>(
          storage.write('MyHydratedCubit', {'value': 0}),
        ).called(1);
      });

      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyHydratedCubit')).thenReturn(null);
        expect(MyHydratedCubit().state, 0);
        verify<dynamic>(storage.read('MyHydratedCubit')).called(1);
      });

      test('initial state should return 0 when deserialization fails', () {
        when<dynamic>(storage.read('MyHydratedCubit'))
            .thenThrow(Exception('oops'));
        expect(MyHydratedCubit('', false).state, 0);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        when<dynamic>(storage.read('MyHydratedCubit'))
            .thenReturn({'value': 101});

        expect(MyHydratedCubit().state, 101);
        verify<dynamic>(storage.read('MyHydratedCubit')).called(1);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyHydratedCubit().clear();
          verify(storage.delete('MyHydratedCubit')).called(1);
        });
      });
    });

    group('MultiHydratedCubit', () {
      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyMultiHydratedCubitA')).thenReturn(null);
        expect(MyMultiHydratedCubit('A').state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedCubitA')).called(1);

        when<dynamic>(storage.read('MyMultiHydratedCubitB')).thenReturn(null);
        expect(MyMultiHydratedCubit('B').state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedCubitB')).called(1);
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        when<dynamic>(storage.read('MyMultiHydratedCubitA'))
            .thenReturn({'value': 101});
        expect(MyMultiHydratedCubit('A').state, 101);
        verify<dynamic>(storage.read('MyMultiHydratedCubitA')).called(1);

        when<dynamic>(storage.read('MyMultiHydratedCubitB'))
            .thenReturn({'value': 102});
        expect(MyMultiHydratedCubit('B').state, 102);
        verify<dynamic>(storage.read('MyMultiHydratedCubitB')).called(1);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyMultiHydratedCubit('A').clear();
          verify(storage.delete('MyMultiHydratedCubitA')).called(1);
          verifyNever(storage.delete('MyMultiHydratedCubitB'));

          await MyMultiHydratedCubit('B').clear();
          verify(storage.delete('MyMultiHydratedCubitB')).called(1);
        });
      });
    });

    group('MyUuidHydratedCubit', () {
      test('stores initial state when instantiated', () {
        MyUuidHydratedCubit();
        verify<dynamic>(storage.write('MyUuidHydratedCubit', any)).called(1);
      });

      test('correctly caches computed initial state', () {
        dynamic cachedState;
        when<dynamic>(storage.read('MyUuidHydratedCubit'))
            .thenReturn(cachedState);
        MyUuidHydratedCubit();
        cachedState = verify(storage.write('MyUuidHydratedCubit', captureAny))
            .captured
            .last;
        when<dynamic>(storage.read('MyUuidHydratedCubit'))
            .thenReturn(cachedState);
        MyUuidHydratedCubit();
        final dynamic initialStateB =
            verify(storage.write('MyUuidHydratedCubit', captureAny))
                .captured
                .last;
        expect(initialStateB, cachedState);
      });
    });
  });
}
