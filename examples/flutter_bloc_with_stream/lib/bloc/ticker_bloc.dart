import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../ticker/ticker.dart';

part 'ticker_event.dart';
part 'ticker_state.dart';

class TickerBloc extends Bloc<TickerEvent, TickerState> {
  final Ticker ticker;
  StreamSubscription subscription;

  TickerBloc(this.ticker) : super(TickerInitial());

  @override
  Stream<TickerState> mapEventToState(TickerEvent event) async* {
    if (event is TickerStarted) {
      subscription?.cancel();
      subscription = ticker.tick().listen((tick) => add(TickerTicked(tick)));
    }
    if (event is TickerTicked) {
      yield TickerTickSuccess(event.tickCount);
    }
  }

  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }
}
