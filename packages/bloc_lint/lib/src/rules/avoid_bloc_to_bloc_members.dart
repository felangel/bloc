import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_bloc_to_bloc_members}
/// The avoid_bloc_to_bloc_members lint rule.
/// {@endtemplate}
class AvoidBlocToBlocMembers extends LintRule {
  /// {@macro avoid_bloc_to_bloc_members}
  AvoidBlocToBlocMembers([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_bloc_to_bloc_members';

  @override
  Listener? create(LintContext context) => _Listener(context);
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

    if (_isBlocLike(superclazz)) {
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
    if (!_isBlocLike(fieldName)) return;

    context.reportTokenRange(
      beginToken: beginToken,
      endToken: endToken,
      message: 'Avoid bloc or cubit members of blocs or cubits.',
      hint: 'Prefer pushing the problem into the presentation or domain layer.',
    );
  }

  @override
  void endFormalParameter(
    Token? thisKeyword,
    Token? superKeyword,
    Token? periodAfterThisOrSuper,
    Token nameToken,
    Token? initializerStart,
    Token? initializerEnd,
    FormalParameterKind kind,
    MemberKind memberKind,
  ) {
    if (!_isRelevantEnclosingClass) return;

    final typeAnnotation = _getParameterTypeAnnotation(nameToken);
    if (typeAnnotation == null) return;
    if (!_isBlocLike(typeAnnotation)) return;

    context.reportTokenRange(
      beginToken: typeAnnotation,
      endToken: nameToken,
      message: 'Avoid bloc or cubit members of blocs or cubits.',
      hint: 'Prefer pushing the problem into the presentation or domain layer.',
    );
  }
}

bool _isBlocLike(Token token) =>
    token.lexeme.endsWith('Bloc') || token.lexeme.endsWith('Cubit');

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

Token? _getParameterTypeAnnotation(Token? formalParameter) {
  final previous = formalParameter?.previous;
  if (previous?.type == TokenType.QUESTION) {
    // FooBloc? foo
    // ^^^^^^^
    return previous?.previous;
  }
  // FooBloc foo
  // ^^^^^^^
  return previous;
}
