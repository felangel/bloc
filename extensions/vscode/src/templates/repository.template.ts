import * as changeCase from "change-case";

export const getRepositoryTemplate = (repositoryName: string) =>
  defaultRepositoryTemplate(repositoryName);

const defaultRepositoryTemplate = (repositoryName: string) => {
  const pascalCaseCubitName = changeCase.pascalCase(
    repositoryName.toLowerCase()
  );
  const snakeCaseCubitName = changeCase.snakeCase(repositoryName.toLowerCase());

  return `part './${snakeCaseCubitName}_data_provider.dart';
  
abstract class ${pascalCaseCubitName}Repository {}

class ${pascalCaseCubitName}RepositoryI implements ${pascalCaseCubitName}Repository {
  ${pascalCaseCubitName}RepositoryI(this.dataProvider);

  final ${pascalCaseCubitName}DataProvider dataProvider;
}`;
};
