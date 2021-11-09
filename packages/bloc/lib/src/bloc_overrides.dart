import 'dart:async';

import 'package:bloc/bloc.dart';

const _asyncRunZoned = runZoned;

final _blocOverridesToken = Object();

class _BlocOverridesScope implements BlocOverrides {
  _BlocOverridesScope(this._blocObserver, this._eventTransformer);

  final BlocOverrides _previous = BlocOverrides.current;
  final BlocObserver? _blocObserver;
  final EventTransformer? _eventTransformer;

  @override
  BlocObserver get blocObserver {
    return _blocObserver ?? _previous.blocObserver;
  }

  @override
  EventTransformer get eventTransformer {
    return _eventTransformer ?? _previous.eventTransformer;
  }
}

/// This class facilitates overriding [BlocObserver] and [EventTransformer].
/// It should be extended by another class in client code with overrides
/// that construct a custom implementation. The implementation in this class
/// defaults to the base [blocObserver] and [eventTransformer] implementation.
/// For example:
///
/// ```dart
/// class MyBlocObserver implements BlocObserver {
///   ...
///   // An implementation of the BlocObserver interface
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
class BlocOverrides {
  BlocOverrides._();

  /// Returns the current [BlocOverrides] instance.
  static BlocOverrides get current {
    return Zone.current[_blocOverridesToken] as BlocOverrides? ??
        _defaultBlocOverrides;
  }

  /// Runs [body] in a fresh [Zone] using the provided overrides.
  static R runZoned<R>(
    R body(), {
    BlocObserver? blocObserver,
    EventTransformer? eventTransformer,
  }) {
    final overrides = _BlocOverridesScope(blocObserver, eventTransformer);
    return _asyncRunZoned(body, zoneValues: {_blocOverridesToken: overrides});
  }

  static final _defaultBlocOverrides = BlocOverrides._();

  static final _defaultBlocObserver = BlocObserver();

  static final _defaultEventTransformer = (Stream events, EventMapper mapper) {
    return events
        .map(mapper)
        .transform<dynamic>(const _FlatMapStreamTransformer<dynamic>());
  };

  /// The default [BlocObserver] instance.
  BlocObserver get blocObserver => _defaultBlocObserver;

  /// The default [EventTransformer] used for all event handlers.
  /// By default all events are processed concurrently.
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
