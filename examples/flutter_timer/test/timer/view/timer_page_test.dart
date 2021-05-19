import 'package:flutter/material.dart';
import 'package:flutter_timer/timer/timer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockTimerBloc extends MockBloc<TimerEvent, TimerState>
    implements TimerBloc {}

class FakeTimerState extends Fake implements TimerState {}

class FakeTimerEvent extends Fake implements TimerEvent {}

extension on WidgetTester {
  Future<void> pumpTimerView(TimerBloc timerBloc) {
    return pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: timerBloc, child: TimerView()),
      ),
    );
  }
}

void main() {
  late TimerBloc timerBloc;

  setUpAll(() {
    registerFallbackValue<TimerState>(FakeTimerState());
    registerFallbackValue<TimerEvent>(FakeTimerEvent());
  });

  setUp(() {
    timerBloc = MockTimerBloc();
  });

  tearDown(() => reset(timerBloc));

  group('TimerPage', () {
    testWidgets('renders TimerView', (tester) async {
      await tester.pumpWidget(MaterialApp(home: TimerPage()));
      expect(find.byType(TimerView), findsOneWidget);
    });
  });

  group('TimerView', () {
    testWidgets('renders initial Timer view', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerInitial(60));
      await tester.pumpTimerView(timerBloc);
      expect(find.text('01:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
    });

    testWidgets('renders pause and reset button when timer is in progress',
        (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunInProgress(59));
      await tester.pumpTimerView(timerBloc);
      expect(find.text('00:59'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('renders play and reset button when timer is paused',
        (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunPause(600));
      await tester.pumpTimerView(timerBloc);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('renders replay button when timer is finished', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunComplete());
      await tester.pumpTimerView(timerBloc);
      expect(find.text('00:00'), findsOneWidget);
      expect(find.byIcon(Icons.replay), findsOneWidget);
    });

    testWidgets('timer started when play arrow button is pressed',
        (tester) async {
      when(() => timerBloc.state).thenReturn(TimerInitial(60));
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.play_arrow));
      verify(() => timerBloc.add(TimerStarted(duration: 60))).called(1);
    });

    testWidgets(
        'timer pauses when pause button is pressed '
        'while timer is in progress', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunInProgress(30));
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.pause));
      verify(() => timerBloc.add(TimerPaused())).called(1);
    });

    testWidgets(
        'timer resets when replay button is pressed '
        'while timer is in progress', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunInProgress(30));
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.replay));
      verify(() => timerBloc.add(TimerReset())).called(1);
    });

    testWidgets(
        'timer resumes when play arrow button is pressed '
        'while timer is paused', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunPause(30));
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.play_arrow));
      verify(() => timerBloc.add(TimerResumed())).called(1);
    });

    testWidgets(
        'timer resets when reset button is pressed '
        'while timer is paused', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunPause(30));
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.replay));
      verify(() => timerBloc.add(TimerReset())).called(1);
    });

    testWidgets(
        'timer resets when reset button is pressed '
        'when timer is finished', (tester) async {
      when(() => timerBloc.state).thenReturn(TimerRunComplete());
      await tester.pumpTimerView(timerBloc);
      await tester.tap(find.byIcon(Icons.replay));
      verify(() => timerBloc.add(TimerReset())).called(1);
    });
  });
}
