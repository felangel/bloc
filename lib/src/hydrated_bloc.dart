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
      final jsonString =
          storage?.read('${this.runtimeType.toString()}$id') as String;
      return jsonString?.isNotEmpty == true
          ? fromJson(json.decode(jsonString) as Map<String, dynamic>)
          : null;
    } catch (_) {
      return null;
    }
  }

  /// `id` is used to uniquely identify multiple instances of the same `HydratedBloc` type.
  /// In most cases it is not necessary; however, if you wish to intentionally have multiple instances
  /// of the same `HydratedBloc`, then you must override `id` and return a unique identifier for each
  /// `HydratedBloc` instance in order to keep the caches independent of each other.
  String get id => '';

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
