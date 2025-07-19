import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_void_public_cubit_methods}
/// The prefer_void_public_cubit_methods lint rule.
/// {@endtemplate}
class PreferVoidPublicCubitMethods extends LintRule {
  /// {@macro prefer_void_public_cubit_methods}
  PreferVoidPublicCubitMethods([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'prefer_void_public_cubit_methods';

  @override
  Listener? create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  var _isOverride = false;

  static const allowedReturnTypes = ['void', 'Future<void>', 'FutureOr<void>'];

  @override
  void beginMetadata(Token token) {
    _isOverride = token.next?.lexeme == 'override';
  }

  @override
  void beginMethod(
    DeclarationKind declarationKind,
    Token? augmentToken,
    Token? externalToken,
    Token? staticToken,
    Token? covariantToken,
    Token? varFinalOrConst,
    Token? getOrSet,
    Token name,
    String? enclosingDeclarationName,
  ) {
    if (declarationKind != DeclarationKind.Class) return;
    if (_isOverride || staticToken != null) return;
    if (!(enclosingDeclarationName?.endsWith('Cubit') ?? false)) {
      return;
    }
    if (name.previous?.type == Keyword.SWITCH) return;
    final methodName = name.lexeme;
    if (enclosingDeclarationName == methodName) return;
    if (methodName.startsWith('_')) return;
    if (getOrSet?.keyword == Keyword.SET) return;
    if (allowedReturnTypes.contains(_getReturnType(getOrSet ?? name))) return;
    context.reportToken(
      token: name,
      message: '''
Prefer void public methods on cubit instances.
Try adjusting the return type to `void`, `Future<void>`, or `FutureOr<void>`.''',
      hint: 'Prefer `void` return types.',
    );
  }
}

String _getReturnType(Token name) {
  const dynamic = 'dynamic';
  final previous = name.previous;
  if (previous == null) return dynamic;
  if (previous.type != TokenType.GT) return previous.lexeme;

  var bracketCount = 0;
  final chars = <String>[];
  Token? current = previous;

  bool isDone() {
    if (current == null) return true;
    if (bracketCount <= 0) return true;
    return false;
  }

  do {
    chars.insert(0, current!.lexeme);
    if (current.type == TokenType.GT) bracketCount++;
    if (current.type == TokenType.LT) bracketCount--;
    current = current.previous;
  } while (!isDone());

  if (current != null) chars.insert(0, current.lexeme);

  return chars.join();
}
