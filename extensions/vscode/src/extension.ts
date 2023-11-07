import * as _ from "lodash";
import * as yaml from "js-yaml";

import {
  commands,
  ExtensionContext,
  languages,
  Uri,
  window,
  workspace,
} from "vscode";
import { analyzeDependencies } from "./utils";
import {
  convertToMultiBlocListener,
  convertToMultiBlocProvider,
  convertToMultiRepositoryProvider,
  newBloc,
  newCubit,
  wrapWithBlocBuilder,
  wrapWithBlocConsumer,
  wrapWithBlocListener,
  wrapWithBlocProvider,
  wrapWithBlocSelector,
  wrapWithRepositoryProvider,
} from "./commands";
import { BlocCodeActionProvider } from "./code-actions";

const DART_MODE = { language: "dart", scheme: "file" };

export function activate(_context: ExtensionContext) {
  if (workspace.getConfiguration("bloc").get<boolean>("checkForUpdates")) {
    analyzeDependencies();
  }

  setShowContextMenu();

  _context.subscriptions.push(
    window.onDidChangeActiveTextEditor((_) => setShowContextMenu()),
    workspace.onDidChangeWorkspaceFolders((_) => setShowContextMenu()),
    workspace.onDidChangeTextDocument(async function (event) {
      if (event.document.uri.fsPath.endsWith("pubspec.yaml")) {
        setShowContextMenu(event.document.uri);
      }
    }),
    commands.registerCommand("extension.new-bloc", newBloc),
    commands.registerCommand("extension.new-cubit", newCubit),
    commands.registerCommand(
      "extension.convert-multibloclistener",
      convertToMultiBlocListener,
    ),
    commands.registerCommand(
      "extension.convert-multiblocprovider",
      convertToMultiBlocProvider,
    ),
    commands.registerCommand(
      "extension.convert-multirepositoryprovider",
      convertToMultiRepositoryProvider,
    ),
    commands.registerCommand("extension.wrap-blocbuilder", wrapWithBlocBuilder),
    commands.registerCommand(
      "extension.wrap-blocselector",
      wrapWithBlocSelector,
    ),
    commands.registerCommand(
      "extension.wrap-bloclistener",
      wrapWithBlocListener,
    ),
    commands.registerCommand(
      "extension.wrap-blocconsumer",
      wrapWithBlocConsumer,
    ),
    commands.registerCommand(
      "extension.wrap-blocprovider",
      wrapWithBlocProvider,
    ),
    commands.registerCommand(
      "extension.wrap-repositoryprovider",
      wrapWithRepositoryProvider,
    ),
    languages.registerCodeActionsProvider(
      DART_MODE,
      new BlocCodeActionProvider(),
    ),
  );
}

async function setShowContextMenu(pubspec?: Uri | undefined): Promise<void> {
  async function pubspecIncludesBloc(pubspec: Uri): Promise<boolean> {
    try {
      const content = await workspace.fs.readFile(pubspec);
      const yamlContent = yaml.load(content.toString());
      const dependencies = _.get(yamlContent, "dependencies", {});
      return [
        "angular_bloc",
        "bloc",
        "flutter_bloc",
        "hydrated_bloc",
        "replay_bloc",
      ].some((d) => dependencies.hasOwnProperty(d));
    } catch (_) {}
    return false;
  }

  async function workspaceIncludesBloc(): Promise<boolean> {
    try {
      const pubspecs = await workspace.findFiles("**/**/pubspec.yaml");
      for (const pubspec of pubspecs) {
        if (await pubspecIncludesBloc(pubspec)) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  commands.executeCommand(
    "setContext",
    "bloc.showContextMenu",
    pubspec
      ? await pubspecIncludesBloc(pubspec)
      : await workspaceIncludesBloc(),
  );
}
