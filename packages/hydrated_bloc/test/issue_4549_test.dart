// Test for issue #4549: HydratedMixin causes BlocBase to emit the same state
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:test/test.dart';

class CounterCubit extends Cubit<int> with HydratedMixin {
  CounterCubit() : super(0) {
    hydrate();
  }

  void setToFive() {
    emit(5);
  }

  @override
  int? fromJson(Map<String, dynamic> json) {
    return 5;
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return {'state': 5};
  }
}

class MyHydratedStorage implements Storage {
  @override
  dynamic read(String key) {
    return {'state': 5}; // Always return state 5
  }

  @override
  Future<void> write(String key, dynamic value) async {}

  @override
  Future<void> delete(String key) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<void> close() async {}
}

void main() {
  group('Issue #4549', () {
    test('should not emit same state after hydration', () async {
      HydratedBloc.storage = MyHydratedStorage();

      final emissions = <int>[];
      final cubit = CounterCubit();

      // Listen to the stream
      cubit.stream.listen(emissions.add);

      // After hydration, state should be 5
      expect(cubit.state, 5);

      // Try to emit the same state (5)
      cubit.setToFive();

      // Give time for the stream to emit
      await Future<void>.delayed(Duration.zero);

      // Nothing should be emitted because state is already 5
      // This test will FAIL before the fix, showing the bug exists
      expect(
        emissions,
        isEmpty,
        reason: 'Should not emit duplicate state after hydration',
      );
    });
  });
}
