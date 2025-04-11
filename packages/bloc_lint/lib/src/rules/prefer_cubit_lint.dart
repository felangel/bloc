import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_cubit}
/// The prefer_cubit lint rule.
/// {@endtemplate}
class PreferCubitLint extends LintRule {
  /// {@macro prefer_cubit}
  PreferCubitLint([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_cubit';

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

    if (superclazz.lexeme.endsWith('Bloc')) {
      final prefix = superclazz.lexeme.split('Bloc').first;
      context.reportToken(
        token: name,
        message: 'Avoid extending ${prefix}Bloc.',
        hint: 'Prefer extending ${prefix}Cubit instead.',
      );
    }
  }
}
