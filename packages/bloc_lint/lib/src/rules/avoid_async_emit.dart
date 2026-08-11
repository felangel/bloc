import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_async_emit}
/// The avoid_async_emit lint rule.
/// {@endtemplate}
class AvoidAsyncEmit extends LintRule {
  /// {@macro avoid_async_emit}
  AvoidAsyncEmit([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_async_emit';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  bool _inAsyncMethod = false;
  bool _isBlocOrCubit = false;

  int _isClosedGuardLevel = 0;
  int _awaitInGuardLevel = 0;

  @override
  Future<void> handleAsyncModifier(Token? beginToken, Token? endToken) async {
    if (!_isBlocOrCubit) return;

    if (beginToken?.lexeme != 'async') return;

    _inAsyncMethod = true;
  }

  @override
  void beginAwaitExpression(Token token) {
    if (!_isBlocOrCubit) return;
    if (!_inAsyncMethod) return;

    if (_isClosedGuardLevel > 0) {
      _awaitInGuardLevel = _isClosedGuardLevel;
    }
  }

  @override
  void beginIfStatement(Token token) {
    if (!_isBlocOrCubit) return;
    if (!_inAsyncMethod) return;

    final next = token.next;
    if (next?.lexeme == '(') {
      final cond1 = next?.next;
      // if (!isClosed)
      if (cond1?.lexeme == '!' &&
          cond1?.next?.lexeme == 'isClosed' &&
          cond1?.next?.next?.lexeme == ')') {
        _isClosedGuardLevel++;
      }

      // if (isClosed == false)
      if (cond1?.lexeme == 'isClosed' &&
          cond1?.next?.lexeme == '==' &&
          cond1?.next?.next?.lexeme == 'false') {
        _isClosedGuardLevel++;
      }

      // if (isClosed) return;
      if (cond1?.lexeme == 'isClosed' && cond1?.next?.lexeme == ')') {
        final afterParen = cond1?.next?.next;
        if (afterParen?.lexeme == 'return' && afterParen?.next?.lexeme == ';') {
          _isClosedGuardLevel++;
        }
        if (afterParen?.lexeme == '{' &&
            afterParen?.next?.lexeme == 'return' &&
            afterParen?.next?.next?.lexeme == ';' &&
            afterParen?.next?.next?.next?.lexeme == '}') {
          _isClosedGuardLevel++;
        }
      }

      // if (isClosed == false) return;
      // or if (isClosed == false) { return; }
      if (cond1?.lexeme == 'isClosed' &&
          cond1?.next?.lexeme == '==' &&
          cond1?.next?.next?.lexeme == 'false' &&
          cond1?.next?.next?.next?.lexeme == ')') {
        final afterParen = cond1?.next?.next?.next?.next;
        if (afterParen?.lexeme == 'return' && afterParen?.next?.lexeme == ';') {
          _isClosedGuardLevel++;
        }
        if (afterParen?.lexeme == '{' &&
            afterParen?.next?.lexeme == 'return' &&
            afterParen?.next?.next?.lexeme == ';' &&
            afterParen?.next?.next?.next?.lexeme == '}') {
          _isClosedGuardLevel++;
        }
      }
    }
  }

  @override
  void endIfStatement(Token ifToken, Token? elseToken, Token endToken) {
    if (!_isBlocOrCubit) return;
    if (!_inAsyncMethod) return;

    final next = ifToken.next;
    if (next?.lexeme == '(') {
      final cond1 = next?.next;
      if (cond1?.lexeme == '!' && cond1?.next?.lexeme == 'isClosed') {
        if (_isClosedGuardLevel > 0) _isClosedGuardLevel--;
        if (_awaitInGuardLevel > _isClosedGuardLevel) {
          _awaitInGuardLevel = _isClosedGuardLevel;
        }
      }
      if (cond1?.lexeme == 'isClosed' &&
          cond1?.next?.lexeme == '==' &&
          cond1?.next?.next?.lexeme == 'false') {
        if (_isClosedGuardLevel > 0) _isClosedGuardLevel--;
        if (_awaitInGuardLevel > _isClosedGuardLevel) {
          _awaitInGuardLevel = _isClosedGuardLevel;
        }
      }
    }
  }

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    final extendsBlocOrCubit =
        (token.lexeme == 'Cubit' || token.lexeme == 'Bloc') &&
        token.previous?.lexeme == 'extends';

    if (extendsBlocOrCubit) {
      _isBlocOrCubit = true;
    }

    if (!_isBlocOrCubit) return;
    if (!_inAsyncMethod) return;

    if (token.lexeme == 'emit') {
      if (_isClosedGuardLevel > 0 && _awaitInGuardLevel < _isClosedGuardLevel) {
        return;
      }

      context.reportToken(
        token: token,
        message: '''
Avoid calling emit inside async methods without guarding with isClosed.''',
        hint: '''
Guard emit with if (!isClosed) or if (isClosed) return; before calling emit.''',
      );
    }
  }
}
