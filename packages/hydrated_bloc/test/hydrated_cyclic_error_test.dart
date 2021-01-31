import 'package:test/test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

void main() {
  group('HydratedCyclicError', () {
    test('toString override is correct', () {
      expect(
        HydratedCyclicError(<String, dynamic>{}).toString(),
        'Cyclic error while state traversing',
      );
    });
  });
}
