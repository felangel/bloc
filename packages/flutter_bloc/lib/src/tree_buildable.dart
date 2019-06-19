import 'package:flutter/widgets.dart';

import 'copyable.dart';

/// [TreeBuildable] converts the [Copyable] list
/// into a tree of nested [Copyable] widgets.
/// As a result, the only advantage of using [TreeBuildable] is improved
/// readability due to the reduction in nesting and boilerplate.
class TreeBuildable<T extends Copyable> extends StatelessWidget {
  /// The [Copyable] list which is converted into a tree of [Copyable] widgets.
  /// The tree of [Copyable] widgets is created in order meaning the first [Copyable]
  /// will be the top-most [Copyable] and the last [Copyable] will be a direct ancestor
  /// of the `child` [Widget].
  final List<T> copyables;

  /// This [Widget] will be a direct descendent of the last [Copyable] in `Copyables`.
  final Widget child;

  const TreeBuildable({
    Key key,
    @required this.copyables,
    @required this.child,
  })  : assert(copyables != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final copyable in copyables.reversed) {
      tree = copyable.copyWith(tree);
    }
    return tree;
  }
}
