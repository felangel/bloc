import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

enum CounterEvent { increment }

class CounterBloc extends Bloc<CounterEvent, int> {
  @override
  int get initialState => 0;

  @override
  Stream<int> mapEventToState(CounterEvent event) async* {
    switch (event) {
      case CounterEvent.increment:
        yield currentState + 1;
        break;
    }
  }
}

void main() {
  group('MultiBlocListener', () {
    testWidgets('throws if initialized with no listeners and no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: null,
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no listeners',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: null,
            child: Container(),
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('throws if initialized with no child',
        (WidgetTester tester) async {
      try {
        await tester.pumpWidget(
          MultiBlocListener(
            listeners: [],
            child: null,
          ),
        );
      } catch (error) {
        expect(error, isAssertionError);
      }
    });

    testWidgets('calls listeners on state changes',
        (WidgetTester tester) async {
      int latestStateA;
      int listenerCallCountA = 0;
      final counterBlocA = CounterBloc();
      final expectedStatesA = [0, 1, 2];

      int latestStateB;
      int listenerCallCountB = 0;
      final counterBlocB = CounterBloc();
      final expectedStatesB = [0, 1];

      await tester.pumpWidget(
        MultiBlocListener(
          listeners: [
            BlocListener<CounterBloc, int>(
              bloc: counterBlocA,
              listener: (BuildContext context, int state) {
                listenerCallCountA++;
                latestStateA = state;
              },
            ),
            BlocListener<CounterBloc, int>(
              bloc: counterBlocB,
              listener: (BuildContext context, int state) {
                listenerCallCountB++;
                latestStateB = state;
              },
            ),
          ],
          child: Container(key: Key('multiBlocListener_child')),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(Key('multiBlocListener_child')), findsOneWidget);

      counterBlocA.dispatch(CounterEvent.increment);
      counterBlocA.dispatch(CounterEvent.increment);
      counterBlocB.dispatch(CounterEvent.increment);

      expectLater(counterBlocA.state, emitsInOrder(expectedStatesA)).then((_) {
        expect(listenerCallCountA, 2);
        expect(latestStateA, 2);
      });

      expectLater(counterBlocB.state, emitsInOrder(expectedStatesB)).then((_) {
        expect(listenerCallCountB, 1);
        expect(latestStateB, 1);
      });
    });
  });
}
