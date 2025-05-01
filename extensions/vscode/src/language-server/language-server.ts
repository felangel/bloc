import { ProgressLocation, window } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";
import {
  blocToolsVersion,
  getBlocToolsVersion,
  installBlocTools,
} from "../utils";

let client: LanguageClient;

const DART_FILE = { language: "dart", scheme: "file" };
const ANALYSIS_OPTIONS_FILE = {
  pattern: "**/analysis_options.yaml",
  scheme: "file",
};

async function tryStartLanguageServer(): Promise<void> {
  const version = await getBlocToolsVersion();
  const isInstalled = version != null;

  if (version !== blocToolsVersion) {
    var didInstall = false;
    await window.withProgress(
      {
        location: ProgressLocation.Notification,
        title: isInstalled ? "Upgrading Bloc Tools" : "Installing Bloc Tools",
      },
      async () => {
        try {
          didInstall = await installBlocTools();
          window.setStatusBarMessage(
            isInstalled ? "✓ Bloc Tools Upgraded" : "✓ Bloc Tools Installed",
            3000
          );
        } catch (err) {
          window.showErrorMessage(`${err}`);
        }
      }
    );

    if (!didInstall) {
      window.showErrorMessage(
        isInstalled
          ? "✗ Unable to upgrade Bloc Tools"
          : "✗ Unable to install Bloc Tools"
      );
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
    async () => {
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
