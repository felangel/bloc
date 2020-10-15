part of 'ticker_bloc.dart';

/// {@template ticker_state}
/// Base class for all [TickerState]s which are
/// managed by the [TickerBloc].
/// {@endtemplate}
abstract class TickerState extends Equatable {
  /// {@macro ticker_state}
  const TickerState();

  @override
  List<Object> get props => [];
}

/// The initial state of the [TickerBloc].
class TickerInitial extends TickerState {}

/// {@template ticker_tick_success}
/// The state of the [TickerBloc] after a [Ticker]
/// has been started and includes the current tick count.
/// {@endtemplate}
class TickerTickSuccess extends TickerState {
  /// {@macro ticker_tick_success}
  const TickerTickSuccess(this.count);

  /// The current tick count.
  final int count;

  @override
  List<Object> get props => [count];
}
