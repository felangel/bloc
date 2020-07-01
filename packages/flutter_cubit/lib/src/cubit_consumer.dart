import 'package:cubit/cubit.dart';
import 'package:flutter/widgets.dart';

import '../flutter_cubit.dart';

/// {@template cubit_consumer}
/// [CubitConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [CubitConsumer] is analogous to a nested `CubitListener`
/// and `CubitBuilder` but reduces the amount of boilerplate needed.
/// [CubitConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [cubit].
///
/// [CubitConsumer] takes a required `CubitWidgetBuilder`
/// and `CubitWidgetListener` and an optional [cubit],
/// `CubitBuilderCondition`, and `CubitListenerCondition`.
///
/// If the [cubit] parameter is omitted, [CubitConsumer] will automatically
/// perform a lookup using `CubitProvider` and the current `BuildContext`.
///
/// ```dart
/// CubitConsumer<CubitA, CubitAState>(
///   listener: (context, state) {
///     // do stuff here based on CubitA's state
///   },
///   builder: (context, state) {
///     // return widget here based on CubitA's state
///   }
/// )
/// ```
///
/// An optional [listenWhen] and [buildWhen] can be implemented for more
/// granular control over when [listener] and [builder] are called.
/// The [listenWhen] and [buildWhen] will be invoked on each [cubit] `state`
/// change.
/// They each take the previous `state` and current `state` and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous `state` will be initialized to the `state` of the [cubit] when
/// the [CubitConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// CubitConsumer<CubitA, CubitAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on CubitA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on CubitA's state
///   }
/// )
/// ```
/// {@endtemplate}
class CubitConsumer<C extends CubitStream<S>, S> extends StatelessWidget {
  /// {@macro cubit_consumer}
  const CubitConsumer({
    Key key,
    @required this.builder,
    @required this.listener,
    this.cubit,
    this.buildWhen,
    this.listenWhen,
  })  : assert(builder != null),
        assert(listener != null),
        super(key: key);

  /// The [cubit] that the [CubitConsumer] will interact with.
  /// If omitted, [CubitConsumer] will automatically perform a lookup using
  /// `CubitProvider` and the current `BuildContext`.
  final C cubit;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final CubitWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [cubit] `state`
  /// and is responsible for executing in response to `state` changes.
  final CubitWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final CubitBuilderCondition<S> buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [CubitConsumer] with the current `state`.
  final CubitListenerCondition<S> listenWhen;

  @override
  Widget build(BuildContext context) {
    final cubit = this.cubit ?? context.cubit<C>();
    return CubitListener<C, S>(
      cubit: cubit,
      listener: listener,
      listenWhen: listenWhen,
      child: CubitBuilder<C, S>(
        cubit: cubit,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }
}
