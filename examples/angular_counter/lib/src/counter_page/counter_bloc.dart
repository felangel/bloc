import 'package:bloc/bloc.dart';

/// Base counter event.
sealed class CounterEvent {}

/// Notifies bloc to increment state.
final class CounterIncrementPressed extends CounterEvent {}

/// Notifies bloc to decrement state.
final class CounterDecrementPressed extends CounterEvent {}

/// {@template counter_bloc}
/// A simple [Bloc] that manages an `int` as its state.
/// {@endtemplate}
class CounterBloc extends Bloc<CounterEvent, int> {
  /// {@macro counter_bloc}
  CounterBloc() : super(0) {
    on<CounterIncrementPressed>((event, emit) => emit(state + 1));
    on<CounterDecrementPressed>((event, emit) => emit(state - 1));
  }
}
