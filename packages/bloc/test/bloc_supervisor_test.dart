import 'package:test/test.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc/bloc.dart';

class MockBlocDelegate extends Mock implements BlocDelegate {}

void main() {
  test('BlocSupervisor should be a singleton', () {
    final MockBlocDelegate delegate = MockBlocDelegate();
    final BlocSupervisor supervisorA = BlocSupervisor();
    final BlocSupervisor supervisorB = BlocSupervisor();

    supervisorA.delegate = delegate;

    expect(supervisorA.delegate, supervisorB.delegate);
  });
}
