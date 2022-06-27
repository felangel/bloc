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
} from "../templates";
import { getBlocType, BlocType, TemplateType } from "../utils";

export const newBloc = async (uri: Uri) => {
  const blocName = await promptForBlocName();
  if (_.isNil(blocName) || blocName.trim() === "") {
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
  const pascalCaseBlocName = changeCase.pascalCase(blocName);
  try {
    await generateBlocCode(blocName, targetDirectory, blocType);
    window.showInformationMessage(
      `Successfully Generated ${pascalCaseBlocName} Bloc`
    );
  } catch (error) {
    window.showErrorMessage(
      `Error:
        ${error instanceof Error ? error.message : JSON.stringify(error)}`
    );
  }
};

function promptForBlocName(): Thenable<string | undefined> {
  const blocNamePromptOptions: InputBoxOptions = {
    prompt: "Bloc Name",
    placeHolder: "counter",
  };
  return window.showInputBox(blocNamePromptOptions);
}

async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder to create the bloc in",
    canSelectFolders: true,
  };

  return window.showOpenDialog(options).then((uri) => {
    if (_.isNil(uri) || _.isEmpty(uri)) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

async function generateBlocCode(
  blocName: string,
  targetDirectory: string,
  type: BlocType
) {
  const shouldCreateDirectory = workspace
    .getConfiguration("bloc")
    .get<boolean>("newBlocTemplate.createDirectory");
  const blocDirectoryPath = shouldCreateDirectory
    ? `${targetDirectory}/bloc`
    : targetDirectory;
  if (!existsSync(blocDirectoryPath)) {
    await createDirectory(blocDirectoryPath);
  }

  await Promise.all([
    createBlocEventTemplate(blocName, blocDirectoryPath, type),
    createBlocStateTemplate(blocName, blocDirectoryPath, type),
    createBlocTemplate(blocName, blocDirectoryPath, type),
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
  blocName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const targetPath = `${targetDirectory}/${snakeCaseBlocName}_event.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseBlocName}_event.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocEventTemplate(blocName, type),
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
  blocName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const targetPath = `${targetDirectory}/${snakeCaseBlocName}_state.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseBlocName}_state.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocStateTemplate(blocName, type),
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
  blocName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName);
  const targetPath = `${targetDirectory}/${snakeCaseBlocName}_bloc.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseBlocName}_bloc.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(targetPath, getBlocTemplate(blocName, type), "utf8", (error) => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });
}
