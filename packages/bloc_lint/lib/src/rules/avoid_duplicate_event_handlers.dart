import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_duplicate_event_handlers}
/// The avoid_duplicate_event_handlers lint rule.
/// {@endtemplate}
class AvoidDuplicateEventHandlers extends LintRule {
  /// {@macro avoid_duplicate_event_handlers}
  AvoidDuplicateEventHandlers([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_duplicate_event_handlers';

  @override
  Listener? create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  /// Whether the enclosing class is a bloc.
  bool _isBlocClass = false;

  /// The event types which already have a registered handler
  /// within the enclosing bloc.
  final _registeredEventTypes = <String>{};

  @override
  void beginClassDeclaration(
    Token begin,
    Token? abstractToken,
    Token? sealedToken,
    Token? baseToken,
    Token? interfaceToken,
    Token? finalToken,
    Token? augmentToken,
    Token? mixinToken,
    Token name,
  ) {
    _reset();
  }

  @override
  void handleClassExtends(Token? extendsKeyword, int typeCount) {
    final superclass = extendsKeyword?.next;
    if (superclass == null) return;
    _isBlocClass = superclass.lexeme.endsWith('Bloc');
  }

  @override
  void endClassDeclaration(Token beginToken, Token endToken) {
    _reset();
  }

  @override
  void endTypeArguments(int count, Token beginToken, Token endToken) {
    if (!_isBlocClass) return;

    // `on` is always invoked with exactly one type argument.
    // e.g. `on<CounterIncrementPressed>(...)`
    if (count != 1) return;

    final onToken = beginToken.previous;
    if (onToken == null || onToken.lexeme != 'on') return;

    // Ignore handlers registered on another object.
    // e.g. `bloc.on<CounterIncrementPressed>(...)`
    if (onToken.previous?.type == TokenType.PERIOD) return;

    // The type arguments must be followed by an argument list.
    if (endToken.next?.type != TokenType.OPEN_PAREN) return;

    final eventType = _eventType(beginToken, endToken);
    if (_registeredEventTypes.add(eventType)) return;

    context.reportTokenRange(
      beginToken: onToken,
      endToken: endToken,
      message: 'Avoid duplicate event handlers.',
      hint: 'A handler is already registered for `$eventType`.',
    );
  }

  void _reset() {
    _isBlocClass = false;
    _registeredEventTypes.clear();
  }
}

/// Returns the event type declared between [beginToken] (`<`)
/// and [endToken] (`>`) with all whitespace removed.
String _eventType(Token beginToken, Token endToken) {
  final buffer = StringBuffer();
  var token = beginToken.next;
  while (token != null &&
      token != endToken &&
      token.type != TokenType.EOF &&
      token.offset < endToken.offset) {
    buffer.write(token.lexeme);
    token = token.next;
  }
  return buffer.toString();
}
