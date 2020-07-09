import 'dart:collection';
import 'package:cubit/cubit.dart';

part 'change_stack.dart';

/// {@template replay_cubit}
/// A specialized [Cubit] which supports `undo` and `redo` operations.
///
/// [ReplayCubit] accepts an optional `limit` which determines
/// the max size of the history.
///
/// A custom [ReplayCubit] can be created by extending [ReplayCubit].
///
/// ```dart
/// class CounterCubit extends ReplayCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
///
/// Then the built-in `undo` and `redo` operations can be used.
///
/// ```dart
/// final cubit = CounterCubit();
///
/// cubit.increment();
/// print(cubit.state); // 1
///
/// cubit.undo();
/// print(cubit.state); // 0
///
/// cubit.redo();
/// print(cubit.state); // 1
/// ```
///
/// The undo/redo history can be destroyed at any time by calling `clear`.
///
/// See also:
///
/// * [Cubit] for information about the [ReplayCubit] superclass.
///
/// {@endtemplate}
abstract class ReplayCubit<State> extends Cubit<State> with ReplayMixin<State> {
  /// {@macro replay_cubit}
  ReplayCubit(State state, {int limit}) : super(state) {
    this.limit = limit;
  }
}

mixin ReplayMixin<State> on CubitStream<State> {
  final _changeStack = _ChangeStack<State>();

  set limit(int limit) => _changeStack.limit = limit;

  @override
  void emit(State state) {
    _changeStack.add(_Change<State>(
      this.state,
      () => super.emit(state),
      (val) => super.emit(val),
    ));
  }

  /// Undo the last change
  void undo() => _changeStack.undo();

  /// Redo the previous change
  void redo() => _changeStack.redo();

  /// Checks whether the undo/redo stack is empty
  bool get canUndo => _changeStack.canUndo;

  /// Checks wether the undo/redo stack is at the current change
  bool get canRedo => _changeStack.canRedo;

  /// Clear undo/redo history
  void clearHistory() => _changeStack.clear();
}
