import * as changeCase from "change-case";

export const getViewTemplate = (repositoryName: string) =>
  defaultViewTemplate(repositoryName);

const defaultViewTemplate = (repositoryName: string) => {
  const pascalCaseCubitName = changeCase.pascalCase(
    repositoryName.toLowerCase()
  );

  return `import 'package:flutter/material.dart';

class ${pascalCaseCubitName}Page extends StatelessWidget {
  const ${pascalCaseCubitName}Page({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}`;
};
