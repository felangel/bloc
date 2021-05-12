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

///
class TickerTicked extends TickerEvent {
  /// {@macro ticker_ticked}
  const TickerTicked(this.tickCount);

  /// The current tick count.
  final int tickCount;

  @override
  List<Object> get props => [tickCount];
}
