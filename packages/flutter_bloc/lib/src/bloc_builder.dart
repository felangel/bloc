import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import '../flutter_bloc.dart';

/// {@template bloc_builder}
/// [BlocBuilder] handles building a widget in response to new [states].
/// [BlocBuilder] is analogous to [StreamBuilder] but has simplified API to
/// reduce the amount of boilerplate code needed as well as [bloc]-specific
/// performance improvements.

/// Please refer to [BlocListener] if you want to "do" anything in response to
/// [state] changes such as navigation, showing a dialog, etc...
///
/// If the [bloc] parameter is omitted, [BlocBuilder] will automatically
/// perform a lookup using [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// Only specify the [bloc] if you wish to provide a [bloc] that is otherwise
/// not accessible via [BlocProvider] and the current `BuildContext`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   bloc: blocA,
///   builder: (context, state) {
///   // return widget here based on BlocA's state
///   }
/// )
/// ```
///
/// An optional [buildWhen] can be implemented for more granular control over
/// how often [BlocBuilder] rebuilds.
/// [buildWhen] will be invoked on each [cubit] `state` change.
/// [buildWhen] takes the previous `state` and current `state` and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous `state` will be initialized to the `state` of the [bloc] when
/// the [BlocBuilder] is initialized.
/// [buildWhen] is optional and if omitted, it will default to `true`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   buildWhen: (previous, current) {
///     // return true/false to determine whether or not
///     // to rebuild the widget with state
///   },
///   builder: (context, state) {
///     // return widget here based on BlocA's state
///   }
///)
/// ```
/// {@endtemplate}
class BlocBuilder<B extends Bloc<dynamic, S>, S> extends CubitBuilder<B, S> {
  /// {@macro bloc_builder}
  const BlocBuilder({
    Key key,
    @required CubitWidgetBuilder<S> builder,
    B bloc,
    CubitBuilderCondition<S> buildWhen,
  })  : assert(builder != null),
        super(key: key, builder: builder, cubit: bloc, buildWhen: buildWhen);
}
