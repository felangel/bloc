import 'package:cubit/cubit.dart';
import 'package:meta/meta.dart';

import 'cubit_stream.dart';
import 'transition.dart';

/// {@template cubit}
/// A [Cubit] is a subset of [bloc](https://pub.dev/packages/bloc)
/// which has no notion of events and relies on methods to `emit` new states.
///
/// Every `cubit` requires an initial state which will be the
/// state of the `cubit` before `emit` has been called.
///
/// The current state of a `cubit` can be accessed via the `state` getter.
///
/// ```dart
/// class CounterCubit extends Cubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
/// }
/// ```
///
/// See also:
///
/// * [CubitStream], the base `Stream` implementation
/// upon which [Cubit] is built.
///
/// {@endtemplate}
abstract class Cubit<State> extends CubitStream<State> {
  /// {@macro cubit}
  Cubit(State initialState) : super(initialState);

  /// The current [CubitObserver].
  static CubitObserver observer = CubitObserver();

  /// Called whenever a [transition] occurs with the given [transition].
  /// A [transition] occurs when a new `state` is emitted.
  /// [onTransition] is called before the `state` of the `cubit` is updated.
  /// [onTransition] is a great spot to add logging/analytics for a specific `cubit`.
  ///
  /// **Note: `super.onTransition` should always be called last.**
  /// ```dart
  /// @override
  /// void onTransition(Transition transition) {
  ///   // Custom onTransition logic goes here
  ///
  ///   // Always call super.onTransition with the current transition
  ///   super.onTransition(transition);
  /// }
  /// ```
  ///
  /// See also:
  ///
  /// * [CubitObserver] for observing [Cubit] behavior globally.
  @mustCallSuper
  void onTransition(Transition<State> transition) {
    observer.onTransition(this, transition);
  }

  @override
  void emit(State state) {
    onTransition(Transition<State>(currentState: this.state, nextState: state));
    super.emit(state);
  }
}
