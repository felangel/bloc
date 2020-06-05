import * as _ from "lodash";
import * as fs from "fs";
import { getPubspec } from "./get-pubspec";
import { workspace } from "vscode";
import { getPubspecPath } from "./get-pubspec-path";

export function updatePubspecDependency(dependency: {
  name: string;
  version: string;
}) {
  const pubspec = getPubspec();
  const dependencies = _.get(pubspec, "dependencies");

  if (workspace.workspaceFolders && workspace.workspaceFolders.length > 0) {
    const pubspecPath = getPubspecPath();
    if (pubspecPath) {
      try {
        fs.writeFileSync(
          pubspecPath,
          fs
            .readFileSync(pubspecPath, "utf8")
            .replace(
              `${dependency.name}: ${dependencies[dependency.name]}`,
              `${dependency.name}: ${dependency.version}`
            )
        );
      } catch (_) {}
    }
  }
}
