import 'package:flutter_web/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MultiRepositoryProvider extends StatelessWidget {
  /// The [RepositoryProvider] list which is converted into a tree of [RepositoryProvider] widgets.
  /// The tree of [RepositoryProvider] widgets is created in order meaning the first [RepositoryProvider]
  /// will be the top-most [RepositoryProvider] and the last [RepositoryProvider] will be a direct ancestor
  /// of the `child` [Widget].
  final List<RepositoryProvider> providers;

  /// The [Widget] and its descendants which will have access to every value provided by `providers`.
  /// This [Widget] will be a direct descendent of the last [RepositoryProvider] in `providers`.
  final Widget child;

  /// Merges multiple [RepositoryProvider] widgets into one widget tree.
  ///
  /// [MultiRepositoryProvider] improves the readability and eliminates the need
  /// to nest multiple [RepositoryProviders].
  ///
  /// By using [MultiRepositoryProvider] we can go from:
  ///
  /// ```dart
  /// RepositoryProvider<RepositoryA>(
  ///   builder: (context) => RepositoryA(),
  ///   child: RepositoryProvider<RepositoryB>(
  ///     builder: (context) => RepositoryB(),
  ///     child: RepositoryProvider<RepositoryC>(
  ///       builder: (context) => RepositoryC(),
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
  ///     RepositoryProvider<RepositoryA>(builder: (context) => RepositoryA()),
  ///     RepositoryProvider<RepositoryB>(builder: (context) => RepositoryB()),
  ///     RepositoryProvider<RepositoryC>(builder: (context) => RepositoryC()),
  ///   ],
  ///   child: ChildA(),
  /// )
  /// ```
  ///
  /// [MultiRepositoryProvider] converts the [RepositoryProvider] list
  /// into a tree of nested [RepositoryProvider] widgets.
  /// As a result, the only advantage of using [MultiRepositoryProvider] is improved
  /// readability due to the reduction in nesting and boilerplate.
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
