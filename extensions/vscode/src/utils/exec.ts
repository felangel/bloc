import * as cp from "child_process";

export interface ExecOptions {
  cwd?: string | undefined;
}

export const exec = (cmd: string, options?: ExecOptions) =>
  new Promise<string>((resolve, reject) => {
    cp.exec(cmd, { cwd: options?.cwd }, (err, output) => {
      if (err) {
        return reject(err);
      }
      return resolve(output);
    });
  });
