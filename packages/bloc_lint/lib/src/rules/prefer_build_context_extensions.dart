import 'package:bloc_lint/bloc_lint.dart';

/// {@template prefer_build_context_extensions}
/// The prefer_build_context_extensions lint rule.
/// {@endtemplate}
class PreferBuildContextExtensions extends LintRule {
  /// {@macro prefer_build_context_extensions}
  PreferBuildContextExtensions([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'prefer_build_context_extensions';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _message = 'Prefer using BuildContext extensions.';

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    final provider = tryParseProvider(token);
    if (provider != null) {
      return context.reportTokenRange(
        beginToken: provider,
        endToken: token,
        message: _message,
        hint: '''
Avoid using ${provider.lexeme}.of<T>.
Prefer using context.read or context.watch instead.''',
      );
    }

    final blocBuilder = tryParseBlocBuilder(token);
    if (blocBuilder != null) {
      return context.reportTokenRange(
        beginToken: blocBuilder,
        endToken: token,
        message: _message,
        hint: '''
Avoid using ${blocBuilder.lexeme}.
Prefer using context.watch instead.''',
      );
    }

    final blocSelector = tryParseBlocSelector(token);
    if (blocSelector != null) {
      return context.reportTokenRange(
        beginToken: blocSelector,
        endToken: token,
        message: _message,
        hint: '''
Avoid using ${blocSelector.lexeme}.
Prefer using context.select instead.''',
      );
    }
  }

  Token? tryParseProvider(Token token) {
    if (token.lexeme != 'of') return null;

    final prev = token.previous;
    if (prev == null) return null;
    if (prev.type != TokenType.PERIOD) return null;

    final next = token.next;
    if (next == null) return null;

    final target = prev.previous;
    if (target == null) return null;

    const providers = <String>{'BlocProvider', 'RepositoryProvider'};
    return providers.contains(target.lexeme) ? target : null;
  }

  Token? tryParseBlocBuilder(Token token) {
    if (token.lexeme != 'BlocBuilder') return null;
    return (token.next is BeginToken) ? token : null;
  }

  Token? tryParseBlocSelector(Token token) {
    if (token.lexeme != 'BlocSelector') return null;
    return (token.next is BeginToken) ? token : null;
  }
}
