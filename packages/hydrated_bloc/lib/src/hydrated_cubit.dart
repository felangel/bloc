import 'dart:async';

import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';

import 'hydrated_bloc.dart';
import 'hydrated_storage.dart';

/// {@template storage_not_found}
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
class StorageNotFound implements Exception {
  /// {@macro storage_not_found}
  const StorageNotFound();

  @override
  String toString() {
    return 'Storage was accessed before it was initialized.\n'
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
    hydrate();
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

/// A mixin which enables automatic state persistence
/// for [Bloc] and [Cubit] classes.
///
/// The [hydrate] method must be invoked in the constructor body
/// when using the [HydratedMixin] directly.
///
/// If a mixin is not necessary, it is recommended to
/// extend [HydratedBloc] and [HydratedCubit] respectively.
///
/// ```dart
/// class CounterBloc extends Bloc<CounterEvent, int> with HydratedMixin {
///  CounterBloc() : super(0) {
///    hydrate();
///  }
///  ...
/// }
/// ```
///
/// See also:
///
/// * [HydratedCubit] to enable automatic state persistence/restoration with [Cubit]
/// * [HydratedBloc] to enable automatic state persistence/restoration with [Bloc]
///
mixin HydratedMixin<State> on Cubit<State> {
  /// Instance of [Storage] which will be used to
  /// manage persisting/restoring the [Cubit] state.
  static Storage storage;

  void hydrate() {
    if (storage == null) throw const StorageNotFound();
    try {
      final stateJson = _toJson(state);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
      }
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
  }

  State _state;

  @override
  State get state {
    if (storage == null) throw const StorageNotFound();
    if (_state != null) return _state;
    try {
      final stateJson = storage.read(storageToken) as Map<dynamic, dynamic>;
      if (stateJson == null) return _state = super.state;
      return _state = fromJson(
        _cast<Map<String, dynamic>>(_traverseRead(stateJson)),
      );
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
      return _state = super.state;
    }
  }

  dynamic _traverseRead(dynamic value) {
    if (value is Map) {
      final map = <String, dynamic>{};
      value.forEach((dynamic key, dynamic value) {
        map[_cast<String>(key)] = _traverseRead(value);
      });
      return map;
    }
    if (value is List) {
      for (var i = 0; i < value.length; i++) {
        value[i] = _traverseRead(value[i]);
      }
    }
    return value;
  }

  T _cast<T>(dynamic x) => x is T ? x : null;

  @override
  void onChange(Change<State> change) {
    if (storage == null) throw const StorageNotFound();
    final state = change.nextState;
    try {
      final stateJson = _toJson(state);
      if (stateJson != null) {
        storage.write(storageToken, stateJson).then((_) {}, onError: onError);
      }
    } on dynamic catch (error, stackTrace) {
      onError(error, stackTrace);
    }
    _state = state;
    super.onChange(change);
  }

  Map<String, dynamic> _toJson(State state) {
    return _cast<Map<String, dynamic>>(_traverseWrite(toJson(state)).value);
  }

  _Traversed _traverseWrite(dynamic value) {
    final dynamic traversedJson = _traverseJson(value);
    if (traversedJson is! NIL) {
      return _Traversed.builtIn(traversedJson);
    }
    try {
      _checkCycle(value);
      final dynamic customJson = _toEncodable(value);
      final dynamic traversedCustomJson = _traverseJson(customJson);
      if (traversedCustomJson is NIL) {
        throw HydratedUnsupportedError(value);
      }
      _removeSeen(value);
      return _Traversed.custom(traversedCustomJson);
    } on HydratedCyclicError catch (e) {
      throw HydratedUnsupportedError(value, cause: e);
    } on HydratedUnsupportedError {
      rethrow; // do not stack `HydratedUnsupportedError`
    } on dynamic catch (e) {
      throw HydratedUnsupportedError(value, cause: e);
    }
  }

  dynamic _traverseJson(dynamic object) {
    if (object is num) {
      if (!object.isFinite) return const NIL();
      return object;
    } else if (identical(object, true)) {
      return true;
    } else if (identical(object, false)) {
      return false;
    } else if (object == null) {
      return null;
    } else if (object is String) {
      return object;
    } else if (object is List) {
      _checkCycle(object);
      List<dynamic> list;
      for (var i = 0; i < object.length; i++) {
        final traversed = _traverseWrite(object[i]);
        list ??= traversed.outcome == _Outcome.builtIn
            ? object.sublist(0)
            : (<dynamic>[]..length = object.length);
        list[i] = traversed.value;
      }
      _removeSeen(object);
      return list;
    } else if (object is Map) {
      _checkCycle(object);
      final map = <String, dynamic>{};
      object.forEach((dynamic key, dynamic value) {
        map[_cast<String>(key)] = _traverseWrite(value).value;
      });
      _removeSeen(object);
      return map;
    }
    return const NIL();
  }

  dynamic _toEncodable(dynamic object) => object.toJson();

  final List _seen = <dynamic>[];

  void _checkCycle(dynamic object) {
    for (var i = 0; i < _seen.length; i++) {
      if (identical(object, _seen[i])) {
        throw HydratedCyclicError(object);
      }
    }
    _seen.add(object);
  }

  void _removeSeen(dynamic object) {
    assert(_seen.isNotEmpty);
    assert(identical(_seen.last, object));
    _seen.removeLast();
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

/// Reports that an object could not be serialized due to cyclic references.
/// When the cycle is detected, a [HydratedCyclicError] is thrown.
class HydratedCyclicError extends HydratedUnsupportedError {
  /// The first object that was detected as part of a cycle.
  HydratedCyclicError(Object object) : super(object);

  @override
  String toString() => 'Cyclic error while state traversing';
}

/// Reports that an object could not be serialized.
/// The [unsupportedObject] field holds object that failed to be serialized.
///
/// If an object isn't directly serializable, the serializer calls the `toJson`
/// method on the object. If that call fails, the error will be stored in the
/// [cause] field. If the call returns an object that isn't directly
/// serializable, the [cause] is null.
class HydratedUnsupportedError extends Error {
  /// The object that failed to be serialized.
  /// Error of attempt to serialize through `toJson` method.
  HydratedUnsupportedError(
    this.unsupportedObject, {
    this.cause,
  });

  /// The object that could not be serialized.
  final Object unsupportedObject;

  /// The exception thrown when trying to convert the object.
  final Object cause;

  @override
  String toString() {
    final safeString = Error.safeToString(unsupportedObject);
    final prefix = cause != null
        ? 'Converting object to an encodable object failed:'
        : 'Converting object did not return an encodable object:';
    return '$prefix $safeString';
  }
}

/// {@template NIL}
/// Type which represents objects that do not support json encoding
///
/// This should never be used and is exposed only for testing purposes.
/// {@endtemplate}
@visibleForTesting
class NIL {
  /// {@macro NIL}
  const NIL();
}

enum _Outcome { builtIn, custom }

class _Traversed {
  _Traversed._({@required this.outcome, @required this.value});
  _Traversed.builtIn(dynamic value)
      : this._(outcome: _Outcome.builtIn, value: value);
  _Traversed.custom(dynamic value)
      : this._(outcome: _Outcome.custom, value: value);
  final _Outcome outcome;
  final dynamic value;
}
