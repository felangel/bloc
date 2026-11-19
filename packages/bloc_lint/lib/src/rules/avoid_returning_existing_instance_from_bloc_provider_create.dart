import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_returning_existing_instance_from_bloc_provider_create}
/// The avoid_returning_existing_instance_from_bloc_provider_create lint rule.
/// {@endtemplate}
class AvoidReturningExistingInstanceFromBlocProviderCreate extends LintRule {
  /// {@macro avoid_returning_existing_instance_from_bloc_provider_create}
  AvoidReturningExistingInstanceFromBlocProviderCreate([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule =
      'avoid_returning_existing_instance_from_bloc_provider_create';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _message =
      'Avoid returning an existing instance from BlocProvider create.';

  static const _hint = '''
Prefer creating a new instance within create.
Use BlocProvider.value to provide an existing instance.''';

  // Tokens which can make up a reference to an existing instance such as
  // `bloc`, `_bloc`, `this.bloc`, `widget.bloc` and `widget.bloc!`.
  static const _referenceTokenTypes = <TokenType>{
    TokenType.IDENTIFIER,
    TokenType.PERIOD,
    TokenType.QUESTION_PERIOD,
    TokenType.BANG,
    Keyword.THIS,
  };

  // Methods which look up an existing instance from the widget tree.
  static const _lookupMethods = <String>{'read', 'watch'};

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    if (token.lexeme != 'BlocProvider') return;

    final openParen = _argumentList(token);
    if (openParen == null) return;

    // Look for a top level `create` argument within the argument list.
    final closeParen = openParen.endGroup;
    var current = openParen.next;
    while (current != null && current != closeParen) {
      final group = current.endGroup;
      if (group != null) {
        current = group.next;
        continue;
      }
      final next = current.next;
      if (current.lexeme == 'create' && next?.type == TokenType.COLON) {
        return _visitCreate(next?.next);
      }
      current = next;
    }
  }

  /// Returns the `(` of the argument list when [token] is the beginning of a
  /// `BlocProvider(...)` or `BlocProvider<T>(...)` invocation.
  Token? _argumentList(Token token) {
    var next = token.next;
    if (next?.type == TokenType.LT) next = next?.endGroup?.next ?? next;
    if (next?.type != TokenType.OPEN_PAREN) return null;
    return next;
  }

  /// Visits the value of the `create` argument which begins at [token].
  /// Only function literals are visited since a tear-off does not reveal
  /// what will be returned.
  void _visitCreate(Token? token) {
    if (token?.type != TokenType.OPEN_PAREN) return;
    final parameters = token?.endGroup;
    final body = parameters?.next;
    // The name of the `BuildContext` parameter, if there is one.
    final parameter = parameters?.previous?.lexeme;
    if (body?.type == TokenType.FUNCTION) {
      return _visitReturnValue(body?.next, parameter);
    }
    if (body?.type == TokenType.OPEN_CURLY_BRACKET) {
      return _visitBlock(body!, parameter);
    }
  }

  /// Visits every top level `return` within the block beginning at [token].
  void _visitBlock(Token token, String? parameter) {
    final closeCurly = token.endGroup;
    var current = token.next;
    while (current != null && current != closeCurly) {
      final group = current.endGroup;
      if (group != null) {
        current = group.next;
        continue;
      }
      if (current.type == Keyword.RETURN) {
        _visitReturnValue(current.next, parameter);
      }
      current = current.next;
    }
  }

  /// Reports the expression beginning at [token] when it resolves to an
  /// instance which already exists.
  void _visitReturnValue(Token? token, String? parameter) {
    if (token == null) return;
    final end = _expressionEnd(token);
    final isExisting =
        _isReference(token, end) || _isLookup(token, end, parameter);
    if (!isExisting) return;
    context.reportTokenRange(
      beginToken: token,
      endToken: end,
      message: _message,
      hint: _hint,
    );
  }

  /// Returns the last token of the expression beginning at [token].
  Token _expressionEnd(Token token) {
    var current = token;
    while (true) {
      current = current.endGroup ?? current;
      final next = current.next;
      if (next == null ||
          next.type == TokenType.COMMA ||
          next.type == TokenType.CLOSE_PAREN ||
          next.type == TokenType.SEMICOLON) {
        return current;
      }
      current = next;
    }
  }

  /// Whether the expression from [begin] to [end] is only a reference to an
  /// instance which already exists (e.g. `bloc` or `widget.bloc`).
  bool _isReference(Token begin, Token end) {
    var current = begin;
    while (_referenceTokenTypes.contains(current.type)) {
      if (current == end) return true;
      current = current.next!;
    }
    return false;
  }

  /// Whether the expression from [begin] to [end] looks up an instance which
  /// already exists such as `context.read<T>()` or
  /// `BlocProvider.of<T>(context)`.
  bool _isLookup(Token begin, Token end, String? parameter) {
    if (begin.type != TokenType.IDENTIFIER) return false;
    final period = begin.next;
    if (period?.type != TokenType.PERIOD) return false;

    final method = period?.next;
    if (method == null) return false;

    final target = begin.lexeme;
    final isExtension =
        (target == 'context' || target == parameter) &&
        _lookupMethods.contains(method.lexeme);
    final isProviderOf = target == 'BlocProvider' && method.lexeme == 'of';
    if (!isExtension && !isProviderOf) return false;

    var next = method.next;
    if (next?.type == TokenType.LT) next = next?.endGroup?.next ?? next;
    if (next?.type != TokenType.OPEN_PAREN) return false;
    return next?.endGroup == end;
  }
}
