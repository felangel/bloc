import * as yaml from "js-yaml";
import { getPubspecPath } from "./get-pubspec-path";
import { workspace, Uri } from "vscode";

export async function getPubspec(): Promise<Record<string, any> | undefined> {
  const pubspecPath = getPubspecPath();
  if (pubspecPath) {
    try {
      let content = await workspace.fs.readFile(Uri.file(pubspecPath));
      return yaml.load(content.toString());
    } catch (_) {}
  }
}
