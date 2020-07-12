import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';

import '../flutter_bloc.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [BlocConsumer] is analogous to a nested `BlocListener`
/// and `BlocBuilder` but reduces the amount of boilerplate needed.
/// [BlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [cubit].
///
/// [BlocConsumer] takes a required `BlocWidgetBuilder`
/// and `BlocWidgetListener` and an optional [cubit],
/// `BlocBuilderCondition`, and `BlocListenerCondition`.
///
/// If the [cubit] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using `BlocProvider` and the current `BuildContext`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
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
/// the [BlocConsumer] is initialized.
/// [listenWhen] and [buildWhen] are optional and if they aren't implemented,
/// they will default to `true`.
///
/// ```dart
/// BlocConsumer<BlocA, BlocAState>(
///   listenWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to invoke listener with state
///   },
///   listener: (context, state) {
///     // do stuff here based on BlocA's state
///   },
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
/// )
/// ```
/// {@endtemplate}
class BlocConsumer<C extends Cubit<S>, S> extends StatelessWidget {
  /// {@macro bloc_consumer}
  const BlocConsumer({
    Key key,
    @required this.builder,
    @required this.listener,
    this.cubit,
    this.buildWhen,
    this.listenWhen,
  })  : assert(builder != null),
        assert(listener != null),
        super(key: key);

  /// The [cubit] that the [BlocConsumer] will interact with.
  /// If omitted, [BlocConsumer] will automatically perform a lookup using
  /// `BlocProvider` and the current `BuildContext`.
  final C cubit;

  /// The [builder] function which will be invoked on each widget build.
  /// The [builder] takes the `BuildContext` and current `state` and
  /// must return a widget.
  /// This is analogous to the [builder] function in [StreamBuilder].
  final BlocWidgetBuilder<S> builder;

  /// Takes the `BuildContext` along with the [cubit] `state`
  /// and is responsible for executing in response to `state` changes.
  final BlocWidgetListener<S> listener;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to trigger
  /// [builder] with the current `state`.
  final BlocBuilderCondition<S> buildWhen;

  /// Takes the previous `state` and the current `state` and is responsible for
  /// returning a [bool] which determines whether or not to call [listener] of
  /// [BlocConsumer] with the current `state`.
  final BlocListenerCondition<S> listenWhen;

  @override
  Widget build(BuildContext context) {
    final cubit = this.cubit ?? context.bloc<C>();
    return BlocListener<C, S>(
      cubit: cubit,
      listener: listener,
      listenWhen: listenWhen,
      child: BlocBuilder<C, S>(
        cubit: cubit,
        builder: builder,
        buildWhen: buildWhen,
      ),
    );
  }
}
