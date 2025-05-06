import { exec } from "./exec";
import * as semver from "semver";

export const getDartVersion = async (): Promise<semver.SemVer | null> => {
  try {
    const result = await exec("dart --version");
    // Dart SDK version: 3.7.2 (stable) (Tue Mar 11 04:27:50 2025 -0700) on "macos_arm64"
    const output = result.trim();

    // Parse "major.minor.patch"
    const regexp = new RegExp(/\d+\.\d+\.\d+/);
    const versionString = output.match(regexp)?.[0] ?? null;
    return semver.parse(versionString);
  } catch (_) {
    return null;
  }
};
