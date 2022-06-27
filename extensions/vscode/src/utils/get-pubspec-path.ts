import { workspace } from "vscode";
import * as path from "path";

const PUBSPEC_FILE_NAME = "pubspec.yaml";
const PUBSPEC_LOCK_FILE_NAME = "pubspec.lock";

export function getPubspecPath(): string | undefined {
  return getWorkspacePath(PUBSPEC_FILE_NAME);
}

export function getPubspecLockPath(): string | undefined {
  return getWorkspacePath(PUBSPEC_LOCK_FILE_NAME);
}

function getWorkspacePath(fileName: string): string | undefined {
  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    return path.join(
      `${workspace.workspaceFolders[0].uri.path}`,
      fileName
    );
  }
}
