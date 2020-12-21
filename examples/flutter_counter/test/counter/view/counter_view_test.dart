// ignore: import_of_legacy_library_into_null_safe
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_counter/counter/counter.dart';
import 'package:flutter_counter/counter/view/counter_view.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:mockito/mockito.dart';

class MockCounterCubit extends MockBloc<int> implements CounterCubit {}

const _incrementButtonKey = Key('counterView_increment_floatingActionButton');
const _decrementButtonKey = Key('counterView_decrement_floatingActionButton');

void main() {
  late CounterCubit counterCubit;

  setUp(() {
    counterCubit = MockCounterCubit();
    when(counterCubit.state).thenReturn(0);
    whenListen(counterCubit, Stream.value(0));
  });

  group('CounterView', () {
    testWidgets('renders current CounterCubit state', (tester) async {
      when(counterCubit.state).thenReturn(42);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: counterCubit,
            child: CounterView(),
          ),
        ),
      );
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('tapping increment button invokes increment', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: counterCubit,
            child: CounterView(),
          ),
        ),
      );
      await tester.tap(find.byKey(_incrementButtonKey));
      verify(counterCubit.increment()).called(1);
    });

    testWidgets('tapping decrement button invokes decrement', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: counterCubit,
            child: CounterView(),
          ),
        ),
      );
      final decrementFinder = find.byKey(_decrementButtonKey);
      await tester.ensureVisible(decrementFinder);
      await tester.tap(decrementFinder);
      verify(counterCubit.decrement()).called(1);
    });
  });
}
