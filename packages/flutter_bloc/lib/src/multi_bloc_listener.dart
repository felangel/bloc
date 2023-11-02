import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/src/bloc_listener.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// {@template multi_bloc_listener}
/// Merges multiple [BlocListener] widgets into one widget tree.
///
/// [MultiBlocListener] improves the readability and eliminates the need
/// to nest multiple [BlocListener]s.
///
/// By using [MultiBlocListener] we can go from:
///
/// ```dart
/// BlocListener<BlocA, BlocAState>(
///   listener: (context, state) {},
///   child: BlocListener<BlocB, BlocBState>(
///     listener: (context, state) {},
///     child: BlocListener<BlocC, BlocCState>(
///       listener: (context, state) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiBlocListener(
///   listeners: [
///     BlocListener<BlocA, BlocAState>(
///       listener: (context, state) {},
///     ),
///     BlocListener<BlocB, BlocBState>(
///       listener: (context, state) {},
///     ),
///     BlocListener<BlocC, BlocCState>(
///       listener: (context, state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiBlocListener] converts the [BlocListener] list into a tree of nested
/// [BlocListener] widgets.
/// As a result, the only advantage of using [MultiBlocListener] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiBlocListener extends MultiProvider {
  /// {@macro multi_bloc_listener}
  MultiBlocListener({
    required List<SingleChildWidget> listeners,
    required Widget child,
    Key? key,
  }) : super(key: key, providers: listeners, child: child);
}
