import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/error/error.dart';
import 'package:analyzer/error/listener.dart';
import 'package:bloc_lint/bloc_lint_constants.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

class EventBaseClassSuffix extends DartLintRule {
  const EventBaseClassSuffix()
      : super(
          code: const LintCode(
            name: 'event_base_class_suffix',
            problemMessage:
                '''The base event class should always be suffixed by 'Event'.''',
            errorSeverity: ErrorSeverity.WARNING,
          ),
        );

  static const _ignoredType = [
    'int',
    'double',
    'num',
    'String',
    'bool',
    'List',
    'Set',
    'Map',
  ];

  @override
  void run(
    CustomLintResolver resolver,
    ErrorReporter reporter,
    CustomLintContext context,
  ) {
    context.registry.addExtendsClause((node) {
      final superClass = node.superclass;
      TypeAnnotation? stateNode;

      if (superClass.element?.name == BlocLintConstants.blocClass) {
        stateNode = superClass.typeArguments?.arguments[0];
      }
      if (stateNode == null) {
        return;
      }
      final stateType = stateNode.type as InterfaceType?;
      if (stateType == null || _ignoredType.contains(stateType.element.name)) {
        return;
      }

      if (stateType.element.name.endsWith('Event') == false) {
        reporter.atNode(stateNode, code);
      }
    });
  }
}
