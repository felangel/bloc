export async function retry<T>(
  callback: () => Promise<T>,
  label: string,
  retryCount: number,
  delay: number,
  onError?: (error: Error) => void
): Promise<T> {
  try {
    return await callback();
  } catch (error) {
    if (error instanceof Error) {
      if (retryCount === 0)
        throw new Error(
          `Maximum retry count exceeded.'${label}' failed with error: ${
            error.message
          }. ${JSON.stringify(error)}`
        );
      if (onError != null) onError(error);
    }
    await new Promise((resolve): void => {
      setTimeout(resolve, delay);
    });
    return retry(callback, label, retryCount - 1, delay * 2, onError);
  }
}
