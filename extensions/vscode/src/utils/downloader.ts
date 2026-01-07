import axios, { AxiosRequestConfig } from "axios";
import * as fs from "fs";
import * as path from "path";
import * as rimraf from "rimraf";
import { pipeline, Readable } from "stream";
import { promisify } from "util";
import { v4 as uuid } from "uuid";
import { ExtensionContext, Uri } from "vscode";
import { retry } from "./retry";

const DEFAULT_TIMEOUT_MS = 5000;
const DEFAULT_RETRY_COUNT = 5;
const DEFAULT_RETRY_DELAY_MS = 100;

const pipelineAsync = promisify(pipeline);
const rmAsync = promisify(rimraf);

export async function downloadFile(
  url: Uri,
  filename: string,
  context: ExtensionContext,
): Promise<Uri> {
  if (url.scheme !== `http` && url.scheme !== `https`) {
    throw new Error(
      `Unsupported URI scheme in url. Supported schemes are http and https.`,
    );
  }

  const downloadsStoragePath: string = downloadsPath(context);
  const tempFileDownloadPath: string = path.join(downloadsStoragePath, uuid());
  const fileDownloadPath: string = path.join(downloadsStoragePath, filename);
  await fs.promises.mkdir(downloadsStoragePath, { recursive: true });

  let progress = 0;
  let progressTimerId: any;
  try {
    progressTimerId = setInterval(() => {
      if (progress > 100) clearInterval(progressTimerId);
    }, 1500);

    const downloadStream: Readable = await get(
      url.toString(),
      DEFAULT_TIMEOUT_MS,
      DEFAULT_RETRY_COUNT,
      DEFAULT_RETRY_DELAY_MS,
    );

    const writeStream = fs.createWriteStream(tempFileDownloadPath);
    await Promise.all([
      pipelineAsync([downloadStream, writeStream]),
      new Promise((resolve) => writeStream.on(`close`, resolve)),
    ]);
  } catch (error) {
    if (progressTimerId != null) clearInterval(progressTimerId);
    throw error;
  }

  await fs.promises.chmod(tempFileDownloadPath, 0o744); // make executable

  await rmAsync(fileDownloadPath);

  const renameDownloadedFile = async (): Promise<Uri> => {
    await fs.promises.rename(tempFileDownloadPath, fileDownloadPath);
    return Uri.file(fileDownloadPath);
  };

  return retry(
    renameDownloadedFile,
    renameDownloadedFile.name,
    DEFAULT_RETRY_COUNT,
    DEFAULT_RETRY_DELAY_MS,
  );
}

export async function tryGetDownload(
  filename: string,
  context: ExtensionContext,
): Promise<Uri | undefined> {
  try {
    return await getDownload(filename, context);
  } catch {
    return undefined;
  }
}

function downloadsPath(context: ExtensionContext): string {
  return path.join(context.globalStorageUri.fsPath, `downloads`);
}

async function listDownloads(context: ExtensionContext): Promise<Uri[]> {
  const downloadsStoragePath = downloadsPath(context);
  try {
    const filePaths: string[] = await fs.promises.readdir(downloadsStoragePath);
    return filePaths.map((filePath) =>
      Uri.file(path.join(downloadsStoragePath, filePath)),
    );
  } catch (error) {
    return [];
  }
}

async function getDownload(
  filename: string,
  context: ExtensionContext,
): Promise<Uri> {
  const filePaths = await listDownloads(context);
  const matchingUris = filePaths.filter(
    (uri) => uri.path.split(`/`).pop() === filename.replace(`/`, ``),
  );
  switch (matchingUris.length) {
    case 1:
      return matchingUris[0];
    case 0:
      throw new Error(
        `Download not found: ${path.join(downloadsPath(context), filename)}`,
      );
    default:
      throw new Error(
        `Multiple downloads found: ${filePaths.map((uri) => uri.toString())}`,
      );
  }
}

async function get(
  url: string,
  timeoutInMs: number,
  retries: number,
  retryDelayInMs: number,
): Promise<Readable> {
  const body = () => getAsStream(url, timeoutInMs);
  const onError = (error: Error) => {
    const statusCode = (error as any)?.response?.status;
    if (statusCode != null && 400 <= statusCode && statusCode < 500) {
      throw error;
    }
  };
  return retry(body, "getAsStream", retries, retryDelayInMs, onError);
}

async function getAsStream(
  url: string,
  timeoutInMs: number,
): Promise<Readable> {
  const options: AxiosRequestConfig = {
    timeout: timeoutInMs,
    responseType: `stream`,
    proxy: false, // Disabling axios proxy in order to use VSCode proxy settings.
  };
  const response = await axios.get(url, options);
  if (response === undefined) {
    throw new Error(
      `Undefined response received when downloading from '${url}'`,
    );
  }
  return response.data;
}
