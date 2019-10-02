import * as fs from "fs";
import * as yaml from "js-yaml";
import { getPubspecPath } from "./get-pubspec-path";

export function getPubspec(): Record<string, any> | undefined {
  const pubspecPath = getPubspecPath();
  if (pubspecPath) {
    try {
      return yaml.safeLoad(fs.readFileSync(pubspecPath, "utf8"));
    } catch (_) {}
  }
}
