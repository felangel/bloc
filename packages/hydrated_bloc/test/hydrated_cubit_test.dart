import 'dart:async';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements Storage {}

class MyUuidHydratedCubit extends HydratedCubit<String> {
  MyUuidHydratedCubit() : super(Uuid().v4());

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
      when(storage).calls(#write).thenAnswer((_) async {});
      when(storage).calls(#read).thenReturn(<String, dynamic>{});
      when(storage).calls(#write).thenAnswer((_) async {});
      when(storage).calls(#delete).thenAnswer((_) async {});
      when(storage).calls(#clear).thenAnswer((_) async {});
      HydratedBloc.storage = storage;
    });

    test('reads from storage once upon initialization', () {
      MyCallbackHydratedCubit();
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedCubit']).once();
    });

    test(
        'does not read from storage on subsequent state changes '
        'when cache value exists', () {
      when(storage).calls(#read).thenReturn({'value': 42});
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 42);
      cubit.increment();
      expect(cubit.state, 43);
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedCubit']).once();
    });

    test(
        'does not deserialize state on subsequent state changes '
        'when cache value exists', () {
      final fromJsonCalls = <dynamic>[];
      when(storage).calls(#read).thenReturn({'value': 42});
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
      when(storage).calls(#read).thenReturn(null);
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 0);
      cubit.increment();
      expect(cubit.state, 1);
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedCubit']).once();
    });

    test('does not deserialize state when cache is empty', () {
      final fromJsonCalls = <dynamic>[];
      when(storage).calls(#read).thenReturn(null);
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
      when(storage).calls(#read).thenReturn('{');
      final cubit = MyCallbackHydratedCubit();
      expect(cubit.state, 0);
      cubit.increment();
      expect(cubit.state, 1);
      verify(storage)
          .called(#read)
          .withArgs(positional: ['MyCallbackHydratedCubit']).once();
    });

    test('does not deserialize state when cache is malformed', () {
      final fromJsonCalls = <dynamic>[];
      runZonedGuarded(
        () {
          when(storage).calls(#read).thenReturn('{');
          MyCallbackHydratedCubit(onFromJsonCalled: fromJsonCalls.add);
        },
        (_, __) {
          expect(fromJsonCalls, isEmpty);
        },
      );
    });

    group('SingleHydratedCubit', () {
      test('should throw StorageNotFound when storage is null', () {
        HydratedBloc.storage = null;
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
          'HydratedBloc.storage = await HydratedStorage.build();',
        );
      });

      test('storage getter returns correct storage instance', () {
        final storage = MockStorage();
        HydratedBloc.storage = storage;
        expect(HydratedBloc.storage, storage);
      });

      test('should call storage.write when onTransition is called', () {
        final transition = const Transition<Null, int>(
          currentState: 0,
          nextState: 0,
        );
        final expected = <String, int>{'value': 0};
        MyHydratedCubit().onTransition(transition);
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyHydratedCubit', expected]).times(2);
      });

      test(
          'should call storage.write when onTransition is called with cubit id',
          () {
        final cubit = MyHydratedCubit('A');
        final transition = const Transition<Null, int>(
          currentState: 0,
          nextState: 0,
        );
        final expected = <String, int>{'value': 0};
        cubit.onTransition(transition);
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyHydratedCubitA', expected]).times(2);
      });

      test('should throw BlocUnhandledErrorException when storage.write throws',
          () {
        runZonedGuarded(
          () async {
            final expectedError = Exception('oops');
            final transition = const Transition<Null, int>(
              currentState: 0,
              nextState: 0,
            );
            when(storage).calls(#write).thenThrow(expectedError);
            MyHydratedCubit().onTransition(transition);
            await Future<void>.delayed(const Duration(seconds: 300));
            fail('should throw');
          },
          (error, _) {
            expect(
              (error as BlocUnhandledErrorException).error.toString(),
              'Exception: oops',
            );
            expect(error.stackTrace, isNotNull);
          },
        );
      });

      test('stores initial state when instantiated', () {
        MyHydratedCubit();
        verify(storage).called(#write).withArgs(positional: [
          'MyHydratedCubit',
          {'value': 0}
        ]).once();
      });

      test('initial state should return 0 when fromJson returns null', () {
        when(storage).calls(#read).thenReturn(null);
        expect(MyHydratedCubit().state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyHydratedCubit']).once();
      });

      test('initial state should return 0 when deserialization fails', () {
        when(storage).calls(#read).thenThrow(Exception('oops'));
        expect(MyHydratedCubit('', false).state, 0);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        when(storage).calls(#read).thenReturn({'value': 101});
        expect(MyHydratedCubit().state, 101);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyHydratedCubit']).once();
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyHydratedCubit().clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyHydratedCubit']).once();
        });
      });
    });

    group('MultiHydratedCubit', () {
      test('initial state should return 0 when fromJson returns null', () {
        when(storage).calls(#read).thenReturn(null);
        expect(MyMultiHydratedCubit('A').state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedCubitA']).once();

        expect(MyMultiHydratedCubit('B').state, 0);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedCubitB']).once();
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        when(storage).calls(#read).withArgs(
          positional: ['MyMultiHydratedCubitA'],
        ).thenReturn({'value': 101});
        expect(MyMultiHydratedCubit('A').state, 101);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedCubitA']).once();

        when(storage).calls(#read).withArgs(
          positional: ['MyMultiHydratedCubitB'],
        ).thenReturn({'value': 102});
        expect(MyMultiHydratedCubit('B').state, 102);
        verify(storage)
            .called(#read)
            .withArgs(positional: ['MyMultiHydratedCubitB']).once();
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await MyMultiHydratedCubit('A').clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedCubitA']).once();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedCubitB']).never();

          await MyMultiHydratedCubit('B').clear();
          verify(storage)
              .called(#delete)
              .withArgs(positional: ['MyMultiHydratedCubitB']).once();
        });
      });
    });

    group('MyUuidHydratedCubit', () {
      test('stores initial state when instantiated', () {
        MyUuidHydratedCubit();
        verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedCubit', any]).once();
      });

      test('correctly caches computed initial state', () async {
        dynamic cachedState;
        when(storage).calls(#read).thenReturn(cachedState);
        when(storage).calls(#write).thenReturn(Future<void>.value());
        MyUuidHydratedCubit();
        final captured = verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedCubit', captureAny]).captured;
        cachedState = captured.last.first;
        when(storage).calls(#read).thenReturn(cachedState);
        MyUuidHydratedCubit();
        final secondCaptured = verify(storage)
            .called(#write)
            .withArgs(positional: ['MyUuidHydratedCubit', captureAny]).captured;
        final dynamic initialStateB = secondCaptured.last.first;

        expect(initialStateB, cachedState);
      });
    });
  });
}
