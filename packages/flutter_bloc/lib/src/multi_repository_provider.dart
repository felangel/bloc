import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'repository_provider.dart';

/// {@template multi_repository_provider}
/// Merges multiple [RepositoryProvider] widgets into one widget tree.
///
/// [MultiRepositoryProvider] improves the readability and eliminates the need
/// to nest multiple [RepositoryProvider]s.
///
/// By using [MultiRepositoryProvider] we can go from:
///
/// ```dart
/// RepositoryProvider<RepositoryA>(
///   create: (context) => RepositoryA(),
///   child: RepositoryProvider<RepositoryB>(
///     create: (context) => RepositoryB(),
///     child: RepositoryProvider<RepositoryC>(
///       create: (context) => RepositoryC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiRepositoryProvider(
///   providers: [
///     RepositoryProvider<RepositoryA>(create: (context) => RepositoryA()),
///     RepositoryProvider<RepositoryB>(create: (context) => RepositoryB()),
///     RepositoryProvider<RepositoryC>(create: (context) => RepositoryC()),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiRepositoryProvider] converts the [RepositoryProvider] list into a tree
/// of nested [RepositoryProvider] widgets.
/// As a result, the only advantage of using [MultiRepositoryProvider] is
/// improved readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiRepositoryProvider extends StatelessWidget {
  /// The [RepositoryProvider] list which is converted into a tree of
  /// [RepositoryProvider] widgets.
  /// The tree of [RepositoryProvider] widgets is created in order meaning
  /// the first [RepositoryProvider] will be the top-most [RepositoryProvider]
  /// and the last [RepositoryProvider] will be a direct ancestor of [child].
  final List<RepositoryProviderSingleChildWidget> providers;

  /// The widget and its descendants which will have access to every value
  /// provided by [providers].
  /// [child] will be a direct descendent of the last [RepositoryProvider] in
  /// [providers].
  final Widget child;

  /// {@macro multi_repository_provider}
  const MultiRepositoryProvider({
    Key key,
    @required this.providers,
    @required this.child,
  })  : assert(providers != null),
        assert(child != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: child,
    );
  }
}
