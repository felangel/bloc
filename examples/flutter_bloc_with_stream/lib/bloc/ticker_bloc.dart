import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import '../ticker/ticker.dart';

class TickerBloc extends Bloc<TickerEvent, TickerState> {
  final Ticker ticker;
  StreamSubscription subscription;

  TickerBloc(this.ticker);

  @override
  TickerState get initialState => Initial();

  @override
  Stream<TickerState> mapEventToState(TickerEvent event) async* {
    if (event is StartTicker) {
      subscription?.cancel();
      subscription = ticker.tick().listen((tick) => dispatch(Tick(tick)));
    }
    if (event is Tick) {
      yield Update(event.tickCount);
    }
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
