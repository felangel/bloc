import { exec, isDartInstalled } from ".";

export const installBlocTools = async (): Promise<boolean> => {
  const blocToolsVersion = "0.1.0-dev.9";
  const canInstall = await isDartInstalled();
  if (!canInstall) return false;
  try {
    await exec(`dart pub global activate bloc_tools ${blocToolsVersion}`);
    return true;
  } catch (_) {
    return false;
  }
};
