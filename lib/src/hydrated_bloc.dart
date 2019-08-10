import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
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
  ///
  /// If `fromJson` throws an `Exception`, `HydratedBloc` will return an `initialState` of `null`
  /// so it is recommended to set `initialState` in the bloc to `super.initialState() ?? defaultInitialState()`.
  State fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the bloc state
  /// into the the `Map<String, dynamic>` representation.
  ///
  /// If `toJson` returns `null`, then no state changes will be persisted.
  Map<String, dynamic> toJson(State state);
}
