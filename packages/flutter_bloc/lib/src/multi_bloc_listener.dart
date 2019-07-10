import 'package:flutter_web/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class MultiBlocListener extends StatelessWidget {
  /// The [BlocListener] list which is converted into a tree of [BlocListener] widgets.
  /// The tree of [BlocListener] widgets is created in order meaning the first [BlocListener]
  /// will be the top-most [BlocListener] and the last [BlocListener] will be a direct ancestor
  /// of the `child` [Widget].
  final List<BlocListener> listeners;

  /// This [Widget] will be a direct descendent of the last [BlocListener] in `listeners`.
  final Widget child;

  /// Merges multiple [BlocListener] widgets into one widget tree.
  ///
  /// [MultiBlocListener] improves the readability and eliminates the need
  /// to nest multiple [BlocListeners].
  ///
  /// By using [MultiBlocListener] we can go from:
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
  /// MutliBlocListener(
  ///   listeners: [
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
  /// [MultiBlocListener] converts the [BlocListener] list
  /// into a tree of nested [BlocListener] widgets.
  /// As a result, the only advantage of using [MultiBlocListener] is improved
  /// readability due to the reduction in nesting and boilerplate.
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
