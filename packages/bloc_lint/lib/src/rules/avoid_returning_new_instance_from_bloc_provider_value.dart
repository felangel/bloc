import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_returning_new_instance_from_bloc_provider_value}
/// The avoid_returning_new_instance_from_bloc_provider_value lint rule.
/// {@endtemplate}
class AvoidReturningNewInstanceFromBlocProviderValue extends LintRule {
  /// {@macro avoid_returning_new_instance_from_bloc_provider_value}
  AvoidReturningNewInstanceFromBlocProviderValue([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_returning_new_instance_from_bloc_provider_value';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _message =
      'Avoid returning a new instance from BlocProvider.value.';

  static const _hint = '''
Prefer using BlocProvider(create: ...) to create a new instance.
Use BlocProvider.value only to provide an existing instance.''';

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    if (token.lexeme != 'BlocProvider') return;

    final openParen = _findValueConstructorOpenParen(token);
    if (openParen == null) return;

    // Look for a top-level `value` argument within the argument list.
    final closeParen = openParen.endGroup;
    var current = openParen.next;
    while (current != null && current != closeParen) {
      final group = current.endGroup;
      if (group != null) {
        current = group.next;
        continue;
      }
      final next = current.next;
      if (current.lexeme == 'value' && next?.type == TokenType.COLON) {
        return _visitValue(next?.next);
      }
      current = next;
    }
  }

  /// Returns the `(` of the argument list when [token] is the beginning of a
  /// `BlocProvider.value(...)` or `BlocProvider<T>.value(...)` invocation.
  Token? _findValueConstructorOpenParen(Token token) {
    var next = token.next;
    if (next?.type == TokenType.LT) {
      next = next?.endGroup?.next;
    }
    if (next?.type != TokenType.PERIOD) return null;
    final constructorName = next?.next;
    if (constructorName?.lexeme != 'value') return null;
    final openParen = constructorName?.next;
    if (openParen?.type != TokenType.OPEN_PAREN) return null;
    return openParen;
  }

  /// Visits the value of the `value` argument which begins at [token].
  void _visitValue(Token? token) {
    if (token == null ||
        token.type == TokenType.COMMA ||
        token.type == TokenType.CLOSE_PAREN) {
      return;
    }
    final end = _expressionEnd(token);
    if (!_isNewInstance(token)) return;

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

  /// Whether the expression beginning at [token] represents a constructor
  /// invocation creating a new instance.
  bool _isNewInstance(Token token) {
    var current = token;

    // Optional `const` or `new` keyword
    if (current.type == Keyword.CONST || current.type == Keyword.NEW) {
      final next = current.next;
      if (next == null) return false;
      current = next;
    }

    // Optional library prefix: `prefix.ClassName`
    if (current.type == TokenType.IDENTIFIER &&
        current.next?.type == TokenType.PERIOD &&
        current.next?.next?.type == TokenType.IDENTIFIER &&
        _isClassName(current.next!.next!)) {
      current = current.next!.next!;
    }

    // Must be a class name (begins with an uppercase ASCII letter)
    if (!_isClassName(current)) return false;

    // Skip optional type arguments: `ClassName<T>`
    var next = current.next;
    if (next?.type == TokenType.LT) {
      next = next?.endGroup?.next;
    }

    // Check for optional named constructor: `.named`
    if (next?.type == TokenType.PERIOD) {
      final constructorName = next?.next;
      if (constructorName?.type != TokenType.IDENTIFIER) return false;
      // Exclude static lookup methods like `.of` and `.maybeOf`
      if (constructorName?.lexeme == 'of' ||
          constructorName?.lexeme == 'maybeOf') {
        return false;
      }
      next = constructorName?.next;
    }

    // Must be followed by argument list: `(...)`
    return next?.type == TokenType.OPEN_PAREN;
  }

  bool _isClassName(Token token) {
    if (token.type != TokenType.IDENTIFIER) return false;
    final lexeme = token.lexeme;
    if (lexeme.isEmpty) return false;
    final firstCode = lexeme.codeUnitAt(0);
    return firstCode >= 65 && firstCode <= 90; // 'A'..'Z'
  }
}
