import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MultiBlocProvider extends StatelessWidget {
  /// The [BlocProvider] list which is converted into a tree of [BlocProvider] widgets.
  /// The tree of [BlocProvider] widgets is created in order meaning the first [BlocProvider]
  /// will be the top-most [BlocProvider] and the last [BlocProvider] will be a direct ancestor
  /// of the `child` [Widget].
  final List<BlocProvider> providers;

  /// The [Widget] and its descendants which will have access to every [Bloc] provided by `providers`.
  /// This [Widget] will be a direct descendent of the last [BlocProvider] in `providers`.
  final Widget child;

  /// Merges multiple [BlocProvider] widgets into one widget tree.
  ///
  /// [MultiBlocProvider] improves the readability and eliminates the need
  /// to nest multiple [BlocProviders].
  ///
  /// By using [MultiBlocProvider] we can go from:
  ///
  /// ```dart
  /// BlocProvider<BlocA>(
  ///   builder: (BuildContext context) => BlocA(),
  ///   child: BlocProvider<BlocB>(
  ///     builder: (BuildContext context) => BlocB(),
  ///     child: BlocProvider<BlocC>(
  ///       builder: (BuildContext context) => BlocC(),
  ///       child: ChildA(),
  ///     )
  ///   )
  /// )
  /// ```
  ///
  /// to:
  ///
  /// ```dart
  /// MultiBlocProvider(
  ///   providers: [
  ///     BlocProvider<BlocA>(
  ///       builder: (BuildContext context) => BlocA(),
  ///     ),
  ///     BlocProvider<BlocB>(
  ///       builder: (BuildContext context) => BlocB(),
  ///     ),
  ///     BlocProvider<BlocC>(
  ///       builder: (BuildContext context) => BlocC(),
  ///     ),
  ///   ],
  ///   child: ChildA(),
  /// )
  /// ```
  ///
  /// [MultiBlocProvider] converts the [BlocProvider] list
  /// into a tree of nested [BlocProvider] widgets.
  /// As a result, the only advantage of using [MultiBlocProvider] is improved
  /// readability due to the reduction in nesting and boilerplate.
  const MultiBlocProvider({
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
