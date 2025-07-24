import 'package:bloc_lint/bloc_lint.dart';
import 'package:collection/collection.dart';

/// {@template avoid_build_context_extensions}
/// The avoid_build_context_extensions lint rule.
/// {@endtemplate}
class AvoidBuildContextExtensions extends LintRule {
  /// {@macro avoid_build_context_extensions}
  AvoidBuildContextExtensions([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_build_context_extensions';

  @override
  Listener create(LintContext context) => _Listener(context);
}

// Supported `BuildContext` extensions methods.
enum _ContextMethod { read, watch, select }

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _declarationKeywords = {'final', 'const', 'var', 'late'};

  /// Whether the type is implicitly a bloc type.
  bool _isImplicitBlocType = false;

  @override
  void beginInitializedIdentifier(Token nameToken) {
    final prev = nameToken.previous;
    if (prev != null &&
        prev.type == TokenType.IDENTIFIER &&
        !_declarationKeywords.contains(prev.lexeme)) {
      _isImplicitBlocType = prev.isBlocType;
    }
    super.beginInitializedIdentifier(nameToken);
  }

  @override
  void endInitializedIdentifier(Token nameToken) {
    _isImplicitBlocType = false;
    super.endInitializedIdentifier(nameToken);
  }

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    final method = _ContextMethod.values.firstWhereOrNull(
      (value) => value.name == token.lexeme,
    );
    if (method == null) return;

    final prev = token.previous;
    if (prev == null || prev.type != TokenType.PERIOD) return;

    final target = prev.previous;
    if (target == null) return;
    if (target.lexeme != 'context') return;

    // Case 1: implicit type
    // e.g. final MyBloc bloc = context.read();
    if (_isImplicitBlocType) return _report(method, target, token);

    // Case 2: explicit type
    // e.g. final bloc = context.read<MyBloc>();
    final openBracketToken = token.next;
    if (openBracketToken == null) return;
    if (openBracketToken.type != TokenType.LT) return;

    final typeToken = openBracketToken.next;
    if (typeToken == null) return;
    if (typeToken.type != TokenType.IDENTIFIER) return;
    if (!typeToken.isBlocType) return;

    return _report(method, target, token);
  }

  void _report(_ContextMethod method, Token beginToken, Token endToken) {
    context.reportTokenRange(
      beginToken: beginToken,
      endToken: endToken,
      message: 'Avoid using BuildContext extensions.',
      hint: 'Prefer using ${method.alternative} instead.',
    );
  }
}

extension on _ContextMethod {
  String get alternative {
    switch (this) {
      case _ContextMethod.read:
        return 'BlocProvider.of<Bloc>(context, listen: false)';
      case _ContextMethod.watch:
        return '''BlocBuilder<Bloc, State>(...) or BlocProvider.of<Bloc>(context)''';
      case _ContextMethod.select:
        return 'BlocSelector<Bloc, State>(...)';
    }
  }
}

extension on Token {
  bool get isBlocType {
    return lexeme.endsWith('Bloc') || lexeme.endsWith('Cubit');
  }
}
