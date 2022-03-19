import * as changeCase from "change-case";

export const getDataProviderTemplate = (dataProviderName: string) =>
  defaultDataProviderTemplate(dataProviderName);

const defaultDataProviderTemplate = (dataProviderName: string) => {
  const pascalCaseCubitName = changeCase.pascalCase(
    dataProviderName.toLowerCase()
  );
  const snakeCaseCubitName = changeCase.snakeCase(
    dataProviderName.toLowerCase()
  );

  return `part of './${snakeCaseCubitName}_repository.dart';
  
abstract class ${pascalCaseCubitName}DataProvider {}

class ${pascalCaseCubitName}DataProviderI implements ${pascalCaseCubitName}DataProvider {}`;
};
