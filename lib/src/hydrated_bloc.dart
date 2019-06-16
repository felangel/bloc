import 'dart:convert';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

/// Specialized `Bloc` which handles initializing the `Bloc` state
/// based on the persisted state. This allows state to be persisted
/// across hot restarts as well as complete app restarts.
abstract class HydratedBloc<Event, State> extends Bloc<Event, State> {
  final HydratedStorage storage =
      (BlocSupervisor.delegate as HydratedBlocDelegate).storage;

  @mustCallSuper
  @override
  State get initialState {
    try {
      return fromJson(
        json.decode(
          storage?.read(this.runtimeType.toString()) as String,
        ) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  /// Responsible for converting the `Map<String, dynamic>` representation of the bloc state
  /// into a concrete instance of the bloc state.
  State fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the bloc state
  /// into the the `Map<String, dynamic>` representation.
  Map<String, dynamic> toJson(State state);
}
