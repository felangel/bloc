import 'package:bloc/bloc.dart';

typedef OnEventCallback = void Function(CounterEvent);
typedef OnTransitionCallback = void Function(Transition<CounterEvent, int>);
typedef OnErrorCallback = void Function(Object error, StackTrace? stackTrace);

enum CounterEvent { increment, decrement }

class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc({
    this.onEventCallback,
    this.onTransitionCallback,
    this.onErrorCallback,
  }) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final OnEventCallback? onEventCallback;
  final OnTransitionCallback? onTransitionCallback;
  final OnErrorCallback? onErrorCallback;

  @override
  void onEvent(CounterEvent event) {
    super.onEvent(event);
    onEventCallback?.call(event);
  }

  @override
  void onTransition(Transition<CounterEvent, int> transition) {
    super.onTransition(transition);
    onTransitionCallback?.call(transition);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback?.call(error, stackTrace);
    super.onError(error, stackTrace);
  }

  void _onCounterEvent(CounterEvent event, Emitter<int> emit) {
    switch (event) {
      case CounterEvent.increment:
        return emit(state + 1);
      case CounterEvent.decrement:
        return emit(state - 1);
    }
  }
}
