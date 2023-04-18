import 'package:bloc_test/bloc_test.dart';
import 'package:test/test.dart';

import 'blocs/blocs.dart';

void main() {
  fakeAsyncBlocTest<ErrorCounterBloc, int>(
    'emits [1] and throws ErrorCounterBlocError '
    'when increment is added',
    build: () => ErrorCounterBloc(),
    act: (bloc, fakeAsync) => throw ErrorCounterBlocError(),
    errors: () => [isA<ErrorCounterBlocError>()],
  );
}
