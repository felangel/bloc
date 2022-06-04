import 'package:bloc/bloc.dart';
import 'package:flutter_counter/counter/cubit/counter_cubit.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages an [int] as its state.
/// {@endtemplate}
class CounterListCubit extends Cubit<List<CounterCubit>> {
  /// {@macro counter_cubit}
  CounterListCubit() : super(List.generate(10, (index) => CounterCubit()));
  @override
  Future<void> close() {
    for (var cubit in state) {
      cubit.close();
    }
    return super.close();
  }
}
