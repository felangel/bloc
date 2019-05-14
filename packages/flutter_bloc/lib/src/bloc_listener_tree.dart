import 'package:flutter_web/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A Flutter [Widget] that merges multiple [BlocListener] widgets into one widget tree.
///
/// [BlocListenerTree] improves the readability and eliminates the need
/// to nest multiple [BlocListeners].
///
/// By using [BlocListenerTree] we can go from:
///
/// ```dart
/// BlocListener<BlocAEvent, BlocAState>(
///   bloc: BlocA(),
///   listener: (BuildContext context, BlocAState state) {},
///   child: BlocListener<BlocBEvent, BlocBState>(
///     bloc: BlocB(),
///     listener: (BuildContext context, BlocBState state) {},
///     child: BlocListener<BlocCEvent, BlocCState>(
///       bloc: BlocC(),
///       listener: (BuildContext context, BlocCState state) {},
///       child: ChildA(),
///     ),
///   ),
/// )
/// ```
///
/// to:
///
/// ```dart
/// BlocListenerTree(
///   blocListeners: [
///     BlocListener<BlocAEvent, BlocAState>(
///       bloc: BlocA(),
///       listener: (BuildContext context, BlocAState state) {},
///     ),
///     BlocListener<BlocBEvent, BlocBState>(
///       bloc: BlocB(),
///       listener: (BuildContext context, BlocBState state) {},
///     ),
///     BlocListener<BlocCEvent, BlocCState>(
///       bloc: BlocC(),
///       listener: (BuildContext context, BlocCState state) {},
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [BlocListenerTree] converts the [BlocListener] list
/// into a tree of nested [BlocListener] widgets.
/// As a result, the only advantage of using [BlocListenerTree] is improved
/// readability due to the reduction in nesting and boilerplate.
class BlocListenerTree extends StatelessWidget {
  /// The [BlocListener] list which is converted into a tree of [BlocListener] widgets.
  /// The tree of [BlocListener] widgets is created in order meaning the first [BlocListener]
  /// will be the top-most [BlocListener] and the last [BlocListener] will be a direct ancestor
  /// of the `child` [Widget].
  final List<BlocListener> blocListeners;

  /// This [Widget] will be a direct descendent of the last [BlocListener] in `blocListeners`.
  final Widget child;

  const BlocListenerTree({
    Key key,
    @required this.blocListeners,
    @required this.child,
  })  : assert(blocListeners != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocListener in blocListeners.reversed) {
      tree = blocListener.copyWith(tree);
    }
    return tree;
  }
}
