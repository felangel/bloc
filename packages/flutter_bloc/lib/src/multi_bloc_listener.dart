import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'bloc_listener.dart';

/// {@template multibloclistener}
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
/// MutliBlocListener(
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
class MultiBlocListener extends StatelessWidget {
  /// The [BlocListener] list which is converted into a tree of [BlocListener]
  /// widgets.
  /// The tree of [BlocListener] widgets is created in order meaning the first
  /// [BlocListener] will be the top-most [BlocListener] and the last
  /// [BlocListener] will be a direct ancestor of [child].
  final List<BlocListenerSingleChildWidget> listeners;

  /// The widget which will be a direct descendent of the last [BlocListener]
  /// in [listeners].
  final Widget child;

  /// {@macro multibloclistener}
  const MultiBlocListener({
    Key key,
    @required this.listeners,
    @required this.child,
  })  : assert(listeners != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: listeners,
      child: child,
    );
  }
}
