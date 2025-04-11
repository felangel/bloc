import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_public_fields}
/// The avoid_public_fields lint rule.
/// {@endtemplate}
class AvoidPublicFields extends LintRule {
  /// {@macro avoid_public_fields}
  AvoidPublicFields([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_public_fields';

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
    if (staticToken != null) return;

    final fieldName = _getFieldName(beginToken, endToken);
    if (fieldName.lexeme.startsWith('_')) return;

    context.reportTokenRange(
      beginToken: beginToken,
      endToken: endToken,
      message: 'Avoid public fields.',
      hint: 'Prefer using the `state` to hold all public fields.',
    );
  }
}

List<Token> _getTokens(Token begin, Token end) {
  final tokens = <Token>[];
  Token? token = begin;
  while (token != null && token != end) {
    tokens.add(token);
    token = token.next;
  }
  return tokens;
}

Token _getFieldName(Token begin, Token end) {
  final tokens = _getTokens(begin, end);
  final equalsIndex = tokens.indexWhere((token) => token.type == TokenType.EQ);
  if (equalsIndex != -1) return tokens.elementAt(equalsIndex).previous!;
  return end.previous!;
}
