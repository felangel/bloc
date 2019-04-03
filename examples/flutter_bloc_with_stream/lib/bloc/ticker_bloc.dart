import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';
import '../ticker/ticker.dart';

class TickerBloc extends Bloc<TickerEvent, TickerState> {
  final Ticker ticker;
  StreamSubscription subscription;

  TickerBloc(this.ticker) {
    subscription = ticker.tick().listen((tick) => dispatch(Tick(tick)));
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  TickerState get initialState => InitialTickerState();

  @override
  Stream<TickerState> mapEventToState(TickerEvent event) async* {
    if (event is Tick) {
      yield TickUpdate(event.tickCount);
    }
  }
}
