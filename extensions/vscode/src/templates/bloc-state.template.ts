import * as changeCase from "change-case";

export function getBlocStateTemplate(
  blocName: string,
  useEquatable: boolean
): string {
  return useEquatable
    ? getEquatableBlocStateTemplate(blocName)
    : getDefaultBlocStateTemplate(blocName);
}

function getEquatableBlocStateTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  return `import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ${pascalCaseBlocName}State extends Equatable {
  ${pascalCaseBlocName}State([List props = const <dynamic>[]]) : super(props);
}

class Initial${pascalCaseBlocName}State extends ${pascalCaseBlocName}State {}
`;
}

function getDefaultBlocStateTemplate(blocName: string): string {
  const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
  return `import 'package:meta/meta.dart';

@immutable
abstract class ${pascalCaseBlocName}State {}
  
class Initial${pascalCaseBlocName}State extends ${pascalCaseBlocName}State {}
`;
}
