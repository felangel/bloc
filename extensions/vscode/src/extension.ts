import * as _ from "lodash";
import * as changeCase from "change-case";
import * as mkdirp from "mkdirp";
import * as rimraf from "rimraf";
import {
  commands,
  ExtensionContext,
  InputBoxOptions,
  OpenDialogOptions,
  QuickPickOptions,
  Uri,
  window
} from "vscode";
import { existsSync, lstatSync, writeFile } from "fs";
import {
  getBarrelTemplate,
  getBlocEventTemplate,
  getBlocStateTemplate,
  getBlocTemplate
} from "./templates";

export function activate(_context: ExtensionContext) {
  commands.registerCommand("extension.new-bloc", async (uri: Uri) => {
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

    const useEquatable = (await promptForUseEquatable()) === "yes (advanced)";

    const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
    try {
      await generateBlocCode(blocName, targetDirectory, useEquatable);
      window.showInformationMessage(
        `Successfully Generated ${pascalCaseBlocName} Bloc`
      );
    } catch (error) {
      window.showErrorMessage(
        `Failed to Generate ${pascalCaseBlocName} Bloc
        ${JSON.stringify(error)}`
      );
    }
  });
}

function promptForBlocName(): Thenable<string | undefined> {
  const blocNamePromptOptions: InputBoxOptions = {
    prompt: "Bloc Name",
    placeHolder: "counter"
  };
  return window.showInputBox(blocNamePromptOptions);
}

function promptForUseEquatable(): Thenable<string | undefined> {
  const useEquatablePromptValues: string[] = ["no (default)", "yes (advanced)"];
  const useEquatablePromptOptions: QuickPickOptions = {
    placeHolder:
      "Do you want to use the Equatable Package in this bloc to override equality comparisons?",
    canPickMany: false
  };
  return window.showQuickPick(
    useEquatablePromptValues,
    useEquatablePromptOptions
  );
}

async function promptForTargetDirectory(): Promise<string | undefined> {
  const options: OpenDialogOptions = {
    canSelectMany: false,
    openLabel: "Select a folder to create the bloc in",
    canSelectFolders: true
  };

  return window.showOpenDialog(options).then(uri => {
    if (_.isNil(uri) || _.isEmpty(uri)) {
      return undefined;
    }
    return uri[0].fsPath;
  });
}

async function generateBlocCode(
  blocName: string,
  targetDirectory: string,
  useEquatable: boolean
) {
  await createBlocDirectory(targetDirectory);
  await Promise.all([
    createBlocEventTemplate(blocName, targetDirectory, useEquatable),
    createBlocStateTemplate(blocName, targetDirectory, useEquatable),
    createBlocTemplate(blocName, targetDirectory),
    createBarrelTemplate(blocName, targetDirectory)
  ]);
}

function createBlocDirectory(targetDirectory: string): Promise<void> {
  const basePath = `${targetDirectory}/bloc`;
  if (existsSync(basePath)) {
    rimraf.sync(basePath);
  }

  return new Promise(async (resolve, reject) => {
    try {
      await createDirectory(basePath);
      return resolve();
    } catch (error) {
      return reject(error);
    }
  });
}

function createDirectory(targetDirectory: string): Promise<void> {
  return new Promise((resolve, reject) => {
    mkdirp(targetDirectory, error => {
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
  useEquatable: boolean
) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  const targetPath = `${targetDirectory}/bloc/${snakeCaseBlocName}_event.dart`;
  return new Promise(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocEventTemplate(blocName, useEquatable),
      "utf8",
      error => {
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
  useEquatable: boolean
) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  const targetPath = `${targetDirectory}/bloc/${snakeCaseBlocName}_state.dart`;
  return new Promise(async (resolve, reject) => {
    writeFile(
      targetPath,
      getBlocStateTemplate(blocName, useEquatable),
      "utf8",
      error => {
        if (error) {
          reject(error);
          return;
        }
        resolve();
      }
    );
  });
}

function createBlocTemplate(blocName: string, targetDirectory: string) {
  const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
  const targetPath = `${targetDirectory}/bloc/${snakeCaseBlocName}_bloc.dart`;
  return new Promise(async (resolve, reject) => {
    writeFile(targetPath, getBlocTemplate(blocName), "utf8", error => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });
}

function createBarrelTemplate(blocName: string, targetDirectory: string) {
  const targetPath = `${targetDirectory}/bloc/bloc.dart`;
  return new Promise(async (resolve, reject) => {
    writeFile(targetPath, getBarrelTemplate(blocName), "utf8", error => {
      if (error) {
        reject(error);
        return;
      }
      resolve();
    });
  });
}
