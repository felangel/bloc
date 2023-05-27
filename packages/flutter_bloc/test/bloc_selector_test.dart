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
            selector: (state) => state.isEven,
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
              selector: (state) => state.isEven,
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
              selector: (state) => state.isEven,
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
              selector: (state) => state.isEven,
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
            selector: (state) => state.isEven,
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
            selector: (state) => state.isEven,
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
  });
}
