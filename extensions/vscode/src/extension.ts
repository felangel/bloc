import * as _ from "lodash";
import * as yaml from "js-yaml";

import {
  commands,
  ExtensionContext,
  languages,
  workspace,
  window,
} from "vscode";
import { analyzeDependencies } from "./utils";
import {
  newBloc,
  newCubit,
  convertToMultiBlocListener,
  convertToMultiBlocProvider,
  convertToMultiRepositoryProvider,
  wrapWithBlocBuilder,
  wrapWithBlocListener,
  wrapWithBlocConsumer,
  wrapWithBlocProvider,
  wrapWithRepositoryProvider,
  wrapWithBlocSelector,
} from "./commands";
import { BlocCodeActionProvider } from "./code-actions";

const DART_MODE = { language: "dart", scheme: "file" };

export function activate(_context: ExtensionContext) {
  if (workspace.getConfiguration("bloc").get<boolean>("checkForUpdates")) {
    analyzeDependencies();
  }

  updateAnyBlocProjectLoaded();

  _context.subscriptions.push(
    window.onDidChangeActiveTextEditor(updateAnyBlocProjectLoaded),
    workspace.onDidChangeWorkspaceFolders(updateAnyBlocProjectLoaded),
    workspace.onDidChangeTextDocument((event) => {
      if (
        event.document.languageId === "yaml" &&
        event.document.uri.fsPath.endsWith("pubspec.yaml")
      ) {
        updateAnyBlocProjectLoaded();
      }
    }),
    commands.registerCommand("extension.new-bloc", newBloc),
    commands.registerCommand("extension.new-cubit", newCubit),
    commands.registerCommand(
      "extension.convert-multibloclistener",
      convertToMultiBlocListener
    ),
    commands.registerCommand(
      "extension.convert-multiblocprovider",
      convertToMultiBlocProvider
    ),
    commands.registerCommand(
      "extension.convert-multirepositoryprovider",
      convertToMultiRepositoryProvider
    ),
    commands.registerCommand("extension.wrap-blocbuilder", wrapWithBlocBuilder),
    commands.registerCommand(
      "extension.wrap-blocselector",
      wrapWithBlocSelector
    ),
    commands.registerCommand(
      "extension.wrap-bloclistener",
      wrapWithBlocListener
    ),
    commands.registerCommand(
      "extension.wrap-blocconsumer",
      wrapWithBlocConsumer
    ),
    commands.registerCommand(
      "extension.wrap-blocprovider",
      wrapWithBlocProvider
    ),
    commands.registerCommand(
      "extension.wrap-repositoryprovider",
      wrapWithRepositoryProvider
    ),
    languages.registerCodeActionsProvider(
      DART_MODE,
      new BlocCodeActionProvider()
    )
  );
}

/**
 * Sets "dart-frog:anyBlocProjectLoaded" context to "true" if a Bloc
 * project is loaded in the workspace, or "false" otherwise.
 *
 * This provides "bloc:anyDartFrogProjectLoaded" as a custom when clause,
 * to be used in the "package.json" file to enable or disable commands based on
 * whether a Bloc project is loaded in the workspace.
 *
 * @see {@link https://code.visualstudio.com/api/references/when-clause-contexts#add-a-custom-when-clause-context} for further details about custom when clause context.
 */
async function updateAnyBlocProjectLoaded(): Promise<void> {
  commands.executeCommand(
    "setContext",
    "bloc:anyBlocProjectLoaded",
    await canResolveBlocProject()
  );
}

/**
 * Returns true if a Bloc project is loaded in the workspace, or false otherwise.
 *
 * A project is considered a Bloc project if it has either the `bloc` or `flutter_bloc`
 * dependency in at least one `pubspec.yaml` .
 *
 * @returns {Promise<boolean>} true if a Bloc project is loaded in the workspace, or
 * false otherwise.
 */
async function canResolveBlocProject(): Promise<boolean> {
  const pubspecs = await workspace.findFiles("**/pubspec.yaml");
  for (const pubspec of pubspecs) {
    try {
      const content = await workspace.fs.readFile(pubspec);
      const yamlContent = yaml.load(content.toString());
      const dependencies = _.get(yamlContent, "dependencies", {});
      if (_.has(dependencies, "bloc") || _.has(dependencies, "flutter_bloc")) {
        return true;
      }
    } catch (_) {}
  }

  return false;
}
