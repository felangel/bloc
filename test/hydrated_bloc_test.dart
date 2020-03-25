import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';
import 'package:uuid/uuid.dart';

class MockStorage extends Mock implements HydratedBlocStorage {}

class MockHydratedBlocDelegate extends Mock implements HydratedBlocDelegate {}

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

void main() {
  MockHydratedBlocDelegate delegate;
  MockStorage storage;

  setUp(() {
    delegate = MockHydratedBlocDelegate();
    BlocSupervisor.delegate = delegate;
    storage = MockStorage();

    when(delegate.storage).thenReturn(storage);
  });

  group('HydratedBloc', () {
    MyHydratedBloc bloc;

    setUp(() {
      bloc = MyHydratedBloc();
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
      when<dynamic>(storage.write('MyUuidHydratedBloc', any)).thenReturn(null);
      when<dynamic>(storage.read('MyUuidHydratedBloc')).thenReturn(cachedState);
      MyUuidHydratedBloc();
      cachedState =
          verify(storage.write('MyUuidHydratedBloc', captureAny)).captured.last;
      when<dynamic>(storage.read('MyUuidHydratedBloc')).thenReturn(cachedState);
      MyUuidHydratedBloc();
      final initialStateB =
          verify(storage.write('MyUuidHydratedBloc', captureAny)).captured.last;
      expect(initialStateB, cachedState);
    });
  });
}
