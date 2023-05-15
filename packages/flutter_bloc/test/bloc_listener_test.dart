import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class CounterCubit extends Cubit<int> {
  CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key, this.onListenerCalled}) : super(key: key);

  final BlocWidgetListener<int>? onListenerCalled;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late CounterCubit _counterCubit;

  @override
  void initState() {
    super.initState();
    _counterCubit = CounterCubit();
  }

  @override
  void dispose() {
    _counterCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: BlocListener<CounterCubit, int>(
          bloc: _counterCubit,
          listener: (context, state) {
            widget.onListenerCalled?.call(context, state);
          },
          child: Column(
            children: [
              ElevatedButton(
                key: const Key('cubit_listener_reset_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _counterCubit = CounterCubit());
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_noop_button'),
                child: const SizedBox(),
                onPressed: () {
                  setState(() => _counterCubit = _counterCubit);
                },
              ),
              ElevatedButton(
                key: const Key('cubit_listener_increment_button'),
                child: const SizedBox(),
                onPressed: () => _counterCubit.increment(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  group('BlocListener', () {
    testWidgets(
        'throws AssertionError '
        'when child is not specified', (tester) async {
      const expected =
          '''BlocListener<CounterCubit, int> used outside of MultiBlocListener must specify a child''';
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: CounterCubit(),
          listener: (context, state) {},
        ),
      );
      expect(
        tester.takeException(),
        isA<AssertionError>().having((e) => e.message, 'message', expected),
      );
    });

    testWidgets('renders child properly', (tester) async {
      const targetKey = Key('cubit_listener_container');
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: CounterCubit(),
          listener: (_, __) {},
          child: const SizedBox(key: targetKey),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('calls listener on single state change', (tester) async {
      final counterCubit = CounterCubit();
      final states = <int>[];
      const expectedStates = [1];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listener: (_, state) {
            states.add(state);
          },
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets('calls listener on multiple state change', (tester) async {
      final counterCubit = CounterCubit();
      final states = <int>[];
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listener: (_, state) {
            states.add(state);
          },
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      expect(states, expectedStates);
    });

    testWidgets(
        'updates when the cubit is changed at runtime to a different cubit '
        'and unsubscribes from old cubit', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('cubit_listener_increment_button'),
      );
      final resetCubitFinder = find.byKey(
        const Key('cubit_listener_reset_button'),
      );
      await tester.pumpWidget(
        MyApp(
          onListenerCalled: (_, state) {
            listenerCallCount++;
            latestState = state;
          },
        ),
      );

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(resetCubitFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 1);
    });

    testWidgets(
        'does not update when the cubit is changed at runtime to same cubit '
        'and stays subscribed to current cubit', (tester) async {
      var listenerCallCount = 0;
      int? latestState;
      final incrementFinder = find.byKey(
        const Key('cubit_listener_increment_button'),
      );
      final noopCubitFinder = find.byKey(
        const Key('cubit_listener_noop_button'),
      );
      await tester.pumpWidget(
        MyApp(
          onListenerCalled: (context, state) {
            listenerCallCount++;
            latestState = state;
          },
        ),
      );

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 1);
      expect(latestState, 1);

      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 2);
      expect(latestState, 2);

      await tester.tap(noopCubitFinder);
      await tester.pump();
      await tester.tap(incrementFinder);
      await tester.pump();
      expect(listenerCallCount, 3);
      expect(latestState, 3);
    });

    testWidgets(
        'calls listenWhen on single state change with correct previous '
        'and current states', (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [1];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            latestPreviousState = previous;
            states.add(state);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen with previous listener state and current cubit state',
        (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [2];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            if ((previous + state) % 3 == 0) {
              latestPreviousState = previous;
              states.add(state);
              return true;
            }
            return false;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 3);
      expect(latestPreviousState, 1);
    });

    testWidgets('calls listenWhen and listener with correct state',
        (tester) async {
      final listenWhenPreviousState = <int>[];
      final listenWhenCurrentState = <int>[];
      final states = <int>[];
      final counterCubit = CounterCubit();
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (previous, current) {
            if (current % 3 == 0) {
              listenWhenPreviousState.add(previous);
              listenWhenCurrentState.add(current);
              return true;
            }
            return false;
          },
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterCubit
        ..increment()
        ..increment()
        ..increment();
      await tester.pump();

      expect(states, [3]);
      expect(listenWhenPreviousState, [2]);
      expect(listenWhenCurrentState, [3]);
    });

    testWidgets(
        'infers the cubit from the context if the cubit is not provided',
        (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [1];
      await tester.pumpWidget(
        BlocProvider.value(
          value: counterCubit,
          child: BlocListener<CounterCubit, int>(
            listenWhen: (previous, state) {
              listenWhenCallCount++;
              latestPreviousState = previous;
              states.add(state);
              return true;
            },
            listener: (context, state) {},
            child: const SizedBox(),
          ),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 1);
      expect(latestPreviousState, 0);
    });

    testWidgets(
        'calls listenWhen on multiple state change with correct previous '
        'and current states', (tester) async {
      int? latestPreviousState;
      var listenWhenCallCount = 0;
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [1, 2];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (previous, state) {
            listenWhenCallCount++;
            latestPreviousState = previous;
            states.add(state);
            return true;
          },
          listener: (_, __) {},
          child: const SizedBox(),
        ),
      );
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
      expect(listenWhenCallCount, 2);
      expect(latestPreviousState, 1);
    });

    testWidgets(
        'does not call listener when listenWhen returns false on single state '
        'change', (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (_, __) => false,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on single state change',
        (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [1];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (_, __) => true,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'does not call listener when listenWhen returns false '
        'on multiple state changes', (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = <int>[];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (_, __) => false,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'calls listener when listenWhen returns true on multiple state change',
        (tester) async {
      final states = <int>[];
      final counterCubit = CounterCubit();
      const expectedStates = [1, 2, 3, 4];
      await tester.pumpWidget(
        BlocListener<CounterCubit, int>(
          bloc: counterCubit,
          listenWhen: (_, __) => true,
          listener: (_, state) => states.add(state),
          child: const SizedBox(),
        ),
      );
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();
      counterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });

    testWidgets(
        'updates subscription '
        'when provided bloc is changed', (tester) async {
      final firstCounterCubit = CounterCubit();
      final secondCounterCubit = CounterCubit(seed: 100);

      final states = <int>[];
      const expectedStates = [1, 101];

      await tester.pumpWidget(
        BlocProvider.value(
          value: firstCounterCubit,
          child: BlocListener<CounterCubit, int>(
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      firstCounterCubit.increment();

      await tester.pumpWidget(
        BlocProvider.value(
          value: secondCounterCubit,
          child: BlocListener<CounterCubit, int>(
            listener: (_, state) => states.add(state),
            child: const SizedBox(),
          ),
        ),
      );

      secondCounterCubit.increment();
      await tester.pump();
      firstCounterCubit.increment();
      await tester.pump();

      expect(states, expectedStates);
    });
  });
}
