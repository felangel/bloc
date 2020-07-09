import 'package:cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

void main() {
  group('MultiCubitListener', () {
    testWidgets('throws if initialized with no listeners and no child',
        (tester) async {
      try {
        await tester.pumpWidget(
          MultiCubitListener(listeners: null, child: null),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no listeners', (tester) async {
      try {
        await tester.pumpWidget(
          MultiCubitListener(listeners: null, child: const SizedBox()),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child', (tester) async {
      try {
        await tester.pumpWidget(
          MultiCubitListener(listeners: [], child: null),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('calls listeners on state changes', (tester) async {
      final statesA = <int>[];
      const expectedStatesA = [1, 2];
      final counterCubitA = CounterCubit();

      final statesB = <int>[];
      final expectedStatesB = [1];
      final counterCubitB = CounterCubit();

      await tester.pumpWidget(
        MultiCubitListener(
          listeners: [
            CubitListener<CounterCubit, int>(
              cubit: counterCubitA,
              listener: (context, state) => statesA.add(state),
            ),
            CubitListener<CounterCubit, int>(
              cubit: counterCubitB,
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
        MultiCubitListener(
          listeners: [
            CubitListener(
              cubit: counterCubitA,
              listener: (BuildContext context, int state) => statesA.add(state),
            ),
            CubitListener(
              cubit: counterCubitB,
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
