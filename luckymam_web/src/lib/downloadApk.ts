import { APK_DOWNLOAD_URL, APK_FILE_NAME } from '../constants/download';

export type DownloadMode = 'stream' | 'native';

export interface DownloadProgressUpdate {
  percent: number;
  loaded: number;
  total: number;
  mode: DownloadMode;
}

function triggerNativeDownload() {
  const anchor = document.createElement('a');
  anchor.href = APK_DOWNLOAD_URL;
  anchor.download = APK_FILE_NAME;
  anchor.rel = 'noopener';
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
}

function triggerBlobDownload(blob: Blob) {
  const url = URL.createObjectURL(blob);
  const anchor = document.createElement('a');
  anchor.href = url;
  anchor.download = APK_FILE_NAME;
  document.body.appendChild(anchor);
  anchor.click();
  document.body.removeChild(anchor);
  URL.revokeObjectURL(url);
}

function isMobileDevice() {
  return /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
}

/** Large APK files are unreliable when buffered entirely in JS on mobile browsers. */
function shouldPreferNativeDownload(totalBytes: number) {
  return isMobileDevice() || totalBytes > 80 * 1024 * 1024;
}

async function fetchApkSize(signal: AbortSignal): Promise<number | null> {
  try {
    const headResponse = await fetch(APK_DOWNLOAD_URL, { method: 'HEAD', signal, cache: 'no-store' });
    if (!headResponse.ok) return null;

    const contentLength = Number(headResponse.headers.get('Content-Length') || 0);
    if (!Number.isFinite(contentLength) || contentLength <= 0) return null;

    return contentLength;
  } catch {
    return null;
  }
}

async function downloadViaStream(
  totalBytes: number,
  signal: AbortSignal,
  onProgress: (update: DownloadProgressUpdate) => void,
) {
  const response = await fetch(APK_DOWNLOAD_URL, { signal, cache: 'no-store' });
  if (!response.ok || !response.body) {
    throw new Error(`Échec du téléchargement (${response.status})`);
  }

  const reader = response.body.getReader();
  const chunks: BlobPart[] = [];
  let loaded = 0;

  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    if (!value) continue;

    chunks.push(value);
    loaded += value.byteLength;

    onProgress({
      percent: Math.min(99, Math.round((loaded / totalBytes) * 100)),
      loaded,
      total: totalBytes,
      mode: 'stream',
    });
  }

  if (loaded !== totalBytes) {
    throw new Error('Fichier incomplet');
  }

  const blob = new Blob(chunks, { type: 'application/vnd.android.package-archive' });
  triggerBlobDownload(blob);

  onProgress({
    percent: 100,
    loaded: totalBytes,
    total: totalBytes,
    mode: 'stream',
  });
}

export async function downloadApk(
  signal: AbortSignal,
  onProgress: (update: DownloadProgressUpdate) => void,
): Promise<DownloadMode> {
  const totalBytes = await fetchApkSize(signal);

  if (totalBytes !== null) {
    onProgress({ percent: 0, loaded: 0, total: totalBytes, mode: 'stream' });
  }

  if (totalBytes === null || shouldPreferNativeDownload(totalBytes)) {
    triggerNativeDownload();
    onProgress({
      percent: 100,
      loaded: totalBytes ?? 0,
      total: totalBytes ?? 0,
      mode: 'native',
    });
    return 'native';
  }

  try {
    await downloadViaStream(totalBytes, signal, onProgress);
    return 'stream';
  } catch (error) {
    if (signal.aborted) throw error;

    triggerNativeDownload();
    onProgress({ percent: 100, loaded: totalBytes, total: totalBytes, mode: 'native' });
    return 'native';
  }
}

export function formatDownloadSize(bytes: number) {
  if (bytes <= 0) return '0 Mo';
  return `${(bytes / (1024 * 1024)).toFixed(1)} Mo`;
}
