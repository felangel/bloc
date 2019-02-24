import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// A Flutter [Widget] that merges multiple [BlocProvider] widgets into one widget tree.
///
/// [BlocProviderTree] improves the readability and eliminates the need
/// to nest multiple [BlocProviders].
///
/// By using [BlocProviderTree] we can go from:
///
/// ```dart
/// BlocProvider<BlocA>(
///   bloc: BlocA(),
///   child: BlocProvider<BlocB>(
///     bloc: BlocB(),
///     child: BlocProvider<BlocC>(
///       value: BlocC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// BlocProviderTree(
///   blocProviders: [
///     BlocProvider<BlocA>(bloc: BlocA()),
///     BlocProvider<BlocB>(bloc: BlocB()),
///     BlocProvider<BlocC>(bloc: BlocC()),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [BlocProviderTree] converts the [BlocProvider] list
/// into a tree of nested [BlocProvider] widgets.
/// As a result, the only advantage of using [BlocProviderTree] is improved
/// readability due to the reduction in nesting and boilerplate.
class BlocProviderTree extends StatelessWidget {
  /// The [BlocProvider] list which is converted into a tree of [BlocProvider] widgets.
  /// The tree of [BlocProvider] widgets is created in order meaning the first [BlocProvider]
  /// will be the top-most [BlocProvider] and the last [BlocProvider] will be a direct ancestor
  /// of the `child` [Widget].
  final List<BlocProvider> blocProviders;

  /// The [Widget] and its descendants which will have access to every [Bloc] provided by `blocProviders`.
  /// This [Widget] will be a direct descendent of the last [BlocProvider] in `blocProviders`.
  final Widget child;

  BlocProviderTree({
    Key key,
    @required this.blocProviders,
    @required this.child,
  })  : assert(blocProviders != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget tree = child;
    for (final blocProvider in blocProviders.reversed) {
      tree = blocProvider.copyWith(tree);
    }
    return tree;
  }
}
