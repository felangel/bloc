import 'package:bloc_lint/bloc_lint.dart';

/// {@template avoid_flutter_imports}
/// The avoid_flutter_imports lint rule.
/// {@endtemplate}
class AvoidFlutterImports extends LintRule {
  /// {@macro avoid_flutter_imports}
  AvoidFlutterImports([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.warning);

  /// The name of the lint rule.
  static const rule = 'avoid_flutter_imports';

  @override
  Listener? create(LintContext context) {
    if (context.document.type.isOther) return null;
    return _Listener(context);
  }
}

class _Listener extends Listener {
  _Listener(this.context);

  static const flutterImport = 'package:flutter/';

  final LintContext context;

  @override
  void beginImport(Token importKeyword) {
    final package = importKeyword.next;
    if (package == null) return;
    if (!package.lexeme.substring(1).startsWith(flutterImport)) return;
    final instance = context.document.type.isBloc ? 'Bloc' : 'Cubit';
    context.reportToken(
      token: package,
      message:
          '''Avoid importing Flutter within ${instance.toLowerCase()} instances.''',
      hint: '${instance}s should be decoupled from Flutter.',
    );
  }
}
