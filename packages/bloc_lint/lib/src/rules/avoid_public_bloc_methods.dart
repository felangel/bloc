import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_public_bloc_methods}
/// The avoid_public_bloc_methods lint rule.
/// {@endtemplate}
class AvoidPublicBlocMethods extends LintRule {
  /// {@macro avoid_public_bloc_methods}
  const AvoidPublicBlocMethods()
    : super(name: 'avoid_public_bloc_methods', severity: Severity.warning);

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
