import * as _ from "lodash";
import * as changeCase from "change-case";
import * as mkdirp from "mkdirp";

import {
  InputBoxOptions,
  OpenDialogOptions,
  Uri,
  window,
  workspace,
} from "vscode";
import { existsSync, lstatSync, writeFile } from "fs";
import {
  getBlocEventTemplate,
  getBlocStateTemplate,
  getBlocTemplate,
  getViewTemplate,
  getDataProviderTemplate,
  getRepositoryTemplate,
  getArchitectureBarrelTemplate,
} from "../templates";
import { getBlocType, BlocType, TemplateType } from "../utils";

export const newBlocArchitecure = async (uri: Uri) => {
  const architectureName = await promptForarchitectureName();
  if (_.isNil(architectureName) || architectureName.trim() === "") {
    window.showErrorMessage("The bloc name must not be empty");
    return;
  }

  let targetDirectory;
  if (_.isNil(_.get(uri, "fsPath")) || !lstatSync(uri.fsPath).isDirectory()) {
    targetDirectory = await promptForTargetDirectory();
    if (_.isNil(targetDirectory)) {
      window.showErrorMessage("Please select a valid directory");
      return;
    }
  } else {
    targetDirectory = uri.fsPath;
  }

  const blocType = await getBlocType(TemplateType.Bloc);
  const pascalCasearchitectureName = changeCase.pascalCase(
    architectureName.toLowerCase()
  );
  try {
    await generateBlocCode(architectureName, targetDirectory, blocType);
    await generateDataCode(architectureName, targetDirectory);
    await generateViewCode(architectureName, targetDirectory);
    await generateBarrelFileCode(architectureName, targetDirectory);
    window.showInformationMessage(
      `Successfully Generated ${pascalCasearchitectureName} Bloc Architecture`
    );
  } catch (error) {
    window.showErrorMessage(
      `Error:
        ${error instanceof Error ? error.message : JSON.stringify(error)}`
    );
  }
};

function promptForarchitectureName(): Thenable<string | undefined> {
  const architectureNamePromptOptions: InputBoxOptions = {
    prompt: "Bloc Architecture Name",
    placeHolder: "counter",
  };
  return window.showInputBox(architectureNamePromptOptions);
}

async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder to create the bloc architecture in",
    canSelectFolders: true,
  };

  return window.showOpenDialog(options).then((uri) => {
    if (_.isNil(uri) || _.isEmpty(uri)) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

async function generateViewCode(
  architectureName: string,
  targetDirectory: string
) {
  const shouldCreateDirectory = workspace
    .getConfiguration("bloc")
    .get<boolean>("newBlocArchitectureTemplate.createDirectory");
  const viewDirectoryPath = shouldCreateDirectory
    ? `${targetDirectory}/view`
    : targetDirectory;
  if (!existsSync(viewDirectoryPath)) {
    await createDirectory(viewDirectoryPath);
  }

  await Promise.all([createViewTemplate(architectureName, viewDirectoryPath)]);
}

async function generateBlocCode(
  architectureName: string,
  targetDirectory: string,
  type: BlocType
) {
  const shouldCreateDirectory = workspace
    .getConfiguration("bloc")
    .get<boolean>("newBlocArchitectureTemplate.createDirectory");
  const blocDirectoryPath = shouldCreateDirectory
    ? `${targetDirectory}/bloc`
    : targetDirectory;
  if (!existsSync(blocDirectoryPath)) {
    await createDirectory(blocDirectoryPath);
  }

  await Promise.all([
    createBlocEventTemplate(architectureName, blocDirectoryPath, type),
    createBlocStateTemplate(architectureName, blocDirectoryPath, type),
    createBlocTemplate(architectureName, blocDirectoryPath, type),
  ]);
}

async function generateDataCode(
  architectureName: string,
  targetDirectory: string
) {
  const shouldCreateDirectory = workspace
    .getConfiguration("bloc")
    .get<boolean>("newBlocArchitectureTemplate.createDirectory");
  const dataDirectoryPath = shouldCreateDirectory
    ? `${targetDirectory}/data`
    : targetDirectory;
  if (!existsSync(dataDirectoryPath)) {
    await createDirectory(dataDirectoryPath);
  }

  await Promise.all([
    createDataProviderTemplate(architectureName, dataDirectoryPath),
    createRepositoryTemplate(architectureName, dataDirectoryPath),
  ]);
}
async function generateBarrelFileCode(
  architectureName: string,
  targetDirectory: string
) {
  const dataDirectoryPath = targetDirectory;

  if (!existsSync(dataDirectoryPath)) {
    await createDirectory(dataDirectoryPath);
  }

  await Promise.all([
    createBarrelFileTemplate(architectureName, dataDirectoryPath),
  ]);
}

function createDirectory(targetDirectory: string): Promise<void> {
  return new Promise((resolve, reject) => {
    mkdirp(targetDirectory, (error) => {
      if (error) {
        return reject(error);
      }
      resolve();
    });
  });
}

function createBlocEventTemplate(
  architectureName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCasearchitectureName = changeCase.snakeCase(
    architectureName.toLowerCase()
  );
  const targetPath = `${targetDirectory}/${snakeCasearchitectureName}_event.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCasearchitectureName}_event.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocEventTemplate(architectureName, type),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createBlocStateTemplate(
  architectureName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCasearchitectureName = changeCase.snakeCase(
    architectureName.toLowerCase()
  );
  const targetPath = `${targetDirectory}/${snakeCasearchitectureName}_state.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCasearchitectureName}_state.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocStateTemplate(architectureName, type),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createBlocTemplate(
  architectureName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCasearchitectureName = changeCase.snakeCase(
    architectureName.toLowerCase()
  );
  const targetPath = `${targetDirectory}/${snakeCasearchitectureName}_bloc.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCasearchitectureName}_bloc.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocTemplate(architectureName, type),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createViewTemplate(viewName: string, targetDirectory: string) {
  const snakeCaseviewName = changeCase.snakeCase(viewName.toLowerCase());
  const targetPath = `${targetDirectory}/${snakeCaseviewName}_view.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseviewName}_view.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(targetPath, getViewTemplate(viewName), "utf8", (error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });
}
function createBarrelFileTemplate(viewName: string, targetDirectory: string) {
  const snakeCaseviewName = changeCase.snakeCase(viewName.toLowerCase());
  const targetPath = `${targetDirectory}/${snakeCaseviewName}_view.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseviewName}_view.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getArchitectureBarrelTemplate(viewName, "bloc"),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createRepositoryTemplate(
  architectureName: string,
  targetDirectory: string
) {
  const snakeCasearchitectureName = changeCase.snakeCase(
    architectureName.toLowerCase()
  );
  const targetPath = `${targetDirectory}/${snakeCasearchitectureName}_repository.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCasearchitectureName}_repository.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getRepositoryTemplate(architectureName),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createDataProviderTemplate(viewName: string, targetDirectory: string) {
  const snakeCaseviewName = changeCase.snakeCase(viewName.toLowerCase());
  const targetPath = `${targetDirectory}/${snakeCaseviewName}_data_provider.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseviewName}_data_provider.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getDataProviderTemplate(viewName),
      "utf8",
      (error) => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}
