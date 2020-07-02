import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import '../flutter_bloc.dart';

/// {@template bloc_consumer}
/// [BlocConsumer] exposes a [builder] and [listener] in order react to new
/// states.
/// [BlocConsumer] is analogous to a nested [BlocListener] and [BlocBuilder] but
/// reduces the amount of boilerplate needed.
/// [BlocConsumer] should only be used when it is necessary to both rebuild UI
/// and execute other reactions to state changes in the [bloc].
///
/// [BlocConsumer] takes a required [BlocWidgetBuilder] and [BlocWidgetListener]
/// and an optional [bloc], [BlocBuilderCondition], and [BlocListenerCondition].
///
/// If the [bloc] parameter is omitted, [BlocConsumer] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
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
/// The [listenWhen] and [buildWhen] will be invoked on each [bloc] [state]
/// change.
/// They each take the previous [state] and current [state] and must return
/// a [bool] which determines whether or not the [builder] and/or [listener]
/// function will be invoked.
/// The previous [state] will be initialized to the [state] of the [bloc] when
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
class BlocConsumer<B extends Bloc<dynamic, S>, S> extends CubitConsumer<B, S> {
  /// {@macro bloc_consumer}
  const BlocConsumer({
    Key key,
    @required CubitWidgetBuilder<S> builder,
    @required CubitWidgetListener<S> listener,
    B bloc,
    CubitBuilderCondition<S> buildWhen,
    CubitListenerCondition<S> listenWhen,
  })  : assert(builder != null),
        assert(listener != null),
        super(
          key: key,
          builder: builder,
          listener: listener,
          cubit: bloc,
          buildWhen: buildWhen,
          listenWhen: listenWhen,
        );
}
