// ignore_for_file: deprecated_member_use_from_same_package

part of 'bloc.dart';

const _asyncRunZoned = runZoned;

/// This class facilitates overriding [BlocObserver] and [EventTransformer].
/// It should be extended by another class in client code with overrides
/// that construct a custom implementation. The implementation in this class
/// defaults to the base [blocObserver] and [eventTransformer] implementation.
/// For example:
///
/// ```dart
/// class MyBlocObserver extends BlocObserver {
///   ...
///   // A custom BlocObserver implementation.
///   ...
/// }
///
/// void main() {
///   BlocOverrides.runZoned(() {
///     ...
///     // Bloc instances will use MyBlocObserver instead of the default BlocObserver.
///     ...
///   }, blocObserver: MyBlocObserver());
/// }
/// ```
abstract class BlocOverrides {
  static final _token = Object();

  /// Returns the current [BlocOverrides] instance.
  ///
  /// This will return `null` if the current [Zone] does not contain
  /// any [BlocOverrides].
  ///
  /// See also:
  /// * [BlocOverrides.runZoned] to provide [BlocOverrides] in a fresh [Zone].
  ///
  @Deprecated(
    'This will be removed in v9.0.0. Use Bloc.observer/Bloc.transformer instead.',
  )
  static BlocOverrides? get current => Zone.current[_token] as BlocOverrides?;

  /// Runs [body] in a fresh [Zone] using the provided overrides.
  @Deprecated(
    'This will be removed in v9.0.0. Use Bloc.observer/Bloc.transformer instead.',
  )
  static R runZoned<R>(
    R Function() body, {
    BlocObserver? blocObserver,
    EventTransformer? eventTransformer,
  }) {
    final overrides = _BlocOverridesScope(blocObserver, eventTransformer);
    return _asyncRunZoned(body, zoneValues: {_token: overrides});
  }

  /// The [BlocObserver] that will be used within the current [Zone].
  ///
  /// By default, a base [BlocObserver] implementation is used.
  @Deprecated('This will be removed in v9.0.0. Use Bloc.observer instead.')
  BlocObserver get blocObserver => Bloc.observer;

  /// The [EventTransformer] that will be used within the current [Zone].
  ///
  /// By default, all events are processed concurrently.
  ///
  /// If a custom transformer is specified for a particular event handler,
  /// it will take precendence over the global transformer.
  ///
  /// See also:
  ///
  /// * [package:bloc_concurrency](https://pub.dev/packages/bloc_concurrency) for an
  /// opinionated set of event transformers.
  ///
  @Deprecated('This will be removed in v9.0.0. Use Bloc.transformer instead.')
  EventTransformer get eventTransformer => Bloc.transformer;
}

class _BlocOverridesScope extends BlocOverrides {
  _BlocOverridesScope(this._blocObserver, this._eventTransformer);

  final BlocOverrides? _previous = BlocOverrides.current;
  final BlocObserver? _blocObserver;
  final EventTransformer? _eventTransformer;

  @override
  BlocObserver get blocObserver {
    final blocObserver = _blocObserver;
    if (blocObserver != null) return blocObserver;

    final previous = _previous;
    if (previous != null) return previous.blocObserver;

    return super.blocObserver;
  }

  @override
  EventTransformer get eventTransformer {
    final eventTransformer = _eventTransformer;
    if (eventTransformer != null) return eventTransformer;

    final previous = _previous;
    if (previous != null) return previous.eventTransformer;

    return super.eventTransformer;
  }
}
