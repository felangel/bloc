import { exec } from "./exec";

export const isDartInstalled = async (): Promise<boolean> => {
  try {
    await exec("dart");
    return true;
  } catch (_) {
    return false;
  }
};
