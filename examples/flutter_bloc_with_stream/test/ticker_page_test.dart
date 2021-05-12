import 'package:flutter/material.dart';
import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_bloc_with_stream/main.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

const _startTickerButtonKey =
  Key('tickerPage_startTicker_floatingActionButton');

class MockTickerBloc extends MockBloc<TickerEvent, TickerState>
    implements TickerBloc {}


Widget wrapper({required Widget child, required TickerBloc tickerBloc}) {
  return MaterialApp(
    home: BlocProvider.value(value: tickerBloc, child: child),
  );
}

void main() {
  late TickerBloc tickerBloc;

  setUpAll(() {
    registerFallbackValue<TickerState>(TickerInitial());
    registerFallbackValue<TickerEvent>(TickerStarted());
    tickerBloc = MockTickerBloc();
  });

  group('TickerPage', () {
    testWidgets('renders initial TickerPage state', (tester) async {
      when(() => tickerBloc.state).thenReturn(TickerInitial());

      await tester.pumpWidget(
        wrapper(child: TickerPage(), tickerBloc: tickerBloc)
      );
      expect(find.text('Press the floating button to start'), findsOneWidget);
    });

    testWidgets('renders tick count ', (tester) async {
      var tickCount = 5;
      when(() => tickerBloc.state).thenReturn(TickerTickSuccess(tickCount));

      await tester.pumpWidget(
        wrapper(child: TickerPage(), tickerBloc: tickerBloc)
      );
      expect(find.text('Tick #$tickCount'), findsOneWidget);
    });

    testWidgets('ticker started '
        'when start ticker floating action button is pressed', (tester) async {
      when(() => tickerBloc.state).thenReturn(TickerInitial());

      await tester.pumpWidget(
          wrapper(child: TickerPage(), tickerBloc: tickerBloc)
      );

      await tester.tap(find.byKey(_startTickerButtonKey));
      verify(() => tickerBloc.add(TickerStarted())).called(1);
    });

    testWidgets('tick count periodically increments', (tester) async {
      whenListen(tickerBloc, Stream.periodic(
        const Duration(seconds: 1),
        (i) => TickerTickSuccess(i)).take(3),
        initialState: TickerInitial(),
      );

      await tester.pumpWidget(
        wrapper(child: TickerPage(),
        tickerBloc: tickerBloc..add(TickerStarted()))
      );
      
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Tick #0'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Tick #1'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Tick #2'), findsOneWidget);

    });
  });
}