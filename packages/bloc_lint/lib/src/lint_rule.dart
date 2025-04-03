import 'package:bloc_lint/bloc_lint.dart';

/// {@template lint_rule}
/// An individual lint rule.
/// {@endtemplate}
abstract class LintRule {
  /// {@macro lint_rule}
  const LintRule({required this.name, required this.severity});

  /// The unique name of the rule.
  final String name;

  /// The severity of the rule.
  final Severity severity;

  /// Method that must be implemented which returns a listener
  /// given a [LintContext].
  Listener? create(LintContext context);
}
