import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0);

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield state + 1;
        break;
    }
  }
}

void main() {
  group('MultiBlocListener', () {
    testWidgets(
      'throws if initialized with no listeners and no child',
      (tester) async {
        try {
          await tester.pumpWidget(
            MultiBlocListener(
              listeners: null,
              child: null,
            ),
          );
        } on dynamic catch (error) {
          expect(error, isAssertionError);
        }
      },
    );

    testWidgets(
      'throws if initialized with no listeners',
      (tester) async {
        try {
          await tester.pumpWidget(
            MultiBlocListener(
              listeners: null,
              child: Container(),
            ),
          );
        } on dynamic catch (error) {
          expect(error, isAssertionError);
        }
      },
    );

    testWidgets(
      'throws if initialized with no child',
      (tester) async {
        try {
          await tester.pumpWidget(
            MultiBlocListener(
              listeners: [],
              child: null,
            ),
          );
        } on dynamic catch (error) {
          expect(error, isAssertionError);
        }
      },
    );

    testWidgets(
      'calls listeners on state changes',
      (tester) async {
        int latestStateA;
        var listenerCallCountA = 0;
        final counterBlocA = CounterBloc();
        final expectedStatesA = [0, 1, 2];

        int latestStateB;
        var listenerCallCountB = 0;
        final counterBlocB = CounterBloc();
        final expectedStatesB = [0, 1];

        await tester.pumpWidget(
          MultiBlocListener(
            listeners: [
              BlocListener<CounterBloc, int>(
                bloc: counterBlocA,
                listener: (context, state) {
                  listenerCallCountA++;
                  latestStateA = state;
                },
              ),
              BlocListener<CounterBloc, int>(
                bloc: counterBlocB,
                listener: (context, state) {
                  listenerCallCountB++;
                  latestStateB = state;
                },
              ),
            ],
            child: Container(key: const Key('multiBlocListener_child')),
          ),
        );
        await tester.pumpAndSettle();

        expect(
            find.byKey(const Key('multiBlocListener_child')), findsOneWidget);

        counterBlocA..add(CounterEvent.increment)..add(CounterEvent.increment);
        counterBlocB.add(CounterEvent.increment);

        await expectLater(counterBlocA, emitsInOrder(expectedStatesA));
        expect(listenerCallCountA, 2);
        expect(latestStateA, 2);

        await expectLater(counterBlocB, emitsInOrder(expectedStatesB));
        expect(listenerCallCountB, 1);
        expect(latestStateB, 1);
      },
      initialTimeout: const Duration(seconds: 3),
    );

    testWidgets('calls listeners on state changes without explicit types',
        (tester) async {
      int latestStateA;
      var listenerCallCountA = 0;
      final counterBlocA = CounterBloc();
      final expectedStatesA = [0, 1, 2];

      int latestStateB;
      var listenerCallCountB = 0;
      final counterBlocB = CounterBloc();
      final expectedStatesB = [0, 1];

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener<CounterBloc, int>(
              bloc: counterBlocA,
              listener: (context, state) {
                listenerCallCountA++;
                latestStateA = state;
              },
            ),
            BlocListener<CounterBloc, int>(
              bloc: counterBlocB,
              listener: (context, state) {
                listenerCallCountB++;
                latestStateB = state;
              },
            ),
          ],
          child: Container(key: const Key('multiBlocListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('multiBlocListener_child')), findsOneWidget);

      counterBlocA..add(CounterEvent.increment)..add(CounterEvent.increment);
      counterBlocB.add(CounterEvent.increment);

      await expectLater(counterBlocA, emitsInOrder(expectedStatesA));
      expect(listenerCallCountA, 2);
      expect(latestStateA, 2);

      await expectLater(counterBlocB, emitsInOrder(expectedStatesB));
      expect(listenerCallCountB, 1);
      expect(latestStateB, 1);
    });
  });
}
