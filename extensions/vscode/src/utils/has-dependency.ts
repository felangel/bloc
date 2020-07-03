import * as _ from "lodash";

import { getPubspec } from ".";

export function hasDependency(dependency: string) {
  const dependencies = _.get(getPubspec(), "dependencies", {});
  return _.has(dependencies, dependency);
}
