import 'package:bloc/bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

/// {@template hydrated_cubit}
/// Specialized [Cubit] which handles initializing the [Cubit] state
/// based on the persisted state. This allows state to be persisted
/// across application restarts.
///
/// ```dart
/// class CounterCubit extends HydratedCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///   void decrement() => emit(state - 1);
///
///   @override
///   int fromJson(Map<String, dynamic> json) => json['value'] as int;
///
///   @override
///   Map<String, int> toJson(int state) => {'value': state};
/// }
/// ```
///
/// {@endtemplate}
abstract class HydratedCubit<State> extends Cubit<State>
    with HydratedMixin<Null, State> {
  /// {@macro hydrated_cubit}
  HydratedCubit(State state) : super(state) {
    hydrate();
  }

  /// Setter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static set storage(Storage? storage) {
    HydratedMixin.storage = storage;
  }

  /// Getter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static Storage? get storage => HydratedMixin.storage;
}
