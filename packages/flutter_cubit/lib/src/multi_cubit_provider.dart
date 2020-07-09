import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'cubit_provider.dart';

/// {@template multi_cubit_provider}
/// Merges multiple [CubitProvider] widgets into one widget tree.
///
/// [MultiCubitProvider] improves the readability and eliminates the need
/// to nest multiple [CubitProvider]s.
///
/// By using [MultiCubitProvider] we can go from:
///
/// ```dart
/// CubitProvider<CubitA>(
///   create: (BuildContext context) => CubitA(),
///   child: CubitProvider<CubitB>(
///     create: (BuildContext context) => CubitB(),
///     child: CubitProvider<CubitC>(
///       create: (BuildContext context) => CubitC(),
///       child: ChildA(),
///     )
///   )
/// )
/// ```
///
/// to:
///
/// ```dart
/// MultiCubitProvider(
///   providers: [
///     CubitProvider<CubitA>(
///       create: (BuildContext context) => CubitA(),
///     ),
///     CubitProvider<CubitB>(
///       create: (BuildContext context) => CubitB(),
///     ),
///     CubitProvider<CubitC>(
///       create: (BuildContext context) => CubitC(),
///     ),
///   ],
///   child: ChildA(),
/// )
/// ```
///
/// [MultiCubitProvider] converts the [CubitProvider] list into a tree of nested
/// [CubitProvider] widgets.
/// As a result, the only advantage of using [MultiCubitProvider] is improved
/// readability due to the reduction in nesting and boilerplate.
/// {@endtemplate}
class MultiCubitProvider extends MultiProvider {
  /// {@macro multi_cubit_provider}
  MultiCubitProvider({
    Key key,
    @required List<CubitProviderSingleChildWidget> providers,
    @required Widget child,
  })  : assert(providers != null),
        assert(child != null),
        super(key: key, providers: providers, child: child);
}
