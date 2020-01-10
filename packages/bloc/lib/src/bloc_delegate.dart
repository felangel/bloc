import 'package:meta/meta.dart';

import '../bloc.dart';

/// Handles `events` from all [bloc]s
/// which are delegated by the [BlocSupervisor].
class BlocDelegate {
  /// Called whenever an [event] is `added` to any [bloc] with the given [bloc]
  /// and [event].
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onEvent(Bloc bloc, Object event) => null;

  /// Called whenever a transition occurs in any [bloc] with the given [bloc]
  /// and [transition].
  /// A [transition] occurs when a new `event` is `added` and `mapEventToState`
  /// executed.
  /// [onTransition] is called before a [bloc]'s state has been updated.
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onTransition(Bloc bloc, Transition transition) => null;

  /// Called whenever an [error] is thrown in any [bloc] with the given [bloc],
  /// [error], and [stacktrace].
  /// The [stacktrace] argument may be `null` if the state stream received
  /// an error without a [stacktrace].
  /// A great spot to add universal error handling.
  @mustCallSuper
  void onError(Bloc bloc, Object error, StackTrace stacktrace) => null;
}
