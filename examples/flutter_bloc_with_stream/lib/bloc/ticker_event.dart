part of 'ticker_bloc.dart';

/// {@template ticker_event}
/// Base class for all [TickerEvent]s which are
/// handled by the [TickerBloc].
/// {@endtemplate}
abstract class TickerEvent extends Equatable {
  /// {@macro ticker_event}
  const TickerEvent();

  @override
  List<Object> get props => [];
}

/// Signifies to the [TickerBloc] that the user
/// has requested to start the [Ticker].
class TickerStarted extends TickerEvent {}

class _TickerTicked extends TickerEvent {
  const _TickerTicked(this.tickCount);

  final int tickCount;

  @override
  List<Object> get props => [tickCount];
}
