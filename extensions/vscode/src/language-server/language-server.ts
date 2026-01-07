import { ExtensionContext, ProgressLocation, window } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";
import { getBlocToolsExecutable, installBlocTools } from "../utils";

let client: LanguageClient;

const DART_FILE = { language: "dart", scheme: "file" };
const ANALYSIS_OPTIONS_FILE = {
  pattern: "**/analysis_options.yaml",
  scheme: "file",
};

async function startLanguageServer(executable: string) {
  const serverOptions: ServerOptions = {
    command: `"${executable}"`,
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
    clientOptions,
  );

  return client.start();
}

async function startLanguageServerWithProgress(executable: string) {
  window.withProgress(
    {
      location: ProgressLocation.Window,
      title: "Bloc Analysis Server",
    },
    async () => {
      try {
        await startLanguageServer(executable);
        window.setStatusBarMessage("✓ Bloc Analysis Server", 3000);
      } catch (err) {
        window.showErrorMessage(`${err}`);
      }
    },
  );
}

async function tryStartLanguageServer(
  context: ExtensionContext,
): Promise<void> {
  const executable = await getBlocToolsExecutable(context);
  if (executable) return startLanguageServerWithProgress(executable);

  await window.withProgress(
    {
      location: ProgressLocation.Notification,
      title: "Installing the Bloc Language Server",
    },
    async () => {
      try {
        await installBlocTools(context);
        window.setStatusBarMessage("Bloc Language Server installed", 3000);
      } catch (err) {
        window.showErrorMessage(`${err}`);
      }
    },
  );

  const installedExecutable = await getBlocToolsExecutable(context);
  if (!installedExecutable) {
    window.showErrorMessage("Failed to install the Bloc Language Server");
    return;
  }

  return startLanguageServerWithProgress(installedExecutable);
}

export { client, tryStartLanguageServer };
