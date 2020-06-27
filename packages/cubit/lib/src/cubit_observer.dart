import 'package:meta/meta.dart';

import '../cubit.dart';

/// An interface for observing the behavior of a [Cubit].
class CubitObserver {
  /// Called whenever a transition occurs in any [cubit] with the given [cubit]
  /// and [transition].
  /// A [transition] occurs when a new state is emitted.
  /// [onTransition] is called before a cubit's state has been updated.
  @mustCallSuper
  void onTransition(Cubit cubit, Transition transition) {}
}
