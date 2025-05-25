import { BLOC_TOOLS_VERSION, tryGetDownload } from ".";
import { ExtensionContext } from "vscode";

export const getBlocToolsExecutable = async (
  context: ExtensionContext
): Promise<string | null> => {
  try {
    const executable = await tryGetDownload(
      `bloc_${BLOC_TOOLS_VERSION}`,
      context
    );
    if (!executable) return null;
    return executable.fsPath;
  } catch (_) {
    return null;
  }
};
