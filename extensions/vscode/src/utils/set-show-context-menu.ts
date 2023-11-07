import * as yaml from "js-yaml";
import * as _ from "lodash";

import { commands, Uri, workspace } from "vscode";

export async function setShowContextMenu(
  pubspec?: Uri | undefined,
): Promise<void> {
  async function pubspecIncludesBloc(pubspec: Uri): Promise<boolean> {
    try {
      const content = await workspace.fs.readFile(pubspec);
      const yamlContent = yaml.load(content.toString());
      const dependencies = _.get(yamlContent, "dependencies", {});
      return [
        "angular_bloc",
        "bloc",
        "flutter_bloc",
        "hydrated_bloc",
        "replay_bloc",
      ].some((d) => dependencies.hasOwnProperty(d));
    } catch (_) {}
    return false;
  }

  async function workspaceIncludesBloc(): Promise<boolean> {
    try {
      const pubspecs = await workspace.findFiles("**/**/pubspec.yaml");
      for (const pubspec of pubspecs) {
        if (await pubspecIncludesBloc(pubspec)) {
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  commands.executeCommand(
    "setContext",
    "bloc.showContextMenu",
    pubspec
      ? await pubspecIncludesBloc(pubspec)
      : await workspaceIncludesBloc(),
  );
}
