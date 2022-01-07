import 'package:hydrated_bloc/hydrated_bloc.dart';

/// {@template counter_cubit}
/// A [Cubit] which manages an [int] as its state.
/// {@endtemplate}
class CounterCubit extends HydratedCubit<int> {
  /// {@macro counter_cubit}
  CounterCubit() : super(0);

  /// Add 1 to the current state.
  void increment() => emit(state + 1);

  /// Subtract 1 from the current state.
  void decrement() => emit(state - 1);

  @override
  int? fromJson(Map<String, dynamic> json) {
    return json['count'] as int?;
  }

  @override
  Map<String, dynamic>? toJson(int state) {
    return <String, dynamic>{'count': state};
  }
}
