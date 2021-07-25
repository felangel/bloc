import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../ticker/ticker.dart';

part 'ticker_event.dart';
part 'ticker_state.dart';

/// {@template ticker_bloc}
/// Bloc which manages the current [TickerState]
/// and depends on a [Ticker] instance.
/// {@endtemplate}
class TickerBloc extends Bloc<TickerEvent, TickerState> {
  /// {@macro ticker_bloc}
  TickerBloc(this._ticker) : super(TickerInitial()) {
    on<TickerStarted>(_onTickerStarted);
    on<_TickerTicked>(_onTickerTicked);
  }

  final Ticker _ticker;
  StreamSubscription? _subscription;

  void _onTickerStarted(TickerStarted event, Emitter<TickerState> emit) {
    _subscription?.cancel();
    _subscription = _ticker.tick().listen((tick) => add(_TickerTicked(tick)));
  }

  void _onTickerTicked(_TickerTicked event, Emitter<TickerState> emit) {
    emit(TickerTickSuccess(event.tickCount));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
