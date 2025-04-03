import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_mutable_fields}
/// The avoid_mutable_fields lint rule.
/// {@endtemplate}
class AvoidMutableFields extends LintRule {
  /// {@macro avoid_mutable_fields}
  const AvoidMutableFields()
    : super(name: 'avoid_mutable_fields', severity: Severity.warning);

  @override
  Listener? create(LintContext context) {
    if (context.document.type.isOther) return null;
    return _Listener(context);
  }
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  bool _isRelevantEnclosingClass = false;

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
    _isRelevantEnclosingClass = false;

    final extendz = name.next;

    if (extendz == null || extendz.kind != Keyword.EXTENDS.kind) return;

    final superclazz = extendz.next;
    if (superclazz == null) return;

    if (superclazz.lexeme.endsWith('Bloc') ||
        superclazz.lexeme.endsWith('Cubit')) {
      _isRelevantEnclosingClass = true;
    }
    return;
  }

  @override
  void endClassFields(
    Token? abstractToken,
    Token? augmentToken,
    Token? externalToken,
    Token? staticToken,
    Token? covariantToken,
    Token? lateToken,
    Token? varFinalOrConst,
    int count,
    Token beginToken,
    Token endToken,
  ) {
    if (!_isRelevantEnclosingClass) return;
    if (varFinalOrConst == null) return;
    if (varFinalOrConst.keyword != Keyword.VAR) return;
    context.reportTokenRange(
      beginToken: beginToken,
      endToken: endToken,
      message: 'Avoid mutable fields.',
      hint: 'Prefer using the `state` to hold all mutable state.',
    );
  }
}
