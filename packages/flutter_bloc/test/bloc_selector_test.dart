import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);
}

void main() {
  group('BlocSelector', () {
    testWidgets('renders with correct state', (tester) async {
      final counterCubit = CounterCubit();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocSelector<CounterCubit, int, bool>(
            bloc: counterCubit,
            selector: (state) => state % 2 == 0,
            builder: (context, state) {
              builderCallCount++;
              return Text('isEven: $state');
            },
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });

    testWidgets('only rebuilds when selected state changes', (tester) async {
      final counterCubit = CounterCubit();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocSelector<CounterCubit, int, bool>(
            bloc: counterCubit,
            selector: (state) => state == 1,
            builder: (context, state) {
              builderCallCount++;
              return Text('equals 1: $state');
            },
          ),
        ),
      );

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(1));

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: true'), findsOneWidget);
      expect(builderCallCount, equals(2));

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('equals 1: false'), findsOneWidget);
      expect(builderCallCount, equals(3));
    });

    testWidgets('infers bloc from context', (tester) async {
      final counterCubit = CounterCubit();
      var builderCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: counterCubit,
            child: BlocSelector<CounterCubit, int, bool>(
              selector: (state) => state % 2 == 0,
              builder: (context, state) {
                builderCallCount++;
                return Text('isEven: $state');
              },
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(builderCallCount, equals(1));
    });

    testWidgets('rebuilds when provided bloc is changed', (tester) async {
      final firstCounterCubit = CounterCubit();
      final secondCounterCubit = CounterCubit(seed: 100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: firstCounterCubit,
            child: BlocSelector<CounterCubit, int, bool>(
              selector: (state) => state % 2 == 0,
              builder: (context, state) => Text('isEven: $state'),
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);

      firstCounterCubit.increment();
      await tester.pumpAndSettle();
      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: secondCounterCubit,
            child: BlocSelector<CounterCubit, int, bool>(
              selector: (state) => state % 2 == 0,
              builder: (context, state) => Text('isEven: $state'),
            ),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.text('isEven: false'), findsNothing);

      secondCounterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);
    });

    testWidgets('rebuilds when bloc is changed at runtime', (tester) async {
      final firstCounterCubit = CounterCubit();
      final secondCounterCubit = CounterCubit(seed: 100);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocSelector<CounterCubit, int, bool>(
            bloc: firstCounterCubit,
            selector: (state) => state % 2 == 0,
            builder: (context, state) => Text('isEven: $state'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);

      firstCounterCubit.increment();
      await tester.pumpAndSettle();
      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocSelector<CounterCubit, int, bool>(
            bloc: secondCounterCubit,
            selector: (state) => state % 2 == 0,
            builder: (context, state) => Text('isEven: $state'),
          ),
        ),
      );

      expect(find.text('isEven: true'), findsOneWidget);
      expect(find.text('isEven: false'), findsNothing);

      secondCounterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('isEven: false'), findsOneWidget);
      expect(find.text('isEven: true'), findsNothing);
    });

    testWidgets(
        'with selectWhen only rebuilds when selectWhen evaluates to true',
        (tester) async {
      final counterCubit = CounterCubit();
      var builderCallCount = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: counterCubit,
            child: BlocSelector<CounterCubit, int, int>(
              selector: (state) => state,
              selectWhen: ((_, current) => current % 2 == 0),
              builder: (context, state) {
                builderCallCount++;
                return Text('count: $state');
              },
            ),
          ),
        ),
      );

      expect(find.text('count: 0'), findsOneWidget);
      expect(builderCallCount, equals(1));

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('count: 0'), findsOneWidget);
      expect(builderCallCount, equals(1));

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('count: 2'), findsOneWidget);
      expect(builderCallCount, equals(2));
    });

    testWidgets('calls selectWhen and builder with correct state',
        (tester) async {
      final buildWhenPreviousState = <int>[];
      final buildWhenCurrentState = <int>[];
      final states = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        BlocSelector<CounterCubit, int, int>(
          bloc: counterCubit,
          selector: (state) => state,
          selectWhen: (previous, state) {
            if (state % 2 == 0) {
              buildWhenPreviousState.add(previous);
              buildWhenCurrentState.add(state);
              return true;
            }
            return false;
          },
          builder: (_, state) {
            states.add(state);
            return const SizedBox();
          },
        ),
      );
      await tester.pump();
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pumpAndSettle();

      expect(states, [0, 2]);
      expect(buildWhenPreviousState, [1]);
      expect(buildWhenCurrentState, [2]);
    });

    testWidgets(
        'does not rebuild with latest state when '
        'selectWhen is false and widget is updated', (tester) async {
      const key = Key('__target__');
      final states = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: StatefulBuilder(
            builder: (context, setState) =>
                BlocSelector<CounterCubit, int, int>(
              bloc: counterCubit,
              selector: (state) => state,
              selectWhen: (previous, state) => state % 2 == 0,
              builder: (_, state) {
                states.add(state);
                return ElevatedButton(
                  key: key,
                  child: const SizedBox(),
                  onPressed: () => setState(() {}),
                );
              },
            ),
          ),
        ),
      );
      await tester.pump();
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pumpAndSettle();
      expect(states, [0, 2]);

      await tester.tap(find.byKey(key));
      await tester.pumpAndSettle();
      expect(states, [0, 2, 2]);
    });
  });
}
