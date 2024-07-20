import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterCubit extends Cubit<int> {
  _CounterCubit({int seed = 0}) : super(seed);

  void increment() => emit(state + 1);
}

class _MutableCubit {
  _MutableCubit(this.count);

  int count;
}

void main() {
  group(
    'BlocMuteSelector',
    () {
      testWidgets('should renders with correct state', (tester) async {
        final counterCubit = _CounterCubit();
        var builderCallCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
              bloc: counterCubit,
              muteOrCopy: (prev, currentState) {
                prev.count = currentState;
                return;
              },
              create: (state) {
                return _MutableCubit(state);
              },
              builder: (context, state) {
                builderCallCount++;

                return Text('count: ${state.count}');
              },
            ),
          ),
        );

        expect(find.text('count: 0'), findsOneWidget);
        expect(builderCallCount, equals(1));
      });

      testWidgets('should renders with the same (mutated) reference',
          (tester) async {
        final counterCubit = _CounterCubit();
        final mutableCubit = _MutableCubit(counterCubit.state);
        var builderCallCount = 0;
        var builderMutableCubit = mutableCubit;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
              bloc: counterCubit,
              muteOrCopy: (prev, currentState) {
                prev.count = currentState;
                return;
              },
              create: (state) {
                return mutableCubit;
              },
              builder: (context, state) {
                builderCallCount++;
                builderMutableCubit = state;
                return Text('count: ${state.count}');
              },
            ),
          ),
        );

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(find.text('count: 1'), findsOneWidget);
        expect(builderCallCount, equals(2));
        expect(mutableCubit, builderMutableCubit);

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(find.text('count: 2'), findsOneWidget);
        expect(builderCallCount, equals(3));
        expect(mutableCubit, builderMutableCubit);
      });

      testWidgets('should mute only when muteWhen is true', (tester) async {
        final counterCubit = _CounterCubit();
        final mutableCubit = _MutableCubit(counterCubit.state);
        var builderCallCount = 0;
        var builderMutableCubit = mutableCubit;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
              bloc: counterCubit,
              muteOrCopy: (prev, currentState) {
                prev.count = currentState;
                return;
              },
              create: (state) {
                return mutableCubit;
              },
              muteWhen: (previous, current) => current.isEven,
              builder: (context, state) {
                builderCallCount++;
                builderMutableCubit = state;
                return Text('count: ${state.count}');
              },
            ),
          ),
        );

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(find.text('count: 0'), findsOneWidget);
        expect(builderCallCount, equals(1));
        expect(mutableCubit, builderMutableCubit);

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(find.text('count: 2'), findsOneWidget);
        expect(builderCallCount, equals(2));
        expect(mutableCubit, builderMutableCubit);
      });

      testWidgets('should copy if muteOrCopy return a not null value',
          (tester) async {
        final counterCubit = _CounterCubit();
        final mutableCubit = _MutableCubit(counterCubit.state);
        var builderMutableCubit = mutableCubit;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
              bloc: counterCubit,
              muteOrCopy: (prev, currentState) {
                return _MutableCubit(currentState);
              },
              create: (state) {
                return mutableCubit;
              },
              builder: (context, state) {
                builderMutableCubit = state;
                return Text('count: ${state.count}');
              },
            ),
          ),
        );

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(mutableCubit, isNot(builderMutableCubit));

        counterCubit.increment();
        await tester.pumpAndSettle();

        expect(mutableCubit, isNot(builderMutableCubit));
      });

      testWidgets('should infers bloc from context', (tester) async {
        final counterCubit = _CounterCubit();
        final mutableCubit = _MutableCubit(counterCubit.state);
        var builderCallCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: BlocProvider.value(
              value: counterCubit,
              child: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
                bloc: counterCubit,
                muteOrCopy: (prev, currentState) {
                  return _MutableCubit(currentState);
                },
                create: (state) {
                  return mutableCubit;
                },
                builder: (context, state) {
                  builderCallCount++;
                  return Text('count: ${state.count}');
                },
              ),
            ),
          ),
        );

        expect(find.text('count: 0'), findsOneWidget);
        expect(builderCallCount, equals(1));
      });

      testWidgets('should create when provided bloc is changed',
          (tester) async {
        final firstCounterCubit = _CounterCubit();
        final secondCounterCubit = _CounterCubit(seed: 100);
        var createCallCount = 0;

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BlocProvider.value(
              value: firstCounterCubit,
              child: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
                muteOrCopy: (prev, currentState) {
                  return _MutableCubit(currentState);
                },
                create: (state) {
                  createCallCount++;
                  return _MutableCubit(state);
                },
                builder: (context, state) {
                  return Text('count: ${state.count}');
                },
              ),
            ),
          ),
        );

        expect(find.text('count: 0'), findsOneWidget);
        expect(createCallCount, equals(1));

        firstCounterCubit.increment();
        await tester.pumpAndSettle();
        expect(find.text('count: 1'), findsOneWidget);
        expect(find.text('count: 0'), findsNothing);
        expect(createCallCount, equals(1));

        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: BlocProvider.value(
              value: secondCounterCubit,
              child: BlocMuteSelector<_CounterCubit, int, _MutableCubit>(
                muteOrCopy: (prev, currentState) {
                  return _MutableCubit(currentState);
                },
                create: (state) {
                  createCallCount++;
                  return _MutableCubit(state);
                },
                builder: (context, state) {
                  return Text('count: ${state.count}');
                },
              ),
            ),
          ),
        );

        expect(find.text('count: 100'), findsOneWidget);
        expect(createCallCount, equals(2));

        secondCounterCubit.increment();
        await tester.pumpAndSettle();
        expect(find.text('count: 101'), findsOneWidget);
        expect(find.text('count: 100'), findsNothing);
        expect(createCallCount, equals(2));
      });
    },
  );
}
