import { exec } from "./exec";

export const areBlocToolsInstalled = async (): Promise<boolean> => {
  try {
    await exec("bloc");
    return true;
  } catch (_) {
    return false;
  }
};
