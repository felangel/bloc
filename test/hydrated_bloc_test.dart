import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:bloc/bloc.dart';

class MockStorage extends Mock implements HydratedBlocStorage {}

class MockHydratedBlocDelegate extends Mock implements HydratedBlocDelegate {}

class MyHydratedBloc extends HydratedBloc<int, int> {
  @override
  int get initialState => super.initialState ?? null;

  @override
  Stream<int> mapEventToState(int event) {
    return null;
  }

  @override
  String toJson(int state) {
    return state.toString();
  }

  @override
  int fromJson(String json) {
    try {
      return int.tryParse(json);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  MyHydratedBloc bloc;
  MockHydratedBlocDelegate delegate;
  MockStorage storage;

  setUp(() {
    delegate = MockHydratedBlocDelegate();
    BlocSupervisor.delegate = delegate;
    storage = MockStorage();

    when(delegate.storage).thenReturn(storage);

    bloc = MyHydratedBloc();
  });

  group('HydratedBloc', () {
    test('initialState should return null when fromJson returns null', () {
      when(storage.read('MyHydratedBloc')).thenReturn(null);
      expect(bloc.initialState, isNull);
      verify(storage.read('MyHydratedBloc')).called(2);
    });

    test('initialState should return 101 when fromJson returns "101"', () {
      when(storage.read('MyHydratedBloc')).thenReturn('101');
      expect(bloc.initialState, 101);
      verify(storage.read('MyHydratedBloc')).called(2);
    });
  });
}
