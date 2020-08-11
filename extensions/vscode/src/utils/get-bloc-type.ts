import { hasDependency } from "./has-dependency";

const equatable = "equatable";
const freezed_annotation = "freezed_annotation";

export const enum BlocType {
  Simple,
  Equatable,
  Freezed,
}

export async function getBlocType() {
  if (await hasDependency(equatable)) {
    return BlocType.Equatable;
  } else if (await hasDependency(freezed_annotation)) {
    return BlocType.Freezed;
  } else {
    return BlocType.Simple;
  }
}
