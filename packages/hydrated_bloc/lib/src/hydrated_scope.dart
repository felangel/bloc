import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scope for hydrated storage
class HydratedScope extends InheritedWidget {
  /// token is scope name
  const HydratedScope({
    Key key,
    @required this.token,
    @required Widget child,
  })  : assert(token != null),
        assert(child != null),
        super(key: key, child: child);

  /// scope is defined by it's name
  final String token;

  /// Retrieve scope from context
  static HydratedScope of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<HydratedScope>();
  }

  @override
  bool updateShouldNotify(HydratedScope oldWidget) {
    return oldWidget.token != token;
  }

  /// Adds wrapping hook for now
  static Future<void> config() async {
    BlocProvider.addWrapper((context, create) {
      final token = context.scope()?.token;
      if (token == null) return create;
      return (context) {
        // Hydrated.prepare(token);
        return create(context);
      };
    });
    // await Hydrated.config(configs);
  }
}

/// Extends the `BuildContext` class with the ability
/// to perform a HydratedScope lookup.
extension HydratedScopeExtension on BuildContext {
  /// Retrieve nearest scope from context
  HydratedScope scope() => HydratedScope.of(this);
}
