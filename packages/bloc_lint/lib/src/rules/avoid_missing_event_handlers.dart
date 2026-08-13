import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_missing_event_handlers}
/// The avoid_missing_event_handlers lint rule.
/// {@endtemplate}
class AvoidMissingEventHandlers extends LintRule {
  /// {@macro avoid_missing_event_handlers}
  AvoidMissingEventHandlers([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_missing_event_handlers';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _DeclaredType {
  _DeclaredType({
    required this.name,
    required this.parents,
    required this.isAbstractOrSealed,
    required this.isEnum,
  });

  final String name;
  final List<String> parents;
  final bool isAbstractOrSealed;
  final bool isEnum;
}

class _BlocInfo {
  _BlocInfo({
    required this.token,
    required this.eventType,
    required this.isAbstract,
  });

  final Token token;
  final String eventType;
  final bool isAbstract;
  final Set<String> handled = <String>{};
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  final Map<String, _DeclaredType> _types = {};
  final List<_BlocInfo> _blocs = [];

  _BlocInfo? _currentBloc;

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
    _currentBloc = null;

    final isAbstractOrSealed =
        abstractToken != null || sealedToken != null || mixinToken != null;
    final parents = _supertypes(name);
    _types[name.lexeme] = _DeclaredType(
      name: name.lexeme,
      parents: parents,
      isAbstractOrSealed: isAbstractOrSealed,
      isEnum: false,
    );

    final superclazz = _extendsName(name);
    if (superclazz == null || !_isBloc(superclazz.lexeme)) return;

    final eventType = _firstTypeArgument(superclazz);
    if (eventType == null) return;

    final bloc = _BlocInfo(
      token: name,
      eventType: eventType.lexeme,
      isAbstract: abstractToken != null,
    );
    _blocs.add(bloc);
    _currentBloc = bloc;
  }

  @override
  void endClassDeclaration(Token beginToken, Token endToken) {
    _currentBloc = null;
  }

  @override
  void beginEnumDeclaration(
    Token beginToken,
    Token? augmentToken,
    Token enumKeyword,
    Token name,
  ) {
    _types[name.lexeme] = _DeclaredType(
      name: name.lexeme,
      parents: const [],
      isAbstractOrSealed: false,
      isEnum: true,
    );
  }

  @override
  void handleIdentifier(Token token, IdentifierContext _) {
    final bloc = _currentBloc;
    if (bloc == null) return;
    if (token.lexeme != 'on') return;

    final eventType = _firstTypeArgument(token);
    if (eventType == null) return;
    bloc.handled.add(eventType.lexeme);
  }

  @override
  void endCompilationUnit(int count, Token token) {
    for (final bloc in _blocs) {
      if (bloc.isAbstract) continue;
      if (bloc.handled.contains(bloc.eventType)) continue;

      for (final event in _requiredEvents(bloc.eventType)) {
        if (_isHandled(event.name, bloc)) continue;
        context.reportToken(
          token: bloc.token,
          message: 'Missing event handler for ${event.name}.',
          hint: 'Register a handler via on<${event.name}>.',
        );
      }
    }
  }

  Iterable<_DeclaredType> _requiredEvents(String eventType) {
    final descendants = _types.values.where(
      (type) => type.name != eventType && _isDescendantOf(type.name, eventType),
    );
    final concreteDescendants = descendants.where(
      (type) => !type.isAbstractOrSealed,
    );

    if (concreteDescendants.isNotEmpty) return concreteDescendants;

    final declared = _types[eventType];
    if (declared == null) return const [];
    return [declared];
  }

  bool _isHandled(String eventName, _BlocInfo bloc) {
    if (bloc.handled.contains(eventName)) return true;

    final seen = <String>{};
    final pending = <String>[eventName];
    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (!seen.add(current)) continue;
      final type = _types[current];
      if (type == null) continue;
      for (final parent in type.parents) {
        if (bloc.handled.contains(parent)) return true;
        pending.add(parent);
      }
    }
    return false;
  }

  bool _isDescendantOf(String name, String ancestor) {
    final seen = <String>{};
    final pending = <String>[name];
    while (pending.isNotEmpty) {
      final current = pending.removeLast();
      if (!seen.add(current)) continue;
      if (current == ancestor) return true;
      final type = _types[current];
      if (type == null) continue;
      pending.addAll(type.parents);
    }
    return false;
  }

  bool _isBloc(String name) {
    if (name.endsWith('MockBloc')) return false;
    return name.endsWith('Bloc');
  }

  Token? _extendsName(Token name) {
    var token = _afterTypeParameters(name);
    while (token != null && !_isHeaderEnd(token)) {
      if (token.kind == Keyword.EXTENDS.kind) {
        return _typeName(token.next);
      }
      token = token.next;
    }
    return null;
  }

  List<String> _supertypes(Token name) {
    final parents = <String>[];
    var token = _afterTypeParameters(name);
    var collecting = false;
    while (token != null && !_isHeaderEnd(token)) {
      if (token.kind == Keyword.EXTENDS.kind ||
          token.kind == Keyword.IMPLEMENTS.kind) {
        collecting = true;
        token = token.next;
        continue;
      }
      if (token.kind == Keyword.WITH.kind) {
        collecting = false;
        token = token.next;
        continue;
      }
      if (!collecting) {
        token = token.next;
        continue;
      }
      if (token.type == TokenType.COMMA) {
        token = token.next;
        continue;
      }
      if (token.type == TokenType.LT) {
        token = _skipTypeArguments(token);
        continue;
      }
      final type = _typeName(token);
      if (type != null) {
        parents.add(type.lexeme);
        token = type.next;
        continue;
      }
      token = token.next;
    }
    return parents;
  }

  Token? _firstTypeArgument(Token typeName) {
    final lt = typeName.next;
    if (lt == null || lt.type != TokenType.LT) return null;
    return _typeName(lt.next);
  }

  Token? _typeName(Token? token) {
    if (token == null || !token.isIdentifier) return null;
    if (token.next?.type == TokenType.PERIOD) {
      final name = token.next?.next;
      if (name != null && name.isIdentifier) return name;
    }
    return token;
  }

  Token? _afterTypeParameters(Token name) {
    final next = name.next;
    if (next != null && next.type == TokenType.LT) {
      return _skipTypeArguments(next);
    }
    return next;
  }

  Token? _skipTypeArguments(Token lt) {
    var depth = 0;
    Token? token = lt;
    while (token != null) {
      final lexeme = token.lexeme;
      if (lexeme == '<') {
        depth++;
      } else if (lexeme == '>') {
        depth--;
        if (depth <= 0) return token.next;
      } else if (lexeme == '>>') {
        depth -= 2;
        if (depth <= 0) return token.next;
      } else if (lexeme == '>>>') {
        depth -= 3;
        if (depth <= 0) return token.next;
      }
      token = token.next;
    }
    return token;
  }

  bool _isHeaderEnd(Token token) {
    return token.lexeme == '{' || token.type == TokenType.SEMICOLON;
  }
}
