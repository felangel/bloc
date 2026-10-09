import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_mutable_events}
/// The avoid_mutable_events lint rule.
/// {@endtemplate}
class AvoidMutableEvents extends LintRule {
  /// {@macro avoid_mutable_events}
  AvoidMutableEvents([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_mutable_events';

  @override
  Listener? create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  /// Whether the enclosing class is a bloc event.
  bool _isEventClass = false;

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
    // e.g. `sealed class CounterEvent {}`
    _isEventClass = name.lexeme.isEventType;
  }

  @override
  void handleClassExtends(Token? extendsKeyword, int typeCount) {
    final superclass = extendsKeyword?.next;
    if (superclass == null) return;
    // e.g. `final class CounterIncrementPressed extends CounterEvent {}`
    if (superclass.lexeme.isEventType) _isEventClass = true;
  }

  @override
  void endClassDeclaration(Token beginToken, Token endToken) {
    _isEventClass = false;
  }

  @override
  void endFields(
    DeclarationKind kind,
    Token? abstractToken,
    Token? augmentToken,
    Token? externalToken,
    Token? staticToken,
    Token? covariantToken,
    Token? lateToken,
    Token? varFinalOrConst,
    int count,
    Token beginToken,
    Token endToken,
  ) {
    if (!_isEventClass) return;
    if (kind != DeclarationKind.Class) return;

    // Static fields are not part of the event instance.
    if (staticToken != null) return;

    // `final` and `const` fields cannot be reassigned.
    if (varFinalOrConst != null && !varFinalOrConst.isVar) return;

    context.reportTokenRange(
      beginToken: beginToken,
      endToken: endToken,
      message: 'Avoid mutable events.',
      hint: 'Prefer marking fields as final.',
    );
  }

  @override
  void beginMethod(
    DeclarationKind declarationKind,
    Token? augmentToken,
    Token? externalToken,
    Token? staticToken,
    Token? covariantToken,
    Token? varFinalOrConst,
    Token? getOrSet,
    Token name,
    String? enclosingDeclarationName,
  ) {
    if (!_isEventClass) return;
    if (declarationKind != DeclarationKind.Class) return;
    if (staticToken != null) return;
    if (getOrSet == null || !getOrSet.isSet) return;

    context.reportToken(
      token: name,
      message: 'Avoid mutable events.',
      hint: 'Prefer removing the setter.',
    );
  }
}

extension on String {
  /// Whether the type name refers to a bloc event.
  bool get isEventType => endsWith('Event');
}

extension on Token {
  /// Whether the token is the `var` keyword.
  bool get isVar => type == Keyword.VAR;

  /// Whether the token is the `set` keyword.
  bool get isSet => type == Keyword.SET;
}
