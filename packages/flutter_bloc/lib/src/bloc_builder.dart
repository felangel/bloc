import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

import '../flutter_bloc.dart';

/// {@template blocbuilder}
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
/// An optional [condition] can be implemented for more granular control over
/// how often [BlocBuilder] rebuilds.
/// The [condition] function will be invoked on each [bloc] [state] change.
/// The [condition] takes the previous [state] and current [state] and must
/// return a [bool] which determines whether or not the [builder] function will
/// be invoked.
/// The previous [state] will be initialized to the [state] of the [bloc] when
/// the [BlocBuilder] is initialized.
/// [condition] is optional and if it isn't implemented, it will default to
/// `true`.
///
/// ```dart
/// BlocBuilder<BlocA, BlocAState>(
///   condition: (previous, current) {
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
  /// {@macro blocbuilder}
  const BlocBuilder({
    Key key,
    @required CubitWidgetBuilder<S> builder,
    B bloc,
    CubitBuilderCondition<S> condition,
  })  : assert(builder != null),
        super(key: key, builder: builder, cubit: bloc, condition: condition);
}
