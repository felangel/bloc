import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

void main() {
  group('MultiBlocListener', () {
    testWidgets('calls listeners on state changes', (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterCubitA = CounterCubit();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterCubitB = CounterCubit();

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener<CounterCubit, int>(
              bloc: counterCubitA,
              listener: (context, state) => statesA.add(state),
            ),
            BlocListener<CounterCubit, int>(
              bloc: counterCubitB,
              listener: (context, state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiCubitListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiCubitListener_child')), findsOneWidget);

      counterCubitA.increment();
      await tester.pump();
      counterCubitA.increment();
      await tester.pump();
      counterCubitB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });

    testWidgets('calls listeners on state changes without explicit types',
        (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterCubitA = CounterCubit();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterCubitB = CounterCubit();

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener(
              bloc: counterCubitA,
              listener: (BuildContext context, int state) => statesA.add(state),
            ),
            BlocListener(
              bloc: counterCubitB,
              listener: (BuildContext context, int state) => statesB.add(state),
            ),
          ],
          child: const SizedBox(key: Key('multiCubitListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiCubitListener_child')), findsOneWidget);

      counterCubitA.increment();
      await tester.pump();
      counterCubitA.increment();
      await tester.pump();
      counterCubitB.increment();
      await tester.pump();

      expect(statesA, expectedStatesA);
      expect(statesB, expectedStatesB);
    });
  });
}
