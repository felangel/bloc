import * as _ from "lodash";
import fetch from "node-fetch";

export async function getLatestPackageVersion(name: string): Promise<string> {
  try {
    const url = `https://pub.dev/api/packages/${name}`;
    const response = await fetch(url);
    const body = await response.json();
    return _.get(body, "latest.version", "");
  } catch (_) {
    return "";
  }
}
