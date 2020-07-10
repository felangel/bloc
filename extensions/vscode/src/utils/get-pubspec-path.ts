import { workspace } from "vscode";
import * as path from "path";

export function getPubspecPath(): string | undefined {
  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    return path.join(
      `${workspace.workspaceFolders[0].uri.path}`,
      "pubspec.yaml"
    );
  }
}
