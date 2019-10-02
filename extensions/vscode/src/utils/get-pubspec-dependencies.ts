import * as fs from "fs";
import * as yaml from "js-yaml";
import { workspace } from "vscode";

export function getPubspecDependencies(): Record<string, any> | undefined {
  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    try {
      const pubspec = yaml.safeLoad(
        fs.readFileSync(
          `${workspace.workspaceFolders[0].uri.path}/pubspec.yaml`,
          "utf8"
        )
      );
      return pubspec["dependencies"];
    } catch (_) {}
  }
}
