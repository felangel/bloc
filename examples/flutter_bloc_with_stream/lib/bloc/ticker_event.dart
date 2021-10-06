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

/// {@template ticker_started}
/// Signifies to the [TickerBloc] that the user
/// has requested to start the [Ticker].
/// {@endtemplate}
class TickerStarted extends TickerEvent {
  /// {@macro ticker_started}
  const TickerStarted();
}

class _TickerTicked extends TickerEvent {
  const _TickerTicked(this.tick);

  /// The current tick count.
  final int tick;

  @override
  List<Object> get props => [tick];
}
