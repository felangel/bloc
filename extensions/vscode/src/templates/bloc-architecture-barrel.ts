import * as changeCase from "change-case";

export const getArchitectureBarrelTemplate = (
  repositoryName: string,
  type: string
) => defaultArchitectureBarrelTemplate(repositoryName, type);

const defaultArchitectureBarrelTemplate = (
  repositoryName: string,
  type: string
) => {
  const snakeCaseCubitName = changeCase.snakeCase(repositoryName.toLowerCase());

  return `export './view/${snakeCaseCubitName}_view.dart';
export './${type}/${snakeCaseCubitName}_${type}.dart';
export './data/${snakeCaseCubitName}_repository.dart';
  `;
};
