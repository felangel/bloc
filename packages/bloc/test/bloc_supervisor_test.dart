import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';

class MockBlocDelegate extends Mock implements BlocDelegate {}

void main() {
  test('BlocSupervisor should have a default BlocDelegate singleton', () {
    expect(BlocSupervisor.delegate, isNotNull);
    expect(BlocSupervisor.delegate is BlocDelegate, isTrue);
  });

  test(
      'BlocSupervisor should have a correct BlocDelegate singleton '
      'when explicity set', () {
    final delegate = MockBlocDelegate();
    BlocSupervisor.delegate = delegate;
    expect(BlocSupervisor.delegate, delegate);
  });

  test(
      'BlocSupervisor should use default BlocDelegate singleton '
      'when explicity set to null', () {
    BlocSupervisor.delegate = null;
    expect(BlocSupervisor.delegate, isNotNull);
  });
}
