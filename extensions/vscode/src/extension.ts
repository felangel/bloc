import * as _ from "lodash";

import { commands, ExtensionContext } from "vscode";
import { analyzeDependencies } from "./utils";
import { newBloc, newCubit, newFreezedBloc } from "./commands";

export function activate(_context: ExtensionContext) {
  analyzeDependencies();
  commands.registerCommand("extension.new-bloc", newBloc);
  commands.registerCommand("extension.new-cubit", newCubit);
  commands.registerCommand("extension.new-frezzed-bloc", newFreezedBloc);
}
