import 'dart:async';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_timer/ticker.dart';

part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  final Ticker _ticker;
  final int _duration = 60;

  StreamSubscription<int> _tickerSubscription;

  TimerBloc({@required Ticker ticker})
      : assert(ticker != null),
        _ticker = ticker;

  @override
  TimerState get initialState => TimerInitial(_duration);

  @override
  void onTransition(Transition<TimerEvent, TimerState> transition) {
    print(transition);
    super.onTransition(transition);
  }

  @override
  Stream<TimerState> mapEventToState(
    TimerEvent event,
  ) async* {
    if (event is TimerRunStarted) {
      yield* _mapStartToState(event);
    } else if (event is TimerRunPaused) {
      yield* _mapPauseToState(event);
    } else if (event is TimerRunResumed) {
      yield* _mapResumeToState(event);
    } else if (event is TimerRunReset) {
      yield* _mapResetToState(event);
    } else if (event is TimerTicked) {
      yield* _mapTickToState(event);
    }
  }

  @override
  Future<void> close() {
    _tickerSubscription?.cancel();
    return super.close();
  }

  Stream<TimerState> _mapStartToState(TimerRunStarted start) async* {
    yield TimerRunningInProgress(start.duration);
    _tickerSubscription?.cancel();
    _tickerSubscription = _ticker
        .tick(ticks: start.duration)
        .listen((duration) => add(TimerTicked(duration: duration)));
  }

  Stream<TimerState> _mapPauseToState(TimerRunPaused pause) async* {
    if (state is TimerRunningInProgress) {
      _tickerSubscription?.pause();
      yield TimerRunningPaused(state.duration);
    }
  }

  Stream<TimerState> _mapResumeToState(TimerRunResumed resume) async* {
    if (state is TimerRunningPaused) {
      _tickerSubscription?.resume();
      yield TimerRunningInProgress(state.duration);
    }
  }

  Stream<TimerState> _mapResetToState(TimerRunReset reset) async* {
    _tickerSubscription?.cancel();
    yield TimerInitial(_duration);
  }

  Stream<TimerState> _mapTickToState(TimerTicked tick) async* {
    yield tick.duration > 0
        ? TimerRunningInProgress(tick.duration)
        : TimerRunningFinished();
  }
}
