import { workspace } from "vscode";

export function getPubspecPath(): string | undefined {
  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    return `${workspace.workspaceFolders[0].uri.path}/pubspec.yaml`;
  }
}
