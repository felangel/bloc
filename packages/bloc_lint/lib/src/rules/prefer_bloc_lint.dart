import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_bloc}
/// The prefer_bloc lint rule.
/// {@endtemplate}
class PreferBlocLint extends LintRule {
  /// {@macro prefer_bloc}
  PreferBlocLint([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_bloc';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  @override
  void beginClassDeclaration(
    Token begin,
    Token? abstractToken,
    Token? macroToken,
    Token? sealedToken,
    Token? baseToken,
    Token? interfaceToken,
    Token? finalToken,
    Token? augmentToken,
    Token? mixinToken,
    Token name,
  ) {
    final extendz = name.next;

    if (extendz == null || extendz.kind != Keyword.EXTENDS.kind) return;

    final superclazz = extendz.next;
    if (superclazz == null) return;

    if (superclazz.lexeme.endsWith('Cubit')) {
      final prefix = superclazz.lexeme.split('Cubit').first;
      context.reportToken(
        token: name,
        message: 'Avoid extending ${prefix}Cubit.',
        hint: 'Prefer extending ${prefix}Bloc instead.',
      );
    }
  }
}
