import { hasDependency } from "./has-dependency";
import {
  TemplateType,
  getTemplateSetting,
  TemplateSetting,
} from "./get-template-setting";

const equatable = "equatable";
const freezed_annotation = "freezed_annotation";

export const enum BlocType {
  Simple,
  Equatable,
  Freezed,
}

export async function getBlocType(type: TemplateType): Promise<BlocType> {
  const setting = getTemplateSetting(type);
  switch (setting) {
    case TemplateSetting.Freezed:
      return BlocType.Freezed;
    case TemplateSetting.Equatable:
      return BlocType.Equatable;
    case TemplateSetting.Simple:
      return BlocType.Simple;
    case TemplateSetting.Auto:
    default:
      return getDefaultDependency();
  }
}

async function getDefaultDependency(): Promise<BlocType> {
  if (await hasDependency(freezed_annotation)) {
    return BlocType.Freezed;
  } else if (await hasDependency(equatable)) {
    return BlocType.Equatable;
  } else {
    return BlocType.Simple;
  }
}
