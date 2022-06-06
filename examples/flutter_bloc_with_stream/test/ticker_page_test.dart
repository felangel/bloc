// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_with_stream/bloc/ticker_bloc.dart';
import 'package:flutter_bloc_with_stream/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTickerBloc extends MockBloc<TickerEvent, TickerState>
    implements TickerBloc {}

extension on WidgetTester {
  Future<void> pumpTickerPage(TickerBloc tickerBloc) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: tickerBloc, child: TickerPage()),
      ),
    );
  }
}

void main() {
  late TickerBloc tickerBloc;

  setUp(() {
    tickerBloc = MockTickerBloc();
  });

  tearDown(() => reset(tickerBloc));

  group('TickerPage', () {
    testWidgets('renders initial state', (tester) async {
      when(() => tickerBloc.state).thenReturn(TickerInitial());
      await tester.pumpTickerPage(tickerBloc);

      expect(find.text('Press the floating button to start.'), findsOneWidget);
    });

    testWidgets('renders tick count ', (tester) async {
      const tickCount = 5;
      when(() => tickerBloc.state).thenReturn(TickerTickSuccess(tickCount));
      await tester.pumpTickerPage(tickerBloc);

      expect(find.text('Tick #$tickCount'), findsOneWidget);
    });

    testWidgets(
        'adds ticker started '
        'when start ticker floating action button is pressed', (tester) async {
      when(() => tickerBloc.state).thenReturn(TickerInitial());
      await tester.pumpTickerPage(tickerBloc);

      await tester.tap(find.byType(FloatingActionButton));
      verify(() => tickerBloc.add(TickerStarted())).called(1);
    });

    testWidgets(
        'tick count periodically increments '
        'every 1 second', (tester) async {
      whenListen(
        tickerBloc,
        Stream.periodic(Duration(seconds: 1), TickerTickSuccess.new).take(3),
        initialState: TickerInitial(),
      );

      await tester.pumpTickerPage(tickerBloc..add(TickerStarted()));

      await tester.pump(Duration(seconds: 1));
      expect(find.text('Tick #0'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Tick #1'), findsOneWidget);
      await tester.pump(Duration(seconds: 1));
      expect(find.text('Tick #2'), findsOneWidget);
    });

    testWidgets('renders complete state', (tester) async {
      when(() => tickerBloc.state).thenReturn(TickerComplete());

      await tester.pumpTickerPage(tickerBloc);
      await tester.pumpAndSettle();

      expect(
        find.text('Complete! Press the floating button to restart.'),
        findsOneWidget,
      );
    });
  });
}
