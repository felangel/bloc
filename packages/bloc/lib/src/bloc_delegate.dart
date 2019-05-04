import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// Handles events from all [Bloc]s
/// which are delegated by the [BlocSupervisor].
class BlocDelegate {
  /// Called whenever an [Event] is dispatched to any [Bloc] with the given [Bloc] and [Event].
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onEvent(Bloc bloc, Object event) => null;

  /// Called whenever a transition occurs in any [Bloc] with the given [Bloc] and [Transition].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s state has been updated.
  /// A great spot to add universal logging/analytics.
  @mustCallSuper
  void onTransition(Bloc bloc, Transition transition) => null;

  /// Called whenever an [Exception] is thrown in any [Bloc]
  /// with the given [Bloc], [Exception], and [StackTrace].
  /// The stacktrace argument may be `null` if the state stream received an error without a [StackTrace].
  /// A great spot to add universal error handling.
  @mustCallSuper
  void onError(Bloc bloc, Object error, StackTrace stacktrace) => null;
}
