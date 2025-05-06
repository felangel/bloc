import { exec, isDartInstalled } from ".";

export const BLOC_TOOLS_VERSION = "0.1.0-dev.11";
export const installBlocTools = async (): Promise<boolean> => {
  const canInstall = await isDartInstalled();
  if (!canInstall) return false;
  try {
    await exec(`dart pub global activate bloc_tools ${BLOC_TOOLS_VERSION}`);
    return true;
  } catch (_) {
    return false;
  }
};
