import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);
}

void main() {
  group('BlocConsumer', () {
    testWidgets(
        'accesses the bloc directly and passes initial state to builder and '
        'nothing to listener', (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the bloc directly '
        'and passes multiple states to builder and listener', (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterCubit.increment();
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets(
        'accesses the bloc via context and passes initial state to builder',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        BlocProvider<CounterCubit>.value(
          value: counterCubit,
          child: MaterialApp(
            home: Scaffold(
              body: BlocConsumer<CounterCubit, int>(
                bloc: counterCubit,
                builder: (context, state) {
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
    });

    testWidgets(
        'accesses the bloc via context and passes multiple states to builder',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              builder: (context, state) {
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(listenerStates, isEmpty);
      counterCubit.increment();
      await tester.pump();
      expect(find.text('State: 1'), findsOneWidget);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger rebuilds when buildWhen evaluates to false',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              buildWhen: (previous, current) => (previous + current) % 3 == 0,
              builder: (context, state) {
                builderStates.add(state);
                return Text('State: $state');
              },
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });

    testWidgets(
        'does not trigger rebuilds when '
        'buildWhen evaluates to false (inferred bloc)', (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: counterCubit,
              child: BlocConsumer<CounterCubit, int>(
                buildWhen: (previous, current) => (previous + current) % 3 == 0,
                builder: (context, state) {
                  builderStates.add(state);
                  return Text('State: $state');
                },
                listener: (_, state) {
                  listenerStates.add(state);
                },
              ),
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pump();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, [1]);

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 2]);
      expect(listenerStates, [1, 2]);
    });

    testWidgets('updates when cubit/bloc reference has changed',
        (tester) async {
      const buttonKey = Key('__button__');
      var counterCubit = CounterCubit();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return BlocConsumer<CounterCubit, int>(
                  bloc: counterCubit,
                  builder: (context, state) {
                    builderStates.add(state);
                    return TextButton(
                      key: buttonKey,
                      onPressed: () => setState(() {}),
                      child: Text('State: $state'),
                    );
                  },
                  listener: (_, state) {
                    listenerStates.add(state);
                  },
                );
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(builderStates, [0, 1]);
      expect(listenerStates, [1]);

      counterCubit = CounterCubit();
      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0, 1, 0]);
      expect(listenerStates, [1]);
    });

    testWidgets('does not trigger listen when listenWhen evaluates to false',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocConsumer<CounterCubit, int>(
              bloc: counterCubit,
              builder: (context, state) {
                builderStates.add(state);
                return Text('State: $state');
              },
              listenWhen: (previous, current) => (previous + current) % 3 == 0,
              listener: (_, state) {
                listenerStates.add(state);
              },
            ),
          ),
        ),
      );
      expect(find.text('State: 0'), findsOneWidget);
      expect(builderStates, [0]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pump();

      expect(find.text('State: 1'), findsOneWidget);
      expect(builderStates, [0, 1]);
      expect(listenerStates, isEmpty);

      counterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('State: 2'), findsOneWidget);
      expect(builderStates, [0, 1, 2]);
      expect(listenerStates, [2]);
    });

    testWidgets(
        'calls buildWhen/listenWhen and builder/listener with correct states',
        (tester) async {
      final buildWhenPreviousState = <int>[];
      final buildWhenCurrentState = <int>[];
      final buildStates = <int>[];
      final listenWhenPreviousState = <int>[];
      final listenWhenCurrentState = <int>[];
      final listenStates = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        BlocConsumer<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (previous, current) {
            if (current % 3 == 0) {
              listenWhenPreviousState.add(previous);
              listenWhenCurrentState.add(current);
              return true;
            }
            return false;
          },
          listener: (_, state) {
            listenStates.add(state);
          },
          buildWhen: (previous, current) {
            if (current.isEven) {
              buildWhenPreviousState.add(previous);
              buildWhenCurrentState.add(current);
              return true;
            }
            return false;
          },
          builder: (_, state) {
            buildStates.add(state);
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

      expect(buildStates, [0, 2]);
      expect(buildWhenPreviousState, [1]);
      expect(buildWhenCurrentState, [2]);

      expect(listenStates, [3]);
      expect(listenWhenPreviousState, [2]);
      expect(listenWhenCurrentState, [3]);
    });

    testWidgets(
        'rebuilds and updates subscription '
        'when provided bloc is changed', (tester) async {
      final firstCounterCubit = CounterCubit();
      final secondCounterCubit = CounterCubit(seed: 100);

      final states = <int>[];
      const expectedStates = [1, 101];

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: firstCounterCubit,
            child: BlocConsumer<CounterCubit, int>(
              listener: (_, state) => states.add(state),
              builder: (context, state) => Text('Count $state'),
            ),
          ),
        ),
      );

      expect(find.text('Count 0'), findsOneWidget);

      firstCounterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 1'), findsOneWidget);
      expect(find.text('Count 0'), findsNothing);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: BlocProvider.value(
            value: secondCounterCubit,
            child: BlocConsumer<CounterCubit, int>(
              listener: (_, state) => states.add(state),
              builder: (context, state) => Text('Count $state'),
            ),
          ),
        ),
      );

      expect(find.text('Count 100'), findsOneWidget);
      expect(find.text('Count 1'), findsNothing);

      secondCounterCubit.increment();
      await tester.pumpAndSettle();

      expect(find.text('Count 101'), findsOneWidget);
      expect(states, expectedStates);
    });
  });
}
