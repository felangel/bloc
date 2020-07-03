import * as _ from "lodash";
import * as fs from "fs";
import { workspace } from "vscode";
import { getPubspecPath } from "./get-pubspec-path";

export function updatePubspecDependency(dependency: {
  name: string;
  latestVersion: string;
  currentVersion: string;
}) {
  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    const pubspecPath = getPubspecPath();
    if (pubspecPath) {
      try {
        fs.writeFileSync(
          pubspecPath,
          fs
            .readFileSync(pubspecPath, "utf8")
            .replace(
              `${dependency.name}: ${dependency.currentVersion}`,
              `${dependency.name}: ${dependency.latestVersion}`
            )
        );
      } catch (_) {}
    }
  }
}
