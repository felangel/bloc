import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_lint/src/nested_widget_listener.dart';

/// {@template prefer_multi_bloc_listener}
/// The prefer_multi_bloc_listener lint rule.
/// {@endtemplate}
class PreferMultiBlocListener extends LintRule {
  /// {@macro prefer_multi_bloc_listener}
  PreferMultiBlocListener([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_multi_bloc_listener';

  @override
  Listener? create(LintContext context) => NestedWidgetListener(
    context: context,
    widget: 'BlocListener',
    replacement: 'MultiBlocListener',
  );
}
