// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/parser/parser.dart';
import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_build_context_extensions}
/// The prefer_build_context_extensions lint rule.
/// {@endtemplate}
class PreferBuildContextExtensions extends LintRule {
  /// {@macro prefer_build_context_extensions}
  PreferBuildContextExtensions([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'prefer_build_context_extensions';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _providers = <String>{'BlocProvider', 'RepositoryProvider'};

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    if (token.lexeme == 'of') {
      final prev = token.previous;
      if (prev == null) return;
      if (prev.lexeme != '.') return;

      final next = token.next;
      if (next == null) return;

      final target = prev.previous;
      if (target == null) return;
      if (!_providers.contains(target.lexeme)) return;

      context.reportTokenRange(
        beginToken: target,
        endToken: next,
        message: 'Prefer using BuildContext extensions.',
        hint: '''
Avoid using ${target.lexeme}.of<T>.
Use context.read, context.watch, and context.select instead.''',
      );
    }
  }
}
