import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/widgets.dart';

class MockStorage extends Mock implements HydratedBlocStorage {}

class MockHydratedBlocDelegate extends Mock implements HydratedBlocDelegate {}

class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {
  String get storageToken => '${runtimeType.toString()}$id';
}

class MyUuidHydratedBloc extends HydratedBloc<String, String> {
  @override
  String get initialState => super.initialState ?? Uuid().v4();

  @override
  Stream<String> mapEventToState(String event) async* {}

  @override
  Map<String, String> toJson(String state) => {'value': state};

  @override
  String fromJson(dynamic json) {
    try {
      return json['value'];
    } on dynamic catch (_) {
      // ignore: avoid_returning_null
      return null;
    }
  }
}

class MyHydratedBloc extends HydratedBloc<int, int> {
  MyHydratedBloc([this._id]);

  final String _id;

  @override
  String get id => _id;

  @override
  int get initialState => super.initialState ?? 0;

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
  final String _id;

  MyMultiHydratedBloc(String id) : _id = id;

  @override
  int get initialState => super.initialState ?? 0;

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
  final Function(Object error, StackTrace stackTrace) onErrorCallback;

  MyErrorThrowingBloc({this.onErrorCallback});

  @override
  int get initialState => super.initialState ?? 0;

  @override
  Stream<int> mapEventToState(Object event) async* {
    yield state + 1;
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    onErrorCallback?.call(error, stackTrace);
  }

  @override
  Map<String, dynamic> toJson(int state) {
    return {'key': Object};
  }

  @override
  int fromJson(dynamic json) {
    // ignore: avoid_returning_null
    return null;
  }
}

class MyHydratedBlocDelegate extends HydratedBlocDelegate {
  final Function(
    Bloc bloc,
    Object error,
    StackTrace stackTrace,
  ) onErrorCallback;

  MyHydratedBlocDelegate(
    HydratedStorage storage, {
    this.onErrorCallback,
  }) : super(storage);

  @override
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    onErrorCallback?.call(bloc, error, stackTrace);
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  group('HydratedBloc', () {
    MockHydratedBlocDelegate delegate;
    MockStorage storage;

    setUp(() {
      delegate = MockHydratedBlocDelegate();
      BlocSupervisor.delegate = delegate;
      storage = MockStorage();

      when(delegate.storage).thenReturn(storage);
    });

    group('SingleHydratedBloc', () {
      MyHydratedBloc bloc;

      setUp(() {
        bloc = MyHydratedBloc();
      });

      test('should call storage.write when onTransition is called', () {
        final transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        final expected = <String, int>{'value': 0};
        bloc.onTransition(transition);
        verify(
          storage.write('MyHydratedBloc', json.encode(expected)),
        ).called(2);
      });

      test('should call storage.write when onTransition is called with bloc id',
          () {
        final bloc = MyHydratedBloc('A');
        final transition = Transition(
          currentState: 0,
          event: 0,
          nextState: 0,
        );
        final expected = <String, int>{'value': 0};
        bloc.onTransition(transition);
        verify(
          storage.write('MyHydratedBlocA', json.encode(expected)),
        ).called(2);
      });

      test('should call onError when storage.write throws', () {
        runZoned(() {
          final expectedError = Exception('oops');
          final transition = Transition(
            currentState: 0,
            event: 0,
            nextState: 0,
          );
          when(storage.write(any, any)).thenThrow(expectedError);
          bloc.onTransition(transition);
          verify(bloc.onError(expectedError, any)).called(2);
        }, onError: (error) {
          expect(
            (error as BlocUnhandledErrorException).error.toString(),
            'Exception: oops',
          );
          expect((error as BlocUnhandledErrorException).stackTrace, isNotNull);
        });
      });

      test('stores initialState when instantiated', () {
        verify<dynamic>(
          storage.write('MyHydratedBloc', '{"value":0}'),
        ).called(1);
      });

      test('initialState should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyHydratedBloc')).thenReturn(null);
        expect(bloc.initialState, 0);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(2);
      });

      test('initialState should return 101 when fromJson returns 101', () {
        when<dynamic>(storage.read('MyHydratedBloc'))
            .thenReturn(json.encode({'value': 101}));
        expect(bloc.initialState, 101);
        verify<dynamic>(storage.read('MyHydratedBloc')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await bloc.clear();
          verify(storage.delete('MyHydratedBloc')).called(1);
        });
      });
    });

    group('MultiHydratedBloc', () {
      MyMultiHydratedBloc multiBlocA;
      MyMultiHydratedBloc multiBlocB;

      setUp(() {
        multiBlocA = MyMultiHydratedBloc('A');
        multiBlocB = MyMultiHydratedBloc('B');
      });

      test('initialState should return 0 when fromJson returns null', () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA')).thenReturn(null);
        expect(multiBlocA.initialState, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedBlocB')).thenReturn(null);
        expect(multiBlocB.initialState, 0);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(2);
      });

      test('initialState should return 101/102 when fromJson returns 101/102',
          () {
        when<dynamic>(storage.read('MyMultiHydratedBlocA'))
            .thenReturn(json.encode({'value': 101}));
        expect(multiBlocA.initialState, 101);
        verify<dynamic>(storage.read('MyMultiHydratedBlocA')).called(2);

        when<dynamic>(storage.read('MyMultiHydratedBlocB'))
            .thenReturn(json.encode({'value': 102}));
        expect(multiBlocB.initialState, 102);
        verify<dynamic>(storage.read('MyMultiHydratedBlocB')).called(2);
      });

      group('clear', () {
        test('calls delete on storage', () async {
          await multiBlocA.clear();
          verify(storage.delete('MyMultiHydratedBlocA')).called(1);
          verifyNever(storage.delete('MyMultiHydratedBlocB'));

          await multiBlocB.clear();
          verify(storage.delete('MyMultiHydratedBlocB')).called(1);
        });
      });
    });

    group('MyUuidHydratedBloc', () {
      test('stores initialState when instantiated', () {
        MyUuidHydratedBloc();
        verify<dynamic>(storage.write('MyUuidHydratedBloc', any)).called(1);
      });

      test('correctly caches computed initialState', () {
        String cachedState;
        when<dynamic>(storage.write('MyUuidHydratedBloc', any))
            .thenReturn(null);
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        cachedState = verify(storage.write('MyUuidHydratedBloc', captureAny))
            .captured
            .last;
        when<dynamic>(storage.read('MyUuidHydratedBloc'))
            .thenReturn(cachedState);
        MyUuidHydratedBloc();
        final initialStateB =
            verify(storage.write('MyUuidHydratedBloc', captureAny))
                .captured
                .last;
        expect(initialStateB, cachedState);
      });
    });

    group('MyErrorThrowingBloc', () {
      test('continues to emit new states when serialization fails', () async {
        runZoned(() async {
          final bloc = MyErrorThrowingBloc();
          final expectedStates = [0, 1, emitsDone];
          expectLater(
            bloc,
            emitsInOrder(expectedStates),
          );
          bloc.add(Object);
          await bloc.close();
        }, onError: (_) {});
      });

      test('calls onError when json decode fails', () async {
        runZoned(() async {
          Object lastError;
          StackTrace lastStackTrace;
          when(storage.read(any)).thenReturn('invalid json');
          final bloc = MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
          bloc.add(Object);
          await bloc.close();
          expect(
            '$lastError',
            'Converting object to an encodable object failed: Object',
          );
          expect(lastStackTrace, isNotNull);
          verify(delegate.onError(bloc, lastError, lastStackTrace)).called(1);
        }, onError: (_) {});
      });

      test('calls onError when json encode fails', () async {
        runZoned(() async {
          Object lastError;
          StackTrace lastStackTrace;
          final bloc = MyErrorThrowingBloc(
            onErrorCallback: (error, stackTrace) {
              lastError = error;
              lastStackTrace = stackTrace;
            },
          );
          bloc.add(Object);
          await bloc.close();
          expect(
            '$lastError',
            'Converting object to an encodable object failed: Object',
          );
          expect(lastStackTrace, isNotNull);
          verify(delegate.onError(bloc, lastError, lastStackTrace)).called(1);
        }, onError: (_) {});
      });
    });
  });
}
