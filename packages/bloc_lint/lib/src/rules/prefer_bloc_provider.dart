import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_bloc_provider}
/// The prefer_bloc_provider lint rule.
/// {@endtemplate}
class PreferBlocProvider extends LintRule {
  /// {@macro prefer_bloc_provider}
  PreferBlocProvider([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'prefer_bloc_provider';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    if (token.lexeme != 'Provider') return;

    final typeArgument = _typeArgumentName(token);
    if (typeArgument == null) return;
    if (!_looksLikeBlocBase(typeArgument.lexeme)) return;

    context.reportToken(
      token: token,
      message: 'Avoid using Provider to provide bloc or cubit instances.',
      hint: 'Prefer using BlocProvider instead.',
    );
  }

  Token? _typeArgumentName(Token provider) {
    final lt = provider.next;
    if (lt == null || lt.type != TokenType.LT) return null;

    var type = lt.next;
    if (type == null) return null;

    // Skip import prefix: counter.CounterBloc
    if (type.next?.type == TokenType.PERIOD) {
      type = type.next!.next;
      if (type == null) return null;
    }

    return type;
  }

  bool _looksLikeBlocBase(String name) {
    return name.endsWith('BlocBase') ||
        name.endsWith('Bloc') ||
        name.endsWith('Cubit');
  }
}
