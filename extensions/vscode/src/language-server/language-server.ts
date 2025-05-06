import * as semver from "semver";
import { ProgressLocation, window } from "vscode";
import {
  LanguageClient,
  LanguageClientOptions,
  RevealOutputChannelOn,
  ServerOptions,
  TransportKind,
} from "vscode-languageclient/node";
import {
  BLOC_TOOLS_VERSION,
  getBlocToolsVersion,
  getDartVersion,
  installBlocTools,
} from "../utils";

let client: LanguageClient;

const DART_FILE = { language: "dart", scheme: "file" };
const ANALYSIS_OPTIONS_FILE = {
  pattern: "**/analysis_options.yaml",
  scheme: "file",
};

const DART_SDK_CONSTRAINT = "^3.7.0";

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

async function startLanguageServerWithProgress() {
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

async function tryStartLanguageServer(): Promise<void> {
  const blocToolsVersion = await getBlocToolsVersion();
  if (blocToolsVersion == BLOC_TOOLS_VERSION) {
    return startLanguageServerWithProgress();
  }

  const dartVersion = await getDartVersion();
  if (!dartVersion) {
    window.showWarningMessage(
      "The Bloc Language Server requires Dart to be installed"
    );
    return;
  }

  if (!semver.satisfies(dartVersion, DART_SDK_CONSTRAINT)) {
    window.showWarningMessage(
      `The Bloc Language Server requires a newer version of Dart (${DART_SDK_CONSTRAINT})`
    );
    return;
  }

  const areBlocToolsInstalled = blocToolsVersion != null;
  var didActivate = false;
  await window.withProgress(
    {
      location: ProgressLocation.Notification,
      title: areBlocToolsInstalled
        ? "Upgrading the Bloc Language Server"
        : "Installing the Bloc Language Server",
    },
    async () => {
      try {
        didActivate = await installBlocTools();
        window.setStatusBarMessage(
          areBlocToolsInstalled
            ? "Bloc Language Server upgraded"
            : "Bloc Language Server installed",
          3000
        );
      } catch (err) {
        window.showErrorMessage(`${err}`);
      }
    }
  );

  if (!didActivate) {
    window.showErrorMessage(
      areBlocToolsInstalled
        ? "Failed to upgrade the Bloc Language Server"
        : "Failed to install the Bloc Language Server"
    );
    return;
  }

  return startLanguageServerWithProgress();
}

export { client, tryStartLanguageServer };
