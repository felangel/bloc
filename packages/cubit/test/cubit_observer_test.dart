import 'package:cubit/cubit.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockCubit extends Mock implements Cubit<int> {}

// ignore: must_be_immutable
class MockTransition extends Mock implements Transition<int> {}

void main() {
  group('CubitObserver', () {
    group('onTransition', () {
      test('does nothing by default', () {
        CubitObserver().onTransition(MockCubit(), MockTransition());
      });
    });
  });
}
