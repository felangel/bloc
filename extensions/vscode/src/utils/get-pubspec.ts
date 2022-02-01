import * as yaml from "js-yaml";
import { getPubspecPath, getPubspecLockPath } from "./get-pubspec-path";
import { workspace, Uri } from "vscode";

export async function getPubspec(): Promise<Record<string, any> | undefined> {
  const pubspecPath = getPubspecPath();
  return getYAMLFileContent(pubspecPath);
}

export async function getPubspecLock(): Promise<Record<string, any> | undefined> {
  const pubspecLockPath = getPubspecLockPath();
  return getYAMLFileContent(pubspecLockPath);
}

async function getYAMLFileContent(path: string | undefined): Promise<Record<string, any> | undefined> {
  if (path) {
    try {
      let content = await workspace.fs.readFile(Uri.file(path));
      return yaml.load(content.toString());
    } catch (_) {}
  }
}
