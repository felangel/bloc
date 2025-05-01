import { exec } from "./exec";

export const getBlocToolsVersion = async (): Promise<string | null> => {
  try {
    const result = await exec("bloc --version");
    return result.trim();
  } catch (_) {
    return null;
  }
};
