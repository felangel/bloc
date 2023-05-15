import 'package:bloc/bloc.dart';

import '../counter/counter_bloc.dart';

class OnErrorBloc extends Bloc<CounterEvent, int> {
  OnErrorBloc({required this.error, required this.onErrorCallback}) : super(0) {
    on<CounterEvent>(_onCounterEvent);
  }

  final void Function(Object, StackTrace) onErrorCallback;
  final Error error;

  @override
  void onError(Object error, StackTrace stackTrace) {
    onErrorCallback(error, stackTrace);
    super.onError(error, stackTrace);
  }

  void _onCounterEvent(CounterEvent event, Emitter<int> emit) {
    throw error;
  }
}
