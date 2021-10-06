import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc_with_stream/ticker/ticker.dart';

part 'ticker_event.dart';
part 'ticker_state.dart';

/// {@template ticker_bloc}
/// Bloc which manages the current [TickerState]
/// and depends on a [Ticker] instance.
/// {@endtemplate}
class TickerBloc extends Bloc<TickerEvent, TickerState> {
  /// {@macro ticker_bloc}
  TickerBloc(Ticker ticker) : super(TickerInitial()) {
    on<TickerStarted>(
      (event, emit) async {
        await emit.onEach<int>(
          ticker.tick(),
          onData: (tick) => add(_TickerTicked(tick)),
        );
        emit(const TickerComplete());
      },
      transformer: restartable(),
    );

    on<_TickerTicked>((event, emit) => emit(TickerTickSuccess(event.tick)));
  }
}
