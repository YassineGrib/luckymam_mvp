import { type MouseEvent, type ReactNode, useEffect, useState } from 'react';
import { useDownload } from '../context/DownloadContext';

interface DownloadLinkProps {
  children: ReactNode;
  className?: string;
  onClick?: () => void;
}

export function DownloadLink({ children, className = '', onClick }: DownloadLinkProps) {
  const { status, progress, startDownload } = useDownload();
  const [isActive, setIsActive] = useState(false);
  const isDownloading = status === 'downloading';

  useEffect(() => {
    if (status === 'idle') {
      setIsActive(false);
    }
  }, [status]);

  const handleClick = (event: MouseEvent<HTMLButtonElement>) => {
    event.preventDefault();
    if (isDownloading) return;
    setIsActive(true);
    startDownload();
    onClick?.();
  };

  return (
    <button
      type="button"
      onClick={handleClick}
      disabled={isDownloading}
      className={`relative overflow-hidden ${className} ${isDownloading ? 'opacity-95 cursor-wait' : ''}`}
      aria-busy={isDownloading && isActive}
    >
      {isActive && isDownloading && (
        <span
          className="absolute inset-y-0 left-0 download-button-fill pointer-events-none"
          style={{ width: `${progress}%` }}
          aria-hidden="true"
        />
      )}
      <span className="relative z-[1] inline-flex items-center justify-center w-full">
        {children}
      </span>
    </button>
  );
}
