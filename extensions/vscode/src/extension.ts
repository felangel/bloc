import * as _ from "lodash";

import {
  commands,
  ExtensionContext,
  languages,
  ProgressLocation,
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
import {
  analyzeDependencies,
  areBlocToolsInstalled,
  installBlocTools,
  setShowContextMenu,
} from "./utils";

const DART_FILE = { language: "dart", scheme: "file" };
const ANALYSIS_OPTIONS_FILE = {
  pattern: "**/analysis_options.yaml",
  scheme: "file",
};

import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";

let client: LanguageClient;

async function startLanguageServer() {
  const serverOptions: ServerOptions = {
    command: "bloc",
    args: ["language-server"],
    options: {
      env: process.env,
      shell: true,
    },
    transport: TransportKind.stdio,
  };

  const clientOptions: LanguageClientOptions = {
    revealOutputChannelOn: RevealOutputChannelOn.Info,
    documentSelector: [DART_FILE, ANALYSIS_OPTIONS_FILE],
  };

  client = new LanguageClient(
    "blocAnalysisLSP",
    "Bloc Analysis Server",
    serverOptions,
    clientOptions
  );

  return client.start();
}

async function tryInitLanguageServer(): Promise<void> {
  const installed = await areBlocToolsInstalled();

  if (!installed) {
    var didInstall = false;
    await window.withProgress(
      {
        location: ProgressLocation.Window,
        title: "Installing Bloc Tools",
      },
      async (_) => {
        try {
          didInstall = await installBlocTools();
          window.setStatusBarMessage("✓ Bloc Tools Installed", 3000);
        } catch (err) {
          window.showErrorMessage(`${err}`);
        }
      }
    );

    if (!didInstall) {
      window.setStatusBarMessage("✗ Unable to install Bloc Tools", 3000);
      return;
    }
  }

  window.withProgress(
    {
      location: ProgressLocation.Window,
      title: "Bloc Analysis Server",
    },
    async (_) => {
      try {
        await startLanguageServer();
        window.setStatusBarMessage("✓ Bloc Analysis Server", 3000);
      } catch (err) {
        window.showErrorMessage(`${err}`);
      }
    }
  );
}

export function activate(context: ExtensionContext) {
  tryInitLanguageServer();

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
