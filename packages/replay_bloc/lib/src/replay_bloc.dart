import 'package:bloc/bloc.dart' hide Change;
import 'package:replay_bloc/replay_bloc.dart';

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
abstract class ReplayBloc<Event, State> extends Bloc<Event, State>
    with ReplayMixin<State> {
  /// {@macro replay_bloc}
  ReplayBloc(State state, {int limit}) : super(state) {
    this.limit = limit;
  }
}
