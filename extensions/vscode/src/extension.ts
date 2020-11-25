import * as _ from "lodash";

import { commands, ExtensionContext, languages, workspace } from "vscode";
import { analyzeDependencies } from "./utils";
import {
  newBloc,
  newCubit,
  wrapWithBlocBuilder,
  wrapWithBlocListener,
  wrapWithBlocConsumer,
  wrapWithBlocProvider,
  wrapWithRepositoryProvider,
} from "./commands";
import { BlocCodeActionProvider } from "./code-actions";

const DART_MODE = { language: "dart", scheme: "file" };

export function activate(_context: ExtensionContext) {
  if (workspace.getConfiguration("bloc").get<boolean>("checkForUpdates")) {
    analyzeDependencies();
  }

  _context.subscriptions.push(
    commands.registerCommand("extension.new-bloc", newBloc),
    commands.registerCommand("extension.new-cubit", newCubit),
    commands.registerCommand("extension.wrap-blocbuilder", wrapWithBlocBuilder),
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
