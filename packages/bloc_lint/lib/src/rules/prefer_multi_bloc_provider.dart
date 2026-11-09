import 'package:bloc_lint/bloc_lint.dart';
import 'package:collection/collection.dart';

/// {@template prefer_multi_bloc_provider}
/// The prefer_multi_bloc_provider lint rule.
/// {@endtemplate}
class PreferMultiBlocProvider extends LintRule {
  /// {@macro prefer_multi_bloc_provider}
  PreferMultiBlocProvider([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_multi_bloc_provider';

  @override
  Listener? create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  static const _widget = 'BlocProvider';
  static const _replacement = 'MultiBlocProvider';

  final _invocations = <_Invocation>[];
  final _typeArgumentOwners = <Token, Token>{};
  final _reported = <Token>{};

  @override
  void endTypeArguments(int count, Token beginToken, Token endToken) {
    final owner = beginToken.previous;
    if (owner != null) _typeArgumentOwners[endToken] = owner;
  }

  @override
  void beginArguments(Token token) {
    final target = _targetOf(token);
    final isChild = target != null && _isChildArgument(target);

    if (isChild && (_invocations.lastOrNull?.target != null)) {
      _report();
    }

    _invocations.add(_Invocation(target: target, isChild: isChild));
  }

  @override
  void endArguments(int count, Token beginToken, Token endToken) {
    if (_invocations.isNotEmpty) _invocations.removeLast();
  }

  Token? _targetOf(Token openParen) {
    var token = openParen.previous;
    if (token == null) return null;

    final period = token.previous;
    if (period != null && period.type == TokenType.PERIOD) {
      final receiver = period.previous;
      if (receiver == null) return null;
      token = receiver;
    }

    final resolved = _typeArgumentOwners[token] ?? token;
    return resolved.lexeme == _widget ? resolved : null;
  }

  bool _isChildArgument(Token target) {
    var prev = target.previous;
    if (prev != null && prev.keyword == Keyword.CONST) {
      prev = prev.previous;
    }
    if (prev == null || prev.type != TokenType.COLON) return false;
    return prev.previous?.lexeme == 'child';
  }

  void _report() {
    final root = _outermost();
    if (!_reported.add(root)) return;
    context.reportToken(
      token: root,
      message: 'Avoid nesting $_widget widgets.',
      hint: 'Prefer using $_replacement instead.',
    );
  }

  Token _outermost() {
    var root = _invocations.last.target!;
    for (var i = _invocations.length - 1; i > 0; i--) {
      final invocation = _invocations[i];
      final parent = _invocations[i - 1];
      if (!invocation.isChild || parent.target == null) break;
      root = parent.target!;
    }
    return root;
  }
}

class _Invocation {
  const _Invocation({required this.target, required this.isChild});

  final Token? target;
  final bool isChild;
}
