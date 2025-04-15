import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';

/// [ConcurrencyEventHandler] mixin provides different concurrency handling
/// strategie options for event processing in a [Bloc].
///
/// This mixin extends a `Bloc<E, S>` and allows handling events with different
/// concurrency strategies:
///
/// - **Sequential:** events are handled one after another in sequence
/// - **Concurrent:** events to be handled concurrently
/// - **Droppable:** Drops incoming events if a prev event is still in processed
/// - **Restartable:** Cancels the ongoing event and restarts a new one arrives
///
/// Usage:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with ConcurrencyEventHandler {
///   MyBloc() : super(InitialState()) {
///     onSequential<MyEventA>(_mySquentialFunc);
///     onConcurrent<MyEventB>(_myConcurrentFunc);
///   }
/// }
/// ```
///
/// **Note:** The mixin `ConcurrencyEventHandler` does not require generic type
/// parameters when used, as it automatically inherits the types
/// from `Bloc<E, S>`. `ConcurrencyEventHandler<MyEvent, MyState>` is
/// unnecessary because `MyBloc extends Bloc<MyEvent, MyState>` already
/// provides the required types.
mixin ConcurrencyEventHandler<E, S> on Bloc<E, S> {
  /// Handles events sequentially, ensuring that each event is processed
  /// one after the other, in order.
  void onSequential<T extends E>(
    FutureOr<void> Function(T, Emitter<S>) handler,
  ) {
    on<T>(handler, transformer: sequential());
  }

  /// Handles events concurrently, allowing multiple instances of the event
  /// to be processed simultaneously.
  void onConcurrent<T extends E>(
    FutureOr<void> Function(T, Emitter<S>) handler,
  ) {
    on<T>(handler, transformer: concurrent());
  }

  /// Handles events in a droppable manner, meaning any events added while an
  /// event is processing will be ignored.
  void onDroppable<T extends E>(
    FutureOr<void> Function(T, Emitter<S>) handler,
  ) {
    on<T>(handler, transformer: droppable());
  }

  /// Handles events in a restartable manner, meaning only the latest event gets
  /// handeled and previous events will be cancled.
  void onRestartable<T extends E>(
    FutureOr<void> Function(T, Emitter<S>) handler,
  ) {
    on<T>(handler, transformer: restartable());
  }
}
