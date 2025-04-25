import { ProgressLocation, window } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";
import { areBlocToolsInstalled, installBlocTools } from "../utils";

let client: LanguageClient;

const DART_FILE = { language: "dart", scheme: "file" };
const ANALYSIS_OPTIONS_FILE = {
  pattern: "**/analysis_options.yaml",
  scheme: "file",
};

async function tryStartLanguageServer(): Promise<void> {
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

export { tryStartLanguageServer, client };
