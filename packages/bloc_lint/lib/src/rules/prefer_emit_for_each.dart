import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_emit_for_each}
/// The prefer_emit_for_each lint rule.
/// {@endtemplate}
class PreferEmitForEach extends LintRule {
  /// {@macro prefer_emit_for_each}
  PreferEmitForEach([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_emit_for_each';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;
  bool _isBloc = false;

  @override
  void handleClassExtends(Token? extendsKeyword, int typeCount) {
    final name = _unprefixed(extendsKeyword?.next)?.lexeme;
    _isBloc =
        name != null && name.endsWith('Bloc') && !name.endsWith('MockBloc');
  }

  @override
  void endFields(
    DeclarationKind kind,
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
    if (!_isBloc ||
        kind != DeclarationKind.Class ||
        staticToken != null ||
        abstractToken != null ||
        externalToken != null) {
      return;
    }

    var token = beginToken;
    while (token.isModifier) {
      token = token.next!;
    }
    final type = _unprefixed(token);
    if (type == null || type.lexeme != 'StreamSubscription') return;

    // A function returning a subscription is not itself a subscription.
    var name = type.next;
    if (name?.type == TokenType.LT) name = name?.endGroup?.next;
    if (name?.type == TokenType.QUESTION) name = name?.next;
    if (name?.isIdentifier != true || name?.lexeme == 'Function') return;

    context.reportToken(
      token: type,
      message: 'Avoid storing a stream subscription in a bloc.',
      hint: 'Consider using `emit.forEach` in an event handler.',
    );
  }

  static Token? _unprefixed(Token? token) {
    return token?.next?.type == TokenType.PERIOD ? token?.next?.next : token;
  }
}
