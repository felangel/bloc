import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:bloc_lint/bloc_lint_constants.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class AvoidPublicMethodsOnBlocLintRule extends DartLintRule {
  const AvoidPublicMethodsOnBlocLintRule()
      : super(
          code: const LintCode(
            name: 'avoid_public_methods_on_bloc',
            problemMessage: 'Avoid public methods on Bloc classes.',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addClassDeclaration((node) {
      final superClass = node.extendsClause?.superclass.element?.name;

      if (superClass == BlocLintConstants.blocClass) {
        for (final member in node.members) {
          if (member is MethodDeclaration) {
            final isPublic = !member.name.lexeme.startsWith('_');
            if (isPublic) {
              reporter.atToken(member.name, code);
            }
          }
        }
      }
    });
  }
}
