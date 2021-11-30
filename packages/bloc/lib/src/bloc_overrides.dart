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
  static BlocOverrides? get current => Zone.current[_token] as BlocOverrides?;

  /// Runs [body] in a fresh [Zone] using the provided overrides.
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
  BlocObserver get blocObserver => _defaultBlocObserver;

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
  EventTransformer get eventTransformer => _defaultEventTransformer;
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

late final _defaultBlocObserver = _DefaultBlocObserver();
late final _defaultEventTransformer = (Stream events, EventMapper mapper) {
  return events
      .map(mapper)
      .transform<dynamic>(const _FlatMapStreamTransformer<dynamic>());
};

class _DefaultBlocObserver extends BlocObserver {}

class _FlatMapStreamTransformer<T> extends StreamTransformerBase<Stream<T>, T> {
  const _FlatMapStreamTransformer();

  @override
  Stream<T> bind(Stream<Stream<T>> stream) {
    final controller = StreamController<T>.broadcast(sync: true);

    controller.onListen = () {
      final subscriptions = <StreamSubscription<dynamic>>[];

      final outerSubscription = stream.listen(
        (inner) {
          final subscription = inner.listen(
            controller.add,
            onError: controller.addError,
          );

          subscription.onDone(() {
            subscriptions.remove(subscription);
            if (subscriptions.isEmpty) controller.close();
          });

          subscriptions.add(subscription);
        },
        onError: controller.addError,
      );

      outerSubscription.onDone(() {
        subscriptions.remove(outerSubscription);
        if (subscriptions.isEmpty) controller.close();
      });

      subscriptions.add(outerSubscription);

      controller.onCancel = () {
        if (subscriptions.isEmpty) return null;
        final cancels = [for (final s in subscriptions) s.cancel()];
        return Future.wait(cancels).then((_) {});
      };
    };

    return controller.stream;
  }
}
