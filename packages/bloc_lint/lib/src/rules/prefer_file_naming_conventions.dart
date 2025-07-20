import 'package:bloc_lint/bloc_lint.dart';
import 'package:bloc_lint/src/string_case.dart';
import 'package:path/path.dart' as path;

/// {@template prefer_file_naming_conventions}
/// The prefer_file_naming_conventions lint rule.
/// {@endtemplate}
class PreferFileNamingConventions extends LintRule {
  /// {@macro prefer_file_naming_conventions}
  PreferFileNamingConventions([Severity? severity])
    : super(name: rule, severity: severity ?? Severity.info);

  /// The name of the lint rule.
  static const rule = 'prefer_file_naming_conventions';

  @override
  Listener create(LintContext context) => _Listener(context);
}

class _Listener extends Listener {
  _Listener(this.context);

  final LintContext context;

  @override
  void beginClassDeclaration(
    Token begin,
    Token? abstractToken,
    Token? macroToken,
    Token? sealedToken,
    Token? baseToken,
    Token? interfaceToken,
    Token? finalToken,
    Token? augmentToken,
    Token? mixinToken,
    Token name,
  ) {
    final extendz = name.next;

    if (extendz == null || extendz.kind != Keyword.EXTENDS.kind) return;

    final superclazz = extendz.next;
    if (superclazz == null) return;

    if (superclazz.lexeme.endsWith('MockBloc')) return;
    if (superclazz.lexeme.endsWith('MockCubit')) return;

    if (superclazz.lexeme.endsWith('Bloc') ||
        superclazz.lexeme.endsWith('Cubit')) {
      final expectedFileName = '${name.lexeme.toSnakeCase()}.dart';
      final actualFileName = path.basename(context.document.uri.toString());
      if (actualFileName == expectedFileName) return;
      context.reportToken(
        token: name,
        message: 'Prefer following file naming conventions.',
        hint: 'Prefer moving ${name.lexeme} into $expectedFileName.dart',
      );
    }
  }
}
