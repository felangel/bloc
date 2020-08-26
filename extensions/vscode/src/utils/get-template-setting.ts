import { workspace } from "vscode";

export const enum TemplateSetting {
  Auto,
  Equatable,
  Freezed,
  Simple,
}

export const enum TemplateType {
  Bloc,
  Cubit,
}

export function getTemplateSetting(type: TemplateType): TemplateSetting {
  let config: string | undefined;
  switch (type) {
    case TemplateType.Bloc:
      config = workspace.getConfiguration("bloc").get("newBlocTemplate");
      break;
    case TemplateType.Cubit:
      config = workspace.getConfiguration("bloc").get("newCubitTemplate");
      break;
    default:
      return TemplateSetting.Auto;
  }

  switch (config) {
    case "freezed":
      return TemplateSetting.Freezed;
    case "equatable":
      return TemplateSetting.Equatable;
    case "simple":
      return TemplateSetting.Simple;
    case "auto":
    default:
      return TemplateSetting.Auto;
  }
}
