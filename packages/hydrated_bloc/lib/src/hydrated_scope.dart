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
      final token = HydratedScope.of(context)?.token;
      if (token == null) return create;
      return (context) {
        // Hydrated.prepare(token);
        // HydratedMixin.storage = ;
        return create(context);
      };
    });
    // await Hydrated.config(configs);
  }
}
