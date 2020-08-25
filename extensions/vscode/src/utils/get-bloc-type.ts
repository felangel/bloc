import { hasDependency } from "./has-dependency";
import {
  SettingType,
  getConfigedTemplate,
  TemplateSetting,
} from "./get-vscode-config";

const equatable = "equatable";
const freezed_annotation = "freezed_annotation";

export const enum BlocType {
  Simple,
  Equatable,
  Freezed,
}

export async function getTemplateType(which: SettingType) {
  const setting = getConfigedTemplate(which);
  switch (setting) {
    case TemplateSetting.Default:
      return getDefaultDependency();
    case TemplateSetting.Reverse:
      return getReverseDependency();
    case TemplateSetting.Equatable:
      return BlocType.Equatable;
    case TemplateSetting.Freezed:
      return BlocType.Freezed;
    case TemplateSetting.Simple:
      return BlocType.Simple;
    default:
      return getDefaultDependency();
  }
}

async function getDefaultDependency() {
  if (await hasDependency(equatable)) {
    return BlocType.Equatable;
  } else if (await hasDependency(freezed_annotation)) {
    return BlocType.Freezed;
  } else {
    return BlocType.Simple;
  }
}

async function getReverseDependency() {
  if (await hasDependency(freezed_annotation)) {
    return BlocType.Freezed;
  } else if (await hasDependency(equatable)) {
    return BlocType.Equatable;
  } else {
    return BlocType.Simple;
  }
}
