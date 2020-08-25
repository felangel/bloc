import { workspace } from "vscode";
export const enum TemplateSetting {
  Default,
  Reverse,
  Equatable,
  Freezed,
  Simple,
}

export const enum SettingType {
  Bloc,
  Cubit,
}

export function getConfigedTemplate(which: SettingType): TemplateSetting {
  let config: string | undefined;
  switch (which) {
    case SettingType.Bloc:
      config = workspace.getConfiguration("bloc").get("blocTemplateGeneration");
      break;
    case SettingType.Cubit:
      config = workspace
        .getConfiguration("bloc")
        .get("cubitTemplateGeneration");
      console.log(config);
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
