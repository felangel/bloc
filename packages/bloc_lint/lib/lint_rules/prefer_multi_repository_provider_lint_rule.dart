import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class PreferMultiRepositoryProviderLintRule extends DartLintRule {
  const PreferMultiRepositoryProviderLintRule()
      : super(
          code: const LintCode(
            name: 'prefer_multi_repository_provider',
            problemMessage:
                '''Consider using MultiRepositoryProvider instead of multiple RepositoryProvider instances.''',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const _className = 'RepositoryProvider';

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addInstanceCreationExpression((node) {
      if (node.constructorName.type.type?.element?.name == _className) {
        var parent = node.parent;
        while (parent != null) {
          if (parent is InstanceCreationExpression &&
              parent.constructorName.type.type?.element?.name == _className) {
            reporter.atNode(node, code);
            break;
          }
          parent = parent.parent;
        }
      }
    });
  }
}
