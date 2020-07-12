import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'hydrated_storage.dart';

/// {@template hydrated_storage_not_found}
/// Exception thrown if there was no [HydratedStorage] specified.
/// This is most likely due to forgetting to setup the [HydratedStorage]:
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   HydratedCubit.storage = await HydratedStorage.build();
///   runApp(MyApp());
/// }
/// ```
///
/// {@endtemplate}
class HydratedStorageNotFound implements Exception {
  /// {@macro hydrated_storage_not_found}
  const HydratedStorageNotFound();

  @override
  String toString() {
    return 'HydratedStorage was accessed before it was initialized.\n'
        'Please ensure that storage has been initialized.\n\n'
        'For example:\n\n'
        'HydratedCubit.storage = await HydratedStorage.build();';
  }
}

/// {@template hydrated_cubit}
/// Specialized [Cubit] which handles initializing the [Cubit] state
/// based on the persisted state. This allows state to be persisted
/// across application restarts.
///
/// ```dart
/// class CounterCubit extends HydratedCubit<int> {
///   CounterCubit() : super(0);
///
///   void increment() => emit(state + 1);
///   void decrement() => emit(state - 1);
///
///   @override
///   int fromJson(Map<String, dynamic> json) => json['value'] as int;
///
///   @override
///   Map<String, int> toJson(int state) => {'value': state};
/// }
/// ```
///
/// {@endtemplate}
abstract class HydratedCubit<State> extends Cubit<State>
    with HydratedMixin<State> {
  /// {@macro hydrated_cubit}
  HydratedCubit(State state) : super(state) {
    init();
  }

  /// Setter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static set storage(Storage storage) {
    HydratedMixin.storage = storage;
  }

  /// Getter for instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static Storage get storage => HydratedMixin.storage;
}

mixin HydratedMixin<State> on Cubit<State> {
  /// Instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static Storage storage;

  void init() {
    if (storage == null) throw const HydratedStorageNotFound();
    final stateJson = toJson(state);
    if (stateJson != null) {
      try {
        storage.write(storageToken, stateJson);
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }
  }

  State _state;

  @override
  State get state {
    if (storage == null) throw const HydratedStorageNotFound();
    if (_state != null) return _state;
    try {
      final stateJson = storage.read(storageToken) as Map<dynamic, dynamic>;
      if (stateJson == null) return _state = super.state;
      return _state = fromJson(Map<String, dynamic>.from(stateJson));
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
      return _state = super.state;
    }
  }

  @override
  void onChange(Change<State> change) {
    if (storage == null) throw const HydratedStorageNotFound();
    final state = change.nextState;
    final stateJson = toJson(state);
    if (stateJson != null) {
      try {
        storage.write(storageToken, stateJson);
      } on dynamic catch (error, stackTrace) {
        onError(error, stackTrace);
      }
    }
    _state = state;
    super.onChange(change);
  }

  /// `id` is used to uniquely identify multiple instances
  /// of the same `HydratedCubit` type.
  /// In most cases it is not necessary;
  /// however, if you wish to intentionally have multiple instances
  /// of the same `HydratedCubit`, then you must override `id`
  /// and return a unique identifier for each `HydratedCubit` instance
  /// in order to keep the caches independent of each other.
  String get id => '';

  /// `storageToken` is used as registration token for hydrated storage.
  @nonVirtual
  String get storageToken => '${runtimeType.toString()}${id ?? ''}';

  /// `clear` is used to wipe or invalidate the cache of a `HydratedCubit`.
  /// Calling `clear` will delete the cached state of the cubit
  /// but will not modify the current state of the cubit.
  Future<void> clear() => storage.delete(storageToken);

  /// Responsible for converting the `Map<String, dynamic>` representation
  /// of the cubit state into a concrete instance of the cubit state.
  State fromJson(Map<String, dynamic> json);

  /// Responsible for converting a concrete instance of the cubit state
  /// into the the `Map<String, dynamic>` representation.
  ///
  /// If `toJson` returns `null`, then no state changes will be persisted.
  Map<String, dynamic> toJson(State state);
}
