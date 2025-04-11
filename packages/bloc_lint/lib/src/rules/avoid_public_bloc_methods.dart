import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_public_bloc_methods}
/// The avoid_public_bloc_methods lint rule.
/// {@endtemplate}
class AvoidPublicBlocMethods extends LintRule {
  /// {@macro avoid_public_bloc_methods}
  AvoidPublicBlocMethods([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_public_bloc_methods';

  @override
  Listener? create(LintContext context) {
    if (!context.document.type.isBloc) return null;
    return _Listener(context);
  }
}

class _Listener extends Listener {
  _Listener(this.context);

  static const allowedMethods = [
    'add',
    'addError',
    'close',
    'emit',
    'state',
    'stream',
    'on',
    'onChange',
    'onError',
    'onEvent',
    'onTransition',
    'toString',
  ];

  final LintContext context;

  var _isOverride = false;

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
    if (!(enclosingDeclarationName?.endsWith('Bloc') ?? false)) {
      return;
    }
    final methodName = name.lexeme;
    if (enclosingDeclarationName == methodName) return;
    if (allowedMethods.contains(methodName)) return;
    if (methodName.startsWith('_')) return;
    context.reportToken(
      token: name,
      message: 'Avoid public methods on bloc instances.',
      hint: 'Prefer notifying bloc instances via `add`.',
    );
  }
}
