import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'tree_buildable.dart';

/// A Flutter [Widget] that merges multiple [ImmutableProvider] widgets into one widget tree.
///
/// [ImmutableProviderTree] improves the readability and eliminates the need
/// to nest multiple [ImmutableProviders].
///
/// By using [ImmutableProviderTree] we can go from:
///
/// ```dart
/// ImmutableProvider<ValueA>(
///   value: ValueA(),
///   child: ImmutableProvider<ValueB>(
///     value: ValueB(),
///     child: ImmutableProvider<ValueC>(
///       value: ValueC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// ImmutableProviderTree(
///   immutableProviders: [
///     ImmutableProvider<ValueA>(value: ValueA()),
///     ImmutableProvider<ValueB>(value: ValueB()),
///     ImmutableProvider<ValueC>(value: ValueC()),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [ImmutableProviderTree] converts the [ImmutableProvider] list
/// into a tree of nested [ImmutableProvider] widgets.
/// As a result, the only advantage of using [ImmutableProviderTree] is improved
/// readability due to the reduction in nesting and boilerplate.
class ImmutableProviderTree extends TreeBuildable<ImmutableProvider> {
  /// The [ImmutableProvider] list which is converted into a tree of [ImmutableProvider] widgets.
  /// The tree of [ImmutableProvider] widgets is created in order meaning the first [ImmutableProvider]
  /// will be the top-most [ImmutableProvider] and the last [ImmutableProvider] will be a direct ancestor
  /// of the `child` [Widget].
  final List<ImmutableProvider> immutableProviders;

  /// The [Widget] and its descendants which will have access to every value provided by `immutableProviders`.
  /// This [Widget] will be a direct descendent of the last [ImmutableProvider] in `immutableProviders`.
  final Widget child;

  const ImmutableProviderTree({
    Key key,
    @required this.immutableProviders,
    @required this.child,
  }) : super(key: key, copyables: immutableProviders, child: child);
}
