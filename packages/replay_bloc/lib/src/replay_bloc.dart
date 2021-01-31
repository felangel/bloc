part of 'replay_cubit.dart';

/// {@template replay_event}
/// Base event class for all [ReplayBloc] events.
/// {@endtemplate}
abstract class ReplayEvent {
  /// {@template replay_event}
  const ReplayEvent();
}

/// Notifies a [ReplayBloc] of a Redo
class _Redo extends ReplayEvent {
  @override
  String toString() => 'Redo';
}

/// Notifies a [ReplayBloc] of an Undo
class _Undo extends ReplayEvent {
  @override
  String toString() => 'Undo';
}

/// {@template replay_bloc}
/// A specialized [Bloc] which supports `undo` and `redo` operations.
///
/// [ReplayBloc] accepts an optional `limit` which determines
/// the max size of the history.
///
/// A custom [ReplayBloc] can be created by extending [ReplayBloc].
///
/// ```dart
/// enum CounterEvent { increment }
///
/// class CounterBloc extends ReplayBloc<CounterEvent, int> {
///   CounterBloc() : super(0);
///
///   @override
///   Stream<int> mapEventToState(CounterEvent event) async* {
///     switch (event) {
///       case CounterEvent.increment:
///         yield state + 1;
///         break;
///     }
///   }
/// }
/// ```
///
/// Then the built-in `undo` and `redo` operations can be used.
///
/// ```dart
/// final bloc = CounterBloc();
///
/// bloc.add(CounterEvent.increment);
///
/// bloc.undo();
///
/// bloc.redo();
/// ```
///
/// The undo/redo history can be destroyed at any time by calling `clear`.
///
/// See also:
///
/// * [Bloc] for information about the [ReplayBloc] superclass.
///
/// {@endtemplate}
abstract class ReplayBloc<Event extends ReplayEvent, State>
    extends Bloc<Event, State> with ReplayBlocMixin<Event, State> {
  /// {@macro replay_bloc}
  ReplayBloc(State state, {int? limit}) : super(state) {
    if (limit != null) {
      this.limit = limit;
    }
  }
}

/// A mixin which enables `undo` and `redo` operations
/// for [Bloc] classes.
mixin ReplayBlocMixin<Event extends ReplayEvent, State> on Bloc<Event, State> {
  final _changeStack = _ChangeStack<State>();

  /// Sets the internal `undo`/`redo` size limit.
  /// By default there is no limit.
  set limit(int limit) => _changeStack.limit = limit;

  @override
  Stream<State> mapEventToState(covariant Event event);

  @override
  // ignore: must_call_super
  void onTransition(covariant Transition<ReplayEvent, State> transition) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onTransition(this, transition);
  }

  @override
  // ignore: must_call_super
  void onEvent(covariant ReplayEvent event) {
    // ignore: invalid_use_of_protected_member
    Bloc.observer.onEvent(this, event);
  }

  @override
  void emit(State state) {
    _changeStack.add(_Change<State>(
      this.state,
      () {
        final event = _Redo();
        onEvent(event);
        onTransition(Transition(
          currentState: this.state,
          event: event,
          nextState: state,
        ));
        // ignore: invalid_use_of_visible_for_testing_member
        super.emit(state);
      },
      (val) {
        final event = _Undo();
        onEvent(event);
        onTransition(Transition(
          currentState: this.state,
          event: event,
          nextState: val,
        ));
        // ignore: invalid_use_of_visible_for_testing_member
        super.emit(val);
      },
    ));
    // ignore: invalid_use_of_visible_for_testing_member
    super.emit(state);
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
