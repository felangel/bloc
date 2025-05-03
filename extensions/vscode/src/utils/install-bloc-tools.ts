import { exec, isDartInstalled } from ".";

export const blocToolsVersion = "0.1.0-dev.11";
export const installBlocTools = async (): Promise<boolean> => {
  const canInstall = await isDartInstalled();
  if (!canInstall) return false;
  try {
    await exec(`dart pub global activate bloc_tools ${blocToolsVersion}`);
    return true;
  } catch (_) {
    return false;
  }
};
