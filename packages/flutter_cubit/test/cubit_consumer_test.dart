import 'package:cubit/cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit() : super(0);

  void increment() => emit(state + 1);
}

void main() {
  group('CubitConsumer', () {
    testWidgets('throws AssertionError if builder is null', (tester) async {
      try {
        await tester.pumpWidget(
          CubitConsumer<CounterCubit, int>(
            builder: null,
            listener: (_, __) {},
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws AssertionError if listener is null', (tester) async {
      try {
        await tester.pumpWidget(
          CubitConsumer<CounterCubit, int>(
            builder: (_, __) => const SizedBox(),
            listener: null,
          ),
        );
      } on dynamic catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets(
        'accesses the cubit directly and passes initial state to builder and '
        'nothing to listener', (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CubitConsumer<CounterCubit, int>(
              cubit: counterCubit,
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
        'accesses the cubit directly '
        'and passes multiple states to builder and listener', (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CubitConsumer<CounterCubit, int>(
              cubit: counterCubit,
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
        'accesses the cubit via context and passes initial state to builder',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        CubitProvider<CounterCubit>.value(
          value: counterCubit,
          child: MaterialApp(
            home: Scaffold(
              body: CubitConsumer<CounterCubit, int>(
                cubit: counterCubit,
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
        'accesses the cubit via context and passes multiple states to builder',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CubitConsumer<CounterCubit, int>(
              cubit: counterCubit,
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
            body: CubitConsumer<CounterCubit, int>(
              cubit: counterCubit,
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

    testWidgets('does not trigger listen when listenWhen evaluates to false',
        (tester) async {
      final counterCubit = CounterCubit();
      final listenerStates = <int>[];
      final builderStates = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CubitConsumer<CounterCubit, int>(
              cubit: counterCubit,
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
  });
}
