import 'package:bloc/bloc.dart';

/// Handles events from all [Bloc]s
/// which are delegated by the [BlocSupervisor].
abstract class BlocDelegate {
  /// Called whenever a transition occurs with the given [Transition] in any [Bloc].
  /// A [Transition] occurs when a new [Event] is dispatched and `mapEventToState` executed.
  /// `onTransition` is called before a [Bloc]'s state has been updated.
  /// A great spot to add universal logging/analytics.
  void onTransition(Transition transition);
}
