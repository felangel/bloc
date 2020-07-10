import * as yaml from "js-yaml";
import { getPubspecPath } from "./get-pubspec-path";
import { window, workspace, Uri } from "vscode";

export async function getPubspec(): Promise<Record<string, any> | undefined> {
  const pubspecPath = getPubspecPath();
  if (pubspecPath) {
    try {
      let content = await workspace.fs.readFile(Uri.file(pubspecPath));
      return yaml.safeLoad(content.toString());
    } catch (e) {
      window.showErrorMessage(e.toString());
    }
  }
}
