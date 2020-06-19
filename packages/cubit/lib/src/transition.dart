import 'package:meta/meta.dart';

/// {@template transition}
/// A [Transition] represents the change from one [State] to another.
/// A [Transition] consists of the [currentState] and [nextState].
/// {@endtemplate}
@immutable
class Transition<State> {
  /// {@macro transition}
  const Transition({@required this.currentState, @required this.nextState});

  /// The current [State] at the time of the [Transition].
  final State currentState;

  /// The next [State] at the time of the [Transition].
  final State nextState;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transition<State> &&
          runtimeType == other.runtimeType &&
          currentState == other.currentState &&
          nextState == other.nextState;

  @override
  int get hashCode => currentState.hashCode ^ nextState.hashCode;

  @override
  String toString() {
    return 'Transition { currentState: $currentState, nextState: $nextState }';
  }
}
