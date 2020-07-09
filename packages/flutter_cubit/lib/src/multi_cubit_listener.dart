import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'cubit_listener.dart';

/// {@template multi_cubit_listener}
/// Merges multiple [CubitListener] widgets into one widget tree.
///
/// [MultiCubitListener] improves the readability and eliminates the need
/// to nest multiple [CubitListener]s.
///
/// By using [MultiCubitListener] we can go from:
///
/// ```dart
/// CubitListener<CubitA, CubitAState>(
///   listener: (context, state) {},
///   child: CubitListener<CubitB, CubitBState>(
///     listener: (context, state) {},
///     child: CubitListener<CubitC, CubitCState>(
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
/// MultiCubitListener(
///   listeners: [
///     CubitListener<CubitA, CubitAState>(
///       listener: (context, state) {},
///     ),
///     CubitListener<CubitB, CubitBState>(
///       listener: (context, state) {},
///     ),
///     CubitListener<CubitC, CubitCState>(
///       listener: (context, state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiCubitListener] converts the [CubitListener] list into a tree of nested
/// [CubitListener] widgets.
/// As a result, the only advantage of using [MultiCubitListener] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiCubitListener extends MultiProvider {
  /// {@macro multi_cubit_listener}
  MultiCubitListener({
    Key key,
    @required List<CubitListenerSingleChildWidget> listeners,
    @required Widget child,
  })  : assert(listeners != null),
        assert(child != null),
        super(key: key, providers: listeners, child: child);
}
