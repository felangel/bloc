import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

/// {@template bloc_observer}
/// An interface for observing the behavior of [Bloc] instances.
/// {@endtemplate}
abstract class BlocObserver {
  /// {@macro bloc_observer}
  const BlocObserver();

  /// Called whenever a [Bloc] is instantiated.
  /// In many cases, a cubit may be lazily instantiated and
  /// [onCreate] can be used to observe exactly when the cubit
  /// instance is created.
  @protected
  @mustCallSuper
  void onCreate(BlocBase<dynamic> bloc) {}

  /// Called whenever an [event] is `added` to any [bloc] with the given [bloc]
  /// and [event].
  @protected
  @mustCallSuper
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {}

  /// Called whenever a [Change] occurs in any [bloc]
  /// A [change] occurs when a new state is emitted.
  /// [onChange] is called before a bloc's state has been updated.
  @protected
  @mustCallSuper
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {}

  /// Called whenever a transition occurs in any [bloc] with the given [bloc]
  /// and [transition].
  /// A [transition] occurs when a new `event` is added
  /// and a new state is `emitted` from a corresponding [EventHandler].
  /// [onTransition] is called before a [bloc]'s state has been updated.
  @protected
  @mustCallSuper
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {}

  /// Called whenever an [error] is thrown in any [Bloc] or [Cubit].
  /// The [stackTrace] argument may be [StackTrace.empty] if an error
  /// was received without a stack trace.
  @protected
  @mustCallSuper
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {}

  /// Called whenever an [event] handler for a specific [bloc] has completed.
  /// This may include an [error] and [stackTrace] if an uncaught exception
  /// occurred within the event handler.
  @protected
  @mustCallSuper
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {}

  /// Called whenever a [Bloc] is closed.
  /// [onClose] is called just before the [Bloc] is closed
  /// and indicates that the particular instance will no longer
  /// emit new states.
  @protected
  @mustCallSuper
  void onClose(BlocBase<dynamic> bloc) {}
}

/// {@template multi_bloc_observer}
/// A [BlocObserver] which supports registering multiple [BlocObserver]
/// instances. This is useful when maintaining multiple [BlocObserver] instances
/// for different functions e.g. `LoggingBlocObserver`,
/// `ErrorReportingBlocObserver`.
///
/// ```dart
/// Bloc.observer = MultiBlocObserver(
///   observers: [
///     LoggingObserver(),
///     ErrorObserver(),
///     PerformanceObserver(),
///   ],
/// );
/// ```
/// {@endtemplate}
class MultiBlocObserver implements BlocObserver {
  /// {@macro multi_bloc_observer}
  const MultiBlocObserver({required this.observers});

  /// The list of [BlocObserver] instances that will be registered. Observers
  /// are notified of all lifecycle events in the same order that they are
  /// specified.
  final List<BlocObserver> observers;

  @override
  void onCreate(BlocBase<dynamic> bloc) {
    for (final observer in observers) {
      observer.onCreate(bloc);
    }
  }

  @override
  void onEvent(Bloc<dynamic, dynamic> bloc, Object? event) {
    for (final observer in observers) {
      observer.onEvent(bloc, event);
    }
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    for (final observer in observers) {
      observer.onChange(bloc, change);
    }
  }

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    for (final observer in observers) {
      observer.onTransition(bloc, transition);
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    for (final observer in observers) {
      observer.onError(bloc, error, stackTrace);
    }
  }

  @override
  void onDone(
    Bloc<dynamic, dynamic> bloc,
    Object? event, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    for (final observer in observers) {
      observer.onDone(bloc, event, error, stackTrace);
    }
  }

  @override
  void onClose(BlocBase<dynamic> bloc) {
    for (final observer in observers) {
      observer.onClose(bloc);
    }
  }
}
