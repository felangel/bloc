import 'package:bloc_lint/bloc_lint.dart';
import 'package:collection/collection.dart';

/// {@template nested_widget_listener}
/// A [Listener] which reports [widget] instances that are nested directly
/// within the `child` of another [widget] and could instead be collapsed
/// into a single [replacement] widget.
///
/// Only the outermost [widget] of a nested chain is reported.
/// {@endtemplate}
class NestedWidgetListener extends Listener {
  /// {@macro nested_widget_listener}
  NestedWidgetListener({
    required this.context,
    required this.widget,
    required this.replacement,
  });

  /// The current [LintContext].
  final LintContext context;

  /// The name of the widget which should not be nested.
  final String widget;

  /// The name of the widget which should be used instead.
  final String replacement;

  /// The enclosing argument lists, outermost first.
  final _invocations = <_Invocation>[];

  /// Maps the closing `>` of a type argument list to the identifier
  /// which owns it (e.g. `>` -> `BlocListener`).
  final _typeArgumentOwners = <Token, Token>{};

  /// The widgets which have already been reported.
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

    if (isChild && (_invocations.lastOrNull?.target != null)) _report();

    _invocations.add(_Invocation(target: target, isChild: isChild));
  }

  @override
  void endArguments(int count, Token beginToken, Token endToken) {
    if (_invocations.isNotEmpty) _invocations.removeLast();
  }

  /// Returns the [widget] identifier which owns the argument list beginning
  /// at [openParen] or `null` if the invocation is not a [widget].
  Token? _targetOf(Token openParen) {
    var token = openParen.previous;
    if (token == null) return null;

    // Resolve named constructors. e.g. `RepositoryProvider.value(...)`
    final period = token.previous;
    if (period != null && period.type == TokenType.PERIOD) {
      final receiver = period.previous;
      if (receiver == null) return null;
      token = receiver;
    }

    // Resolve type arguments. e.g. `BlocListener<BlocA, BlocAState>(...)`
    final resolved = _typeArgumentOwners[token] ?? token;
    return resolved.lexeme == widget ? resolved : null;
  }

  /// Whether [target] is the value of a `child` argument.
  bool _isChildArgument(Token target) {
    final colon = target.previous;
    if (colon == null || colon.type != TokenType.COLON) return false;
    return colon.previous?.lexeme == 'child';
  }

  void _report() {
    final root = _outermost();
    if (!_reported.add(root)) return;
    context.reportToken(
      token: root,
      message: 'Avoid nesting $widget widgets.',
      hint: 'Prefer using $replacement instead.',
    );
  }

  /// Walks up the chain of `child` arguments to find the outermost [widget].
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

  /// The watched widget which owns this argument list, if any.
  final Token? target;

  /// Whether this invocation is the value of a `child` argument.
  final bool isChild;
}
