// ignore: implementation_imports
import 'package:_fe_analyzer_shared/src/parser/parser.dart';
import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_context_extensions}
/// The prefer_context_extensions lint rule.
/// {@endtemplate}
class PreferContextExtensions extends LintRule {
  /// {@macro prefer_context_extensions}
  PreferContextExtensions([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'prefer_context_extensions';

  @override
  Listener? create(LintContext context) {
    return _Listener(context);
  }
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _providers = <String>{
    'BlocProvider',
    'RepositoryProvider',
  };

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    if (token.lexeme == 'of') {
      final prev = token.previous;
      if (prev != null && prev.lexeme == '.') {
        final target = prev.previous;
        if (target != null && _providers.contains(target.lexeme)) {
          context.reportToken(
            token: target,
            message: 'Avoid using ${target.lexeme}.of<T>.',
            hint: 'Prefer using context extensions instead.',
          );
        }
      }
    }
  }
}
