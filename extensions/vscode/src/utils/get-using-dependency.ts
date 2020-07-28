import { hasDependency } from "./has-dependency";
import { Dependency } from "../consts/dependency_enum";

const equatable = "equatable";
const freezed = "freezed";
const freezed_annotation = "freezed_annotation";

export async function getUsingDependency() {
  if (await hasDependency(equaltable)) {
    return Dependency.Equatable;
  } else if (
    (await hasDependency(freezed)) ||
    (await hasDependency(freezed_annotation))
  ) {
    return Dependency.Freezed;
  } else {
    return Dependency.None;
  }
}
