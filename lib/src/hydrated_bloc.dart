import 'dart:async';
import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import '../hydrated_bloc.dart';

/// {@template hydrated_bloc}
/// Specialized `Bloc` which handles initializing the `Bloc` state
/// based on the persisted state. This allows state to be persisted
/// across hot restarts as well as complete app restarts.
/// {@endtemplate}
abstract class HydratedBloc<Event, State> extends Bloc<Event, State> {
  /// {@macro hydrated_bloc}
  HydratedBloc() {
    final stateJson = toJson(state);
    if (stateJson != null) {
      try {
        _storage.write(storageToken, json.encode(stateJson));
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }
  }

  static HydratedBlocDelegate get _delegate =>
      BlocSupervisor.delegate as HydratedBlocDelegate;
  static HydratedStorage get _storage => _delegate.storage;

  @mustCallSuper
  @override
  State get initialState {
    try {
      final jsonString = _storage.read(storageToken) as String;
      return jsonString?.isNotEmpty == true
          ? fromJson(json.decode(jsonString) as Map<String, dynamic>)
          : null;
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
      return null;
    }
  }

  @override
  void onTransition(Transition<Event, State> transition) {
    final state = transition.nextState;
    final stateJson = toJson(state);
    if (stateJson != null) {
      try {
        _storage.write(storageToken, json.encode(stateJson));
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }
    super.onTransition(transition);
  }

  /// `id` is used to uniquely identify multiple instances
  /// of the same `HydratedBloc` type.
  /// In most cases it is not necessary;
  /// however, if you wish to intentionally have multiple instances
  /// of the same `HydratedBloc`, then you must override `id`
  /// and return a unique identifier for each `HydratedBloc` instance
  /// in order to keep the caches independent of each other.
  String get id => '';

  /// `storageToken` is used as registration token for hydrated storage.
  @nonVirtual
  String get storageToken => '${runtimeType.toString()}${id ?? ''}';

  /// `clear` is used to wipe or invalidate the cache of a `HydratedBloc`.
  /// Calling `clear` will delete the cached state of the bloc
  /// but will not modify the current state of the bloc.
  Future<void> clear() => _storage.delete(storageToken);

  /// Responsible for converting the `Map<String, dynamic>` representation
  /// of the bloc state into a concrete instance of the bloc state.
  ///
  /// If `fromJson` throws an `Exception`,
  /// `HydratedBloc` will return an `initialState` of `null`
  /// so it is recommended to set `initialState` in the bloc to
  /// `super.initialState() ?? defaultInitialState()`.
  State fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the bloc state
  /// into the the `Map<String, dynamic>` representation.
  ///
  /// If `toJson` returns `null`, then no state changes will be persisted.
  Map<String, dynamic> toJson(State state);
}
