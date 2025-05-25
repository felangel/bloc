import * as _ from "lodash";

import {
  commands,
  ExtensionContext,
  languages,
  window,
  workspace,
} from "vscode";
import { BlocCodeActionProvider } from "./code-actions";
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
import { analyzeDependencies, setShowContextMenu } from "./utils";
import { client, DART_FILE, tryStartLanguageServer } from "./language-server";

export function activate(context: ExtensionContext) {
  if (
    workspace.getConfiguration("bloc").get<boolean>("languageServer.enabled")
  ) {
    tryStartLanguageServer(context);
  }

  if (workspace.getConfiguration("bloc").get<boolean>("checkForUpdates")) {
    analyzeDependencies();
  }

  setShowContextMenu();

  context.subscriptions.push(
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
      DART_FILE,
      new BlocCodeActionProvider()
    )
  );
}

export function deactivate(): Thenable<void> | undefined {
  if (!client) return undefined;
  return client.stop();
}
