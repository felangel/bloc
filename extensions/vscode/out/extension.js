"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : new P(function (resolve) { resolve(result.value); }).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const _ = require("lodash");
const changeCase = require("change-case");
const mkdirp = require("mkdirp");
const rimraf = require("rimraf");
const vscode_1 = require("vscode");
const fs_1 = require("fs");
const templates_1 = require("./templates");
function activate(context) {
    vscode_1.commands.registerCommand("extension.new-bloc", () => __awaiter(this, void 0, void 0, function* () {
        const blocName = yield promptForBlocName();
        if (_.isNil(blocName) || blocName.trim() === "") {
            vscode_1.window.showErrorMessage("The bloc name must not be empty");
            return;
        }
        const uri = yield promptForPath();
        if (_.isNil(uri) || _.isEmpty(uri)) {
            vscode_1.window.showErrorMessage("Please select a valid directory");
            return;
        }
        const path = uri[0].fsPath;
        const useEquatable = (yield promptForUseEquatable()) === "yes";
        const pascalCaseBlocName = changeCase.pascalCase(blocName.toLowerCase());
        try {
            yield generateBlocCode(blocName, path, useEquatable);
            vscode_1.window.showInformationMessage(`Successfully Generated ${pascalCaseBlocName} Bloc`);
        }
        catch (error) {
            vscode_1.window.showErrorMessage(`Failed to Generate ${pascalCaseBlocName} Bloc`);
        }
    }));
}
exports.activate = activate;
function promptForBlocName() {
    const blocNamePromptOptions = {
        prompt: "Bloc Name",
        placeHolder: "counter"
    };
    return vscode_1.window.showInputBox(blocNamePromptOptions);
}
function promptForUseEquatable() {
    const useEquatablePromptValues = ["yes", "no"];
    const useEquatablePromptOptions = {
        placeHolder: "Do you want to use the Equatable Package in this Bloc?"
    };
    return vscode_1.window.showQuickPick(useEquatablePromptValues, useEquatablePromptOptions);
}
function promptForPath() {
    const options = {
        canSelectMany: false,
        openLabel: "Select a folder to create the bloc in",
        canSelectFolders: true
    };
    return vscode_1.window.showOpenDialog(options);
}
function generateBlocCode(blocName, path, useEquatable) {
    return __awaiter(this, void 0, void 0, function* () {
        yield createBlocDirectory(path);
        yield Promise.all([
            createBlocEventTemplate(blocName, path, useEquatable),
            createBlocStateTemplate(blocName, path, useEquatable),
            createBlocTemplate(blocName, path),
            createBarrelTemplate(blocName, path)
        ]);
    });
}
function createBlocDirectory(path) {
    const basePath = `${path}/bloc`;
    if (fs_1.existsSync(basePath)) {
        rimraf.sync(basePath);
    }
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        try {
            yield createDirectory(basePath);
            return resolve();
        }
        catch (error) {
            return reject(error);
        }
    }));
}
function createDirectory(path) {
    return new Promise((resolve, reject) => {
        mkdirp(path, error => {
            if (error) {
                return reject(error);
            }
            resolve();
        });
    });
}
function createBlocEventTemplate(blocName, basePath, useEquatable) {
    const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
    const targetPath = `${basePath}/bloc/${snakeCaseBlocName}_event.dart`;
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        fs_1.writeFile(targetPath, templates_1.getBlocEventTemplate(blocName, useEquatable), "utf8", error => {
            if (error) {
                reject(error);
                return;
            }
            resolve();
        });
    }));
}
function createBlocStateTemplate(blocName, basePath, useEquatable) {
    const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
    const targetPath = `${basePath}/bloc/${snakeCaseBlocName}_state.dart`;
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        fs_1.writeFile(targetPath, templates_1.getBlocStateTemplate(blocName, useEquatable), "utf8", error => {
            if (error) {
                reject(error);
                return;
            }
            resolve();
        });
    }));
}
function createBlocTemplate(blocName, basePath) {
    const snakeCaseBlocName = changeCase.snakeCase(blocName.toLowerCase());
    const targetPath = `${basePath}/bloc/${snakeCaseBlocName}_bloc.dart`;
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        fs_1.writeFile(targetPath, templates_1.getBlocTemplate(blocName), "utf8", error => {
            if (error) {
                reject(error);
                return;
            }
            resolve();
        });
    }));
}
function createBarrelTemplate(blocName, basePath) {
    const targetPath = `${basePath}/bloc/bloc.dart`;
    return new Promise((resolve, reject) => __awaiter(this, void 0, void 0, function* () {
        fs_1.writeFile(targetPath, templates_1.getBarrelTemplate(blocName), "utf8", error => {
            if (error) {
                reject(error);
                return;
            }
            resolve();
        });
    }));
}
//# sourceMappingURL=extension.js.map