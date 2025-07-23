import 'package:bloc_lint/bloc_lint.dart';

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
  Listener? create(LintContext context) {
    return _Listener(context);
  }
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _contextExtensions = {'read', 'watch', 'select', 'listen'};
  static const _declarationKeywords = {'final', 'const', 'var', 'late'};

  /// Stores the type name of the variable currently being initialized.
  /// This is the single source of state for the type inference case.
  /// It's set in `beginInitializedIdentifier` and cleared in
  /// `endInitializedIdentifier`.
  String? _inferredTypeName;

  @override
  void beginInitializedIdentifier(Token nameToken) {
    final prev = nameToken.previous;

    if (prev != null &&
        prev.type == TokenType.IDENTIFIER &&
        !_declarationKeywords.contains(prev.lexeme)) {
      _inferredTypeName = prev.lexeme;
    }
    super.beginInitializedIdentifier(nameToken);
  }

  @override
  void endInitializedIdentifier(Token nameToken) {
    _inferredTypeName = null;
    super.endInitializedIdentifier(nameToken);
  }

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    final methodName = token.lexeme;
    if (!_contextExtensions.contains(methodName)) return;

    final prev = token.previous;
    if (prev == null || prev.lexeme != '.') return;

    final target = prev.previous;
    if (target?.lexeme != 'context') return;

    // Case 1: Explicit type -> context.read<MyBloc>()
    final openBracketToken = token.next;
    if (openBracketToken != null && openBracketToken.lexeme == '<') {
      final typeToken = openBracketToken.next;
      if (typeToken != null &&
          typeToken.type == TokenType.IDENTIFIER &&
          _isBlocTypeName(typeToken.lexeme)) {
        _report(token);
        return;
      }
    }

    // Case 2: Inferred type -> final MyBloc bloc = context.read();
    if (_isBlocTypeName(_inferredTypeName)) {
      _report(token);
    }
  }

  bool _isBlocTypeName(String? typeName) {
    if (typeName == null) return false;
    return typeName.endsWith('Bloc') || typeName.endsWith('Cubit');
  }

  void _report(Token token) {
    context.reportToken(
      token: token,
      message: 'Avoid using BuildContext extensions for Blocs/Cubits.',
      hint: 'Prefer using BlocProvider.of<T>(context) instead.',
    );
  }
}
