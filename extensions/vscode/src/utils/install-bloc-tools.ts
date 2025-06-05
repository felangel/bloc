import { arch, type } from "node:os";
import { ExtensionContext, Uri } from "vscode";
import { downloadFile } from ".";

export const BLOC_TOOLS_VERSION = "0.1.0-dev.14";
export const installBlocTools = async (
  context: ExtensionContext
): Promise<boolean> => {
  try {
    const os = getOS();
    if (os === OperatingSystem.unknown) return false;
    const arch = getArch();
    if (arch == Architecture.unknown) return false;
    await downloadFile(
      Uri.parse(
        `https://github.com/felangel/bloc/releases/download/bloc_tools-v${BLOC_TOOLS_VERSION}/bloc_${os}_${arch}`
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
  const hostOS = type();
  switch (hostOS) {
    case "Linux":
      return OperatingSystem.linux;
    case "Darwin":
      return OperatingSystem.macos;
    case "Windows_NT":
      return OperatingSystem.windows;
  }
  return OperatingSystem.unknown;
}

function getArch(): Architecture {
  const hostArch = arch();
  switch (hostArch) {
    case "arm64":
      return Architecture.arm64;
    case "x64":
      return Architecture.x64;
  }
  return Architecture.unknown;
}

enum OperatingSystem {
  linux = "linux",
  macos = "macos",
  windows = "windows",
  unknown = "-",
}

enum Architecture {
  arm64 = "arm64",
  x64 = "x64",
  unknown = "-",
}
