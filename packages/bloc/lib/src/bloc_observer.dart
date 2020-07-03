import 'package:meta/meta.dart';

import '../bloc.dart';

/// An interface for observing the behavior of a [Bloc].
class BlocObserver {
  /// Called whenever an [event] is `added` to any [bloc] with the given [bloc]
  /// and [event].
  @protected
  @mustCallSuper
  void onEvent(Bloc bloc, Object event) {}

  /// Called whenever a transition occurs in any [bloc] with the given [bloc]
  /// and [transition].
  /// A [transition] occurs when a new `event` is `added` and `mapEventToState`
  /// executed.
  /// [onTransition] is called before a [bloc]'s state has been updated.
  @protected
  @mustCallSuper
  void onTransition(Bloc bloc, Transition transition) {}

  /// Called whenever an [error] is thrown in any [bloc] with the given [bloc],
  /// [error], and [stackTrace].
  /// The [stackTrace] argument may be `null` if the state stream received
  /// an error without a [stackTrace].
  @protected
  @mustCallSuper
  void onError(Bloc bloc, Object error, StackTrace stackTrace) {}
}
