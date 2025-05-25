import { type } from "node:os";
import { ExtensionContext, Uri } from "vscode";
import { downloadFile } from ".";

export const BLOC_TOOLS_VERSION = "0.1.0-dev.12";
export const installBlocTools = async (
  context: ExtensionContext
): Promise<boolean> => {
  try {
    const os = getOS();
    await downloadFile(
      Uri.parse(
        `https://github.com/felangel/bloc/releases/download/bloc_tools-v${BLOC_TOOLS_VERSION}/bloc_${os}`
      ),
      `bloc_${BLOC_TOOLS_VERSION}`,
      context
    );
    return true;
  } catch (_) {
    return false;
  }
};

function getOS(): OperatingSystem {
  const osType = type();
  switch (osType) {
    case "Linux":
      return OperatingSystem.linux;
    case "Darwin":
      return OperatingSystem.macos;
    case "Windows_NT":
      return OperatingSystem.windows;
  }
  return OperatingSystem.unknown;
}

enum OperatingSystem {
  linux = "linux",
  macos = "macos",
  windows = "windows",
  unknown = "-",
}
