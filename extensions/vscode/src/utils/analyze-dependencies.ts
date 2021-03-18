import * as _ from "lodash";

import * as semver from "semver";
import { window, env, Uri } from "vscode";
import { getPubspec } from ".";
import { updatePubspecDependency } from "./update-pubspec-dependency";

interface Dependency {
  name: string;
  version: string;
  actions: Action[];
}

interface Action {
  name: string;
  callback: Function;
}

export async function analyzeDependencies() {
  const dependenciesToAnalyze = [
    {
      name: "equatable",
      version: "^2.0.0",
      actions: [
        {
          name: "Open Migration Guide",
          callback: () => {
            env.openExternal(
              Uri.parse(
                "https://github.com/felangel/equatable/blob/master/doc/migration_guides/migration-0.6.0.md"
              )
            );
          },
        },
      ],
    },
    {
      name: "bloc",
      version: "^7.0.0",
      actions: [
        {
          name: "Open Migration Guide",
          callback: () => {
            env.openExternal(Uri.parse("https://bloclibrary.dev/#/migration"));
          },
        },
      ],
    },

    {
      name: "flutter_bloc",
      version: "^7.0.0",
      actions: [
        {
          name: "Open Migration Guide",
          callback: () => {
            env.openExternal(Uri.parse("https://bloclibrary.dev/#/migration"));
          },
        },
      ],
    },
    { name: "angular_bloc", version: "^6.0.1", actions: [] },
    {
      name: "hydrated_bloc",
      version: "^7.0.0",
      actions: [
        {
          name: "Open Migration Guide",
          callback: () => {
            env.openExternal(Uri.parse("https://bloclibrary.dev/#/migration"));
          },
        },
      ],
    },
    { name: "sealed_flutter_bloc", version: "^6.0.0", actions: [] },
  ];

  const devDependenciesToAnalyze = [
    {
      name: "bloc_test",
      version: "^8.0.0",
      actions: [
        {
          name: "Open Migration Guide",
          callback: () => {
            env.openExternal(Uri.parse("https://bloclibrary.dev/#/migration"));
          },
        },
      ],
    },
  ];

  const pubspec = await getPubspec();
  const dependencies = _.get(pubspec, "dependencies", {});
  const devDependencies = _.get(pubspec, "dev_dependencies", {});

  checkForUpgrades(dependenciesToAnalyze, dependencies);
  checkForUpgrades(devDependenciesToAnalyze, devDependencies);
}

function checkForUpgrades(
  dependenciesToAnalyze: Dependency[],
  dependencies: object[]
) {
  for (let i = 0; i < dependenciesToAnalyze.length; i++) {
    const dependency = dependenciesToAnalyze[i];
    if (_.has(dependencies, dependency.name)) {
      const dependencyVersion = _.get(dependencies, dependency.name, "latest");
      if (dependencyVersion === "latest") continue;
      if (dependencyVersion === "any") continue;
      if (dependencyVersion == null) continue;
      if (typeof dependencyVersion !== "string") continue;
      const minVersion = _.get(
        semver.minVersion(dependencyVersion),
        "version",
        "0.0.0"
      );
      if (!semver.satisfies(minVersion, dependency.version)) {
        console.log(minVersion)
        console.log(dependency.version)
        window
          .showWarningMessage(
            `This workspace contains an unsupported version of ${dependency.name}. Please update to ${dependency.version}.`,
            ...dependency.actions.map((action) => action.name).concat("Update")
          )
          .then((invokedAction) => {
            if (invokedAction === "Update") {
              return updatePubspecDependency({
                name: dependency.name,
                latestVersion: dependency.version,
                currentVersion: dependencyVersion,
              });
            }
            const action = dependency.actions.find(
              (action) => action.name === invokedAction
            );
            if (!_.isNil(action)) {
              action.callback();
            }
          });
      }
    }
  }
}
