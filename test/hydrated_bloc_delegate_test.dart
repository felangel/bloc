import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

class MockBloc extends Mock implements HydratedBloc<dynamic, dynamic> {}

class MockStorage extends Mock implements HydratedBlocStorage {}

void main() {
  MockStorage storage;
  HydratedBlocDelegate delegate;
  MockBloc bloc;

  setUp(() {
    storage = MockStorage();
    delegate = HydratedBlocDelegate(storage);
    bloc = MockBloc();
  });

  test('call storage.write when onTransition is called', () {
    final transition = Transition(
      currentState: 'currentState',
      event: 'event',
      nextState: 'nextState',
    );
    when(bloc.toJson('nextState')).thenReturn('nextStateJson');
    delegate.onTransition(bloc, transition);
    verify(storage.write('MockBloc', 'nextStateJson')).called(1);
  });
}
