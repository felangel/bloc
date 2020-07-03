import * as _ from "lodash";

import { commands, ExtensionContext } from "vscode";
import { analyzeDependencies } from "./utils";
import { newBloc, newCubit } from "./commands";

export function activate(_context: ExtensionContext) {
  analyzeDependencies();
  commands.registerCommand("extension.new-bloc", newBloc);
  commands.registerCommand("extension.new-cubit", newCubit);
}
