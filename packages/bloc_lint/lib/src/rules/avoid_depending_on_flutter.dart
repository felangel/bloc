import 'package:bloc_lint/bloc_lint.dart';
import 'package:path/path.dart' as path;

/// {@template avoid_depending_on_flutter}
/// The avoid_depending_on_flutter lint rule.
/// {@endtemplate}
class AvoidDependingOnFlutter extends LintRule {
  /// {@macro avoid_depending_on_flutter}
  const AvoidDependingOnFlutter()
    : super(name: 'avoid_depending_on_flutter', severity: Severity.error);

  @override
  Listener create(LintContext context) => _Listener(context);
}

enum _FileType { bloc, cubit, other }

class _Listener extends Listener {
  _Listener(this.context) {
    final basename = path.basename(context.document.uri.path);
    fileType =
        basename.endsWith('_bloc.dart')
            ? _FileType.bloc
            : basename.endsWith('_cubit.dart')
            ? _FileType.cubit
            : _FileType.other;
  }

  static const flutterImport = 'package:flutter/';

  final LintContext context;
  late final _FileType fileType;

  @override
  void beginImport(Token importKeyword) {
    if (fileType == _FileType.other) return;
    final package = importKeyword.next;
    if (package == null) return;
    if (!package.lexeme.substring(1).startsWith(flutterImport)) return;
    final instance = fileType == _FileType.bloc ? 'Bloc' : 'Cubit';
    context.report(
      token: package,
      message:
          '''Avoid depending on Flutter within ${instance.toLowerCase()} instances.''',
      hint: '${instance}s should be decoupled from the UI layer.',
    );
  }
}
