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
import { getCubitStateTemplate, getCubitTemplate } from "../templates";
import { getBlocType, BlocType, TemplateType } from "../utils";

export const newCubit = async (uri: Uri) => {
  const cubitName = await promptForCubitName();
  if (_.isNil(cubitName) || cubitName.trim() === "") {
    window.showErrorMessage("The cubit name must not be empty");
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

  const blocType = await getBlocType(TemplateType.Cubit);
  const pascalCaseCubitName = changeCase.pascalCase(cubitName);
  try {
    await generateCubitCode(cubitName, targetDirectory, blocType);
    window.showInformationMessage(
      `Successfully Generated ${pascalCaseCubitName} Cubit`
    );
  } catch (error) {
    window.showErrorMessage(
      `Error:
        ${error instanceof Error ? error.message : JSON.stringify(error)}`
    );
  }
};

function promptForCubitName(): Thenable<string | undefined> {
  const cubitNamePromptOptions: InputBoxOptions = {
    prompt: "Cubit Name",
    placeHolder: "counter",
  };
  return window.showInputBox(cubitNamePromptOptions);
}

async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder to create the cubit in",
    canSelectFolders: true,
  };

  return window.showOpenDialog(options).then((uri) => {
    if (_.isNil(uri) || _.isEmpty(uri)) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

async function generateCubitCode(
  cubitName: string,
  targetDirectory: string,
  type: BlocType
) {
  const shouldCreateDirectory = workspace
    .getConfiguration("bloc")
    .get<boolean>("newCubitTemplate.createDirectory");
  const cubitDirectoryPath = shouldCreateDirectory
    ? `${targetDirectory}/cubit`
    : targetDirectory;
  if (!existsSync(cubitDirectoryPath)) {
    await createDirectory(cubitDirectoryPath);
  }

  await Promise.all([
    createCubitStateTemplate(cubitName, cubitDirectoryPath, type),
    createCubitTemplate(cubitName, cubitDirectoryPath, type),
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

function createCubitStateTemplate(
  cubitName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const targetPath = `${targetDirectory}/${snakeCaseCubitName}_state.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseCubitName}_state.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getCubitStateTemplate(cubitName, type),
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

function createCubitTemplate(
  cubitName: string,
  targetDirectory: string,
  type: BlocType
) {
  const snakeCaseCubitName = changeCase.snakeCase(cubitName);
  const targetPath = `${targetDirectory}/${snakeCaseCubitName}_cubit.dart`;
  if (existsSync(targetPath)) {
    throw Error(`${snakeCaseCubitName}_cubit.dart already exists`);
  }
  return new Promise<void>(async (resolve, reject) => {
    writeFile(
      targetPath,
      getCubitTemplate(cubitName, type),
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
