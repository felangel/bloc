import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_lint/src/nested_widget_listener.dart';

/// {@template prefer_multi_repository_provider}
/// The prefer_multi_repository_provider lint rule.
/// {@endtemplate}
class PreferMultiRepositoryProvider extends LintRule {
  /// {@macro prefer_multi_repository_provider}
  PreferMultiRepositoryProvider([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_multi_repository_provider';

  @override
  Listener? create(LintContext context) => NestedWidgetListener(
    context: context,
    widget: 'RepositoryProvider',
    replacement: 'MultiRepositoryProvider',
  );
}
