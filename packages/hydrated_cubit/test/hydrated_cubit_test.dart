import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_cubit/hydrated_cubit.dart';
import 'package:cubit/cubit.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements HydratedCubitStorage {}

class MockCubit extends Mock implements HydratedCubit<dynamic> {
  @override
  String get storageToken => '${runtimeType.toString()}$id';
}

class MyUuidHydratedCubit extends HydratedCubit<String> {
  MyUuidHydratedCubit() : super(Uuid().v4());

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String fromJson(dynamic json) => json['value'] as String;
}

class MyHydratedCubit extends HydratedCubit<int> {
  MyHydratedCubit([this._id]) : super(0);

  final String _id;

  @override
  String get id => _id;

  @override
  Map<String, int> toJson(int state) => {'value': state};

  @override
  int fromJson(dynamic json) => json['value'] as int;
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
    MockStorage storage;

    setUp(() {
      storage = MockStorage();
      HydratedCubit.storage = storage;
    });

    group('SingleHydratedCubit', () {
      MyHydratedCubit cubit;

      setUp(() {
        cubit = MyHydratedCubit();
      });

      test('should throw HydratedStorageNotFound when storage is null', () {
        HydratedCubit.storage = null;
        expect(
          () => MyHydratedCubit(),
          throwsA(isA<HydratedStorageNotFound>()),
        );
      });

      test('HydratedStorageNotFound overrides toString', () {
        expect(
          // ignore: prefer_const_constructors
          HydratedStorageNotFound().toString(),
          'HydratedStorage was accessed before it was initialized.\n'
          'Please ensure that storage has been initialized.\n\n'
          'For example:\n\n'
          'HydratedCubit.storage = await HydratedCubitStorage.getInstance();',
        );
      });

      test('should call storage.write when onTransition is called', () {
        final transition = const Transition(currentState: 0, nextState: 0);
        final expected = <String, int>{'value': 0};
        cubit.onTransition(transition);
        verify(storage.write('MyHydratedCubit', expected)).called(2);
      });

      test(
          'should call storage.write when onTransition is called with cubit id',
          () {
        final cubit = MyHydratedCubit('A');
        final transition = const Transition(currentState: 0, nextState: 0);
        final expected = <String, int>{'value': 0};
        cubit.onTransition(transition);
        verify(storage.write('MyHydratedCubitA', expected)).called(2);
      });

      test('should do nothing when storage.write throws', () {
        runZoned(() {
          final expectedError = Exception('oops');
          final transition = const Transition(currentState: 0, nextState: 0);
          when(storage.write(any, any)).thenThrow(expectedError);
          cubit.onTransition(transition);
        }, onError: (dynamic _) => fail('should not throw'));
      });

      test('stores initial state when instantiated', () {
        verify<dynamic>(
          storage.write('MyHydratedCubit', {'value': 0}),
        ).called(1);
      });

      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyHydratedCubit')).thenReturn(null);
        expect(cubit.state, 0);
        verify<dynamic>(storage.read('MyHydratedCubit')).called(2);
      });

      test('initial state should return 0 when deserialization fails', () {
        when<dynamic>(storage.read('MyHydratedCubit'))
            .thenThrow(Exception('oops'));
        expect(cubit.state, 0);
      });

      test('initial state should return 101 when fromJson returns 101', () {
        when<dynamic>(storage.read('MyHydratedCubit'))
            .thenReturn({'value': 101});
        expect(cubit.state, 101);
        verify<dynamic>(storage.read('MyHydratedCubit')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await cubit.clear();
          verify(storage.delete('MyHydratedCubit')).called(1);
        });
      });
    });

    group('MultiHydratedCubit', () {
      MyMultiHydratedCubit multiCubitA;
      MyMultiHydratedCubit multiCubitB;

      setUp(() {
        multiCubitA = MyMultiHydratedCubit('A');
        multiCubitB = MyMultiHydratedCubit('B');
      });

      test('initial state should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyMultiHydratedCubitA')).thenReturn(null);
        expect(multiCubitA.state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedCubitA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedCubitB')).thenReturn(null);
        expect(multiCubitB.state, 0);
        verify<dynamic>(storage.read('MyMultiHydratedCubitB')).called(2);
      });

      test('initial state should return 101/102 when fromJson returns 101/102',
          () {
        when<dynamic>(storage.read('MyMultiHydratedCubitA'))
            .thenReturn({'value': 101});
        expect(multiCubitA.state, 101);
        verify<dynamic>(storage.read('MyMultiHydratedCubitA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedCubitB'))
            .thenReturn({'value': 102});
        expect(multiCubitB.state, 102);
        verify<dynamic>(storage.read('MyMultiHydratedCubitB')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await multiCubitA.clear();
          verify(storage.delete('MyMultiHydratedCubitA')).called(1);
          verifyNever(storage.delete('MyMultiHydratedCubitB'));

          await multiCubitB.clear();
          verify(storage.delete('MyMultiHydratedCubitB')).called(1);
        });
      });
    });

    group('MyUuidHydratedCubit', () {
      test('stores initialState when instantiated', () {
        MyUuidHydratedCubit();
        verify<dynamic>(storage.write('MyUuidHydratedCubit', any)).called(1);
      });

      test('correctly caches computed initialState', () {
        dynamic cachedState;
        when<dynamic>(storage.write('MyUuidHydratedCubit', any))
            .thenReturn(null);
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
