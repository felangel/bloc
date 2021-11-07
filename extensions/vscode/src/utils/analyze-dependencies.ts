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
  const openBlocMigrationGuide = {
    name: "Open Migration Guide",
    callback: () => {
      env.openExternal(Uri.parse("https://bloclibrary.dev/#/migration"));
    },
  };
  const dependenciesToAnalyze = [
    {
      name: "equatable",
      version: "^2.0.3",
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
      version: "^7.2.1",
      actions: [openBlocMigrationGuide],
    },

    {
      name: "flutter_bloc",
      version: "^7.3.3",
      actions: [openBlocMigrationGuide],
    },
    {
      name: "angular_bloc",
      version: "^7.1.0",
      actions: [openBlocMigrationGuide],
    },
    {
      name: "hydrated_bloc",
      version: "^7.1.0",
      actions: [openBlocMigrationGuide],
    },
    {
      name: "sealed_flutter_bloc",
      version: "^7.1.0",
      actions: [openBlocMigrationGuide],
    },
    {
      name: "replay_bloc",
      version: "^0.1.0",
      actions: [openBlocMigrationGuide],
    },
    {
      name: "bloc_concurrency",
      version: "^0.1.0",
      actions: [],
    },
  ];

  const devDependenciesToAnalyze = [
    {
      name: "bloc_test",
      version: "^8.5.0",
      actions: [openBlocMigrationGuide],
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
        window
          .showWarningMessage(
            `This workspace contains an outdated version of ${dependency.name}. Please update to ${dependency.version}.`,
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
