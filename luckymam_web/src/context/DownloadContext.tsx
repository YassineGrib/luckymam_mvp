import {
  createContext,
  useCallback,
  useContext,
  useMemo,
  useRef,
  useState,
  type ReactNode,
} from 'react';
import {
  downloadApk,
  formatDownloadSize,
  type DownloadMode,
} from '../lib/downloadApk';

type DownloadStatus = 'idle' | 'downloading' | 'complete' | 'error';

interface DownloadContextValue {
  status: DownloadStatus;
  progress: number;
  loadedBytes: number;
  totalBytes: number;
  mode: DownloadMode | null;
  startDownload: () => void;
}

const DownloadContext = createContext<DownloadContextValue | null>(null);

export function DownloadProvider({ children }: { children: ReactNode }) {
  const [status, setStatus] = useState<DownloadStatus>('idle');
  const [progress, setProgress] = useState(0);
  const [loadedBytes, setLoadedBytes] = useState(0);
  const [totalBytes, setTotalBytes] = useState(0);
  const [mode, setMode] = useState<DownloadMode | null>(null);

  const isDownloadingRef = useRef(false);
  const abortRef = useRef<AbortController | null>(null);
  const resetTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  const resetSoon = useCallback((delayMs: number) => {
    if (resetTimerRef.current) clearTimeout(resetTimerRef.current);
    resetTimerRef.current = setTimeout(() => {
      setStatus('idle');
      setProgress(0);
      setLoadedBytes(0);
      setTotalBytes(0);
      setMode(null);
      isDownloadingRef.current = false;
    }, delayMs);
  }, []);

  const startDownload = useCallback(() => {
    if (isDownloadingRef.current) return;

    abortRef.current?.abort();
    abortRef.current = new AbortController();

    isDownloadingRef.current = true;
    setStatus('downloading');
    setProgress(0);
    setLoadedBytes(0);
    setTotalBytes(0);
    setMode(null);

    void downloadApk(abortRef.current.signal, (update) => {
      setProgress(update.percent);
      setLoadedBytes(update.loaded);
      setTotalBytes(update.total);
      setMode(update.mode);
    })
      .then((resultMode) => {
        setMode(resultMode);
        setProgress(100);
        setStatus('complete');
        resetSoon(resultMode === 'native' ? 2600 : 1800);
      })
      .catch((error: unknown) => {
        if (abortRef.current?.signal.aborted) return;
        console.error('APK download failed:', error);
        setStatus('error');
        resetSoon(4000);
      })
      .finally(() => {
        abortRef.current = null;
      });
  }, [resetSoon]);

  const value = useMemo(
    () => ({
      status,
      progress,
      loadedBytes,
      totalBytes,
      mode,
      startDownload,
    }),
    [loadedBytes, mode, progress, startDownload, status, totalBytes],
  );

  return (
    <DownloadContext.Provider value={value}>
      {children}
      <DownloadProgressOverlay
        status={status}
        progress={progress}
        loadedBytes={loadedBytes}
        totalBytes={totalBytes}
        mode={mode}
        onRetry={startDownload}
      />
    </DownloadContext.Provider>
  );
}

export function useDownload() {
  const context = useContext(DownloadContext);
  if (!context) {
    throw new Error('useDownload must be used within DownloadProvider');
  }
  return context;
}

function DownloadProgressOverlay({
  status,
  progress,
  loadedBytes,
  totalBytes,
  mode,
  onRetry,
}: {
  status: DownloadStatus;
  progress: number;
  loadedBytes: number;
  totalBytes: number;
  mode: DownloadMode | null;
  onRetry: () => void;
}) {
  if (status === 'idle') return null;

  const isComplete = status === 'complete';
  const isError = status === 'error';
  const isNative = mode === 'native';

  const label = isComplete
    ? 'Téléchargement lancé'
    : isError
      ? 'Échec du téléchargement'
      : isNative
        ? 'Ouverture du téléchargement'
        : 'Téléchargement en cours';

  const detail = isComplete
    ? isNative
      ? 'Le navigateur gère maintenant le fichier APK. Vérifiez vos notifications ou votre dossier Téléchargements.'
      : 'Le fichier APK a été enregistré. Ouvrez-le pour installer Luckymam.'
    : isError
      ? 'Impossible de récupérer le fichier APK. Vérifiez votre connexion puis réessayez.'
      : isNative
        ? 'Le fichier est volumineux. Votre navigateur va le télécharger directement, sans passer par la mémoire du site.'
        : totalBytes > 0
          ? `${formatDownloadSize(loadedBytes)} / ${formatDownloadSize(totalBytes)} transférés`
          : 'Préparation du fichier APK...';

  return (
    <div
      className="fixed inset-0 z-[100] flex items-end sm:items-center justify-center p-4 sm:p-6 bg-charcoal-dark/55 backdrop-blur-[2px]"
      role="dialog"
      aria-live="polite"
      aria-label={label}
    >
      <div className="w-full max-w-md bg-clay-bg neo-border neo-shadow-lg p-5 sm:p-6 space-y-4 download-overlay-enter">
        <div className="flex items-center justify-between gap-3">
          <div>
            <p className="font-display font-black text-lg text-charcoal-dark">Luckymam</p>
            <p className="text-sm font-medium text-charcoal-dark/70">{label}</p>
          </div>
          <span className="font-display font-black text-2xl text-coral-primary tabular-nums">
            {isError ? '!' : isNative && !isComplete ? '…' : `${progress}%`}
          </span>
        </div>

        <div className="h-4 neo-border bg-white overflow-hidden">
          <div
            className={`h-full download-progress-fill ${isComplete ? 'download-progress-complete' : ''} ${isError ? 'download-progress-error' : ''} ${isNative && !isComplete ? 'download-progress-native' : ''}`}
            style={{ width: isError ? '100%' : `${progress}%` }}
          />
        </div>

        <p className="text-xs font-medium text-charcoal-dark/60">{detail}</p>

        {isError && (
          <button type="button" onClick={onRetry} className="neo-btn w-full py-3 text-sm bg-coral-primary">
            Réessayer
          </button>
        )}
      </div>
    </div>
  );
}
