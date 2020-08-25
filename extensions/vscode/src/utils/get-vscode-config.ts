import { workspace } from "vscode";
export const enum TemplateSetting {
  Default,
  Reverse,
  Equatable,
  Freezed,
  Simple,
}

export const enum Config {
  Bloc,
  Cubit,
}

export function getConfigedTemplate(which: Config): TemplateSetting {
  let config: string | undefined;
  switch (which) {
    case Config.Bloc:
      config = workspace.getConfiguration("bloc").get("blocTemplateGeneration");
      break;
    case Config.Cubit:
      config = workspace
        .getConfiguration("bloc")
        .get("cubitTemplateGeneration");
      break;
    default:
      return TemplateSetting.Default;
  }

  switch (config) {
    case "default":
      return TemplateSetting.Default;
    case "reverse":
      return TemplateSetting.Reverse;
    case "equatable":
      return TemplateSetting.Equatable;
    case "freezed":
      return TemplateSetting.Freezed;
    case "simple":
      return TemplateSetting.Simple;
    default:
      return TemplateSetting.Default;
  }
}
