import { useEffect, useMemo, useRef, useState } from 'react';
import { Link } from 'react-router';
import QRCode from 'qrcode';
import { ListOrdered, Play, RotateCcw, StopCircle, Upload, X } from 'lucide-react';
import { type BinQRMetadata, encodeFileToQRStrings } from '../lib/binqr';

const FPS = 8;

export function SendPage() {
  const [file, setFile] = useState<File | null>(null);
  const [qrStrings, setQrStrings] = useState<string[] | null>(null);
  const [metadata, setMetadata] = useState<BinQRMetadata | null>(null);
  const [sending, setSending] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [qrDataUrl, setQrDataUrl] = useState('');
  const [showChunkSheet, setShowChunkSheet] = useState(false);
  const [showSendAgain, setShowSendAgain] = useState(false);
  const [chunkInput, setChunkInput] = useState('');

  const fileInputRef = useRef<HTMLInputElement | null>(null);
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null);
  const holdTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const sequenceTokenRef = useRef(0);
  const sendingRef = useRef(false);

  useEffect(() => {
    sendingRef.current = sending;
  }, [sending]);

  useEffect(() => {
    return () => {
      clearLoopTimers(intervalRef, holdTimeoutRef);
    };
  }, []);

  const currentQRData = useMemo(() => {
    if (!qrStrings || qrStrings.length === 0) return '';
    const safeIndex = clamp(currentIndex, 0, qrStrings.length - 1);
    return qrStrings[safeIndex] ?? '';
  }, [currentIndex, qrStrings]);

  useEffect(() => {
    if (!currentQRData) {
      setQrDataUrl('');
      return;
    }

    let isActive = true;
    const options = {
      margin: 1,
      width: sending ? 720 : 480,
      color: {
        dark: '#000000',
        light: '#FFFFFF',
      },
    };

    QRCode.toDataURL(currentQRData, options)
      .then((url) => {
        if (isActive) setQrDataUrl(url);
      })
      .catch(() => {
        if (isActive) setQrDataUrl('');
      });

    return () => {
      isActive = false;
    };
  }, [currentQRData, sending]);

  const onPickFile = () => {
    fileInputRef.current?.click();
  };

  const onFileChange = async (event: React.ChangeEvent<HTMLInputElement>) => {
    const picked = event.target.files?.[0] ?? null;
    if (!picked) return;

    const result = await encodeFileToQRStrings(picked);

    clearLoopTimers(intervalRef, holdTimeoutRef);
    setShowChunkSheet(false);
    setShowSendAgain(false);
    setChunkInput('');
    setFile(picked);
    setQrStrings(result.qrStrings);
    setMetadata(result.metadata);
    setCurrentIndex(0);
    setSending(false);
  };

  const startSending = () => {
    if (!qrStrings || !metadata || metadata.totalChunks === 0) return;
    clearLoopTimers(intervalRef, holdTimeoutRef);
    setShowSendAgain(false);
    setSending(true);
    setCurrentIndex(1);
    startLoop();
  };

  const stopSending = () => {
    clearLoopTimers(intervalRef, holdTimeoutRef);
    sequenceTokenRef.current += 1;
    setSending(false);
    setCurrentIndex(0);
    setShowSendAgain(true);
  };

  const startLoop = () => {
    clearLoopTimers(intervalRef, holdTimeoutRef);
    intervalRef.current = setInterval(() => {
      setCurrentIndex((prev) => {
        if (!qrStrings) return prev;
        const next = prev + 1;
        if (next >= qrStrings.length) return 1;
        return next;
      });
    }, Math.round(1000 / FPS));
  };

  const showChunkOnce = (chunkIndex: number) => {
    if (!qrStrings || !metadata) return;
    const total = metadata.totalChunks;
    if (total === 0) return;

    clearLoopTimers(intervalRef, holdTimeoutRef);
    sequenceTokenRef.current += 1;
    const safeIndex = clamp(chunkIndex, 0, total - 1);
    setSending(true);
    setCurrentIndex(safeIndex + 1);

    const token = sequenceTokenRef.current;
    holdTimeoutRef.current = setTimeout(() => {
      if (!sendingRef.current) return;
      if (sequenceTokenRef.current !== token) return;
      startLoop();
    }, 5000);
  };

  const showChunkSequence = async (indices: number[]) => {
    if (!qrStrings || !metadata) return;
    const total = metadata.totalChunks;
    if (total === 0 || indices.length === 0) return;

    clearLoopTimers(intervalRef, holdTimeoutRef);
    const safeIndices = indices.map((index) => clamp(index, 0, total - 1));
    const token = ++sequenceTokenRef.current;

    for (const index of safeIndices) {
      if (sequenceTokenRef.current !== token) return;
      setSending(true);
      setCurrentIndex(index + 1);
      await delay(2000);
    }

    if (sequenceTokenRef.current !== token) return;
    const lastIndex = safeIndices[safeIndices.length - 1] ?? 0;
    const nextIndex = lastIndex + 1 >= total ? 0 : lastIndex + 1;
    setSending(true);
    setCurrentIndex(nextIndex + 1);
    startLoop();
  };

  const parseChunkSequence = (value: string): number[] | null => {
    const total = metadata?.totalChunks ?? 0;
    if (!total) return null;
    const parts = value.split(',');
    if (parts.length === 0) return null;
    const indices: number[] = [];

    for (const rawPart of parts) {
      const part = rawPart.trim();
      if (!part) return null;
      if (part.includes('-')) {
        const rangeParts = part.split('-');
        if (rangeParts.length !== 2) return null;
        const start = Number.parseInt(rangeParts[0].trim(), 10);
        const end = Number.parseInt(rangeParts[1].trim(), 10);
        if (!Number.isFinite(start) || !Number.isFinite(end)) return null;
        if (start < 1 || end < 1 || start > total || end > total) return null;
        if (start <= end) {
          for (let i = start; i <= end; i += 1) indices.push(i - 1);
        } else {
          for (let i = start; i >= end; i -= 1) indices.push(i - 1);
        }
      } else {
        const number = Number.parseInt(part, 10);
        if (!Number.isFinite(number) || number < 1 || number > total) return null;
        indices.push(number - 1);
      }
    }

    return indices.length ? indices : null;
  };

  const onShowChunk = () => {
    const indices = parseChunkSequence(chunkInput);
    if (!indices) return;
    setShowChunkSheet(false);
    if (indices.length === 1) {
      showChunkOnce(indices[0]);
    } else {
      void showChunkSequence(indices);
    }
  };

  const onCloseChunkSheet = () => {
    setShowChunkSheet(false);
    if (sending) startLoop();
  };

  const isShowingMeta = currentIndex === 0;

  return (
    <div className={`min-h-screen text-foreground ${sending ? 'bg-black' : 'bg-background'}`}>
      <input
        ref={fileInputRef}
        type="file"
        className="hidden"
        onChange={onFileChange}
      />

      {!sending && (
        <nav className="flex items-center justify-between px-6 py-6">
          <Link to="/" className="text-secondary hover:text-white transition-colors">
            Back
          </Link>
          <span className="text-white font-semibold">Send</span>
          <div className="w-10" />
        </nav>
      )}

      <main className="px-6 pb-10">
        {!file ? (
          <div className="min-h-[70vh] flex items-center justify-center">
            <div className="w-full max-w-sm text-center">
              <div className="mx-auto mb-6 flex h-20 w-20 items-center justify-center rounded-3xl bg-card">
                <Upload className="h-9 w-9 text-secondary" strokeWidth={1.6} />
              </div>
              <h1 className="text-2xl font-semibold text-white">Select a file</h1>
              <p className="mt-2 text-secondary">Any file type. We split into 2000-byte chunks.</p>
              <button
                type="button"
                onClick={onPickFile}
                className="mt-8 w-full rounded-full bg-white text-black font-semibold h-12"
              >
                Choose File
              </button>
            </div>
          </div>
        ) : sending ? (
          <div className="min-h-[80vh] flex items-center justify-center">
            <div className="w-full max-w-6xl flex flex-col lg:flex-row items-center justify-center gap-10 lg:gap-16">
              <div className="flex flex-col gap-4">
              <div className="bg-white rounded-2xl p-4">
                {qrDataUrl ? (
                  <img
                    src={qrDataUrl}
                    alt="QR code"
                    className="w-[58vw] max-w-[340px] h-auto"
                  />
                ) : (
                  <div className="w-[58vw] max-w-[340px] aspect-square" />
                )}
              </div>
              <p className="mt-3 text-sm text-white/60 text-center">
                Reduce brightness for faster speed
              </p>
              </div>

              <div className="w-full max-w-sm">
                <SendingProgress
                  currentIndex={currentIndex}
                  total={qrStrings ? qrStrings.length - 1 : 0}
                />
                <div className="mt-6 grid gap-3">
                  <button
                    type="button"
                    onClick={() => setShowChunkSheet(true)}
                    className="h-12 w-full rounded-full border border-border text-white flex items-center justify-center gap-2"
                    disabled={!metadata || metadata.totalChunks === 0}
                  >
                    <ListOrdered className="h-4 w-4" strokeWidth={2} />
                    Select Chunk
                  </button>
                  <button
                    type="button"
                    onClick={stopSending}
                    className="h-12 w-full rounded-full bg-[#FF3B30] text-white font-semibold flex items-center justify-center gap-2"
                  >
                    <StopCircle className="h-4 w-4" strokeWidth={2} />
                    Stop
                  </button>
                </div>
              </div>
            </div>
          </div>
        ) : (
          metadata && (
            <div className="mx-auto max-w-2xl">
              <div className="bg-card rounded-2xl p-6 border border-border">
                <p className="text-secondary text-sm">Ready to Send</p>
                <h1 className="mt-2 text-xl font-semibold text-white truncate">
                  {metadata.fileName}{metadata.fileExtension}
                </h1>
                <div className="mt-4 flex flex-wrap gap-2">
                  <Chip label={formatSize(metadata.fileSize)} />
                  <Chip label={`${metadata.totalChunks + 1} QR codes`} />
                </div>
              </div>

              <div className="mt-8 text-center">
                <p className="text-secondary text-sm">Metadata QR</p>
                <div className="mt-4 inline-flex rounded-2xl bg-white p-4">
                  {qrDataUrl ? (
                    <img src={qrDataUrl} alt="Metadata QR" className="w-60 h-60" />
                  ) : (
                    <div className="w-60 h-60" />
                  )}
                </div>
                <p className="mt-3 text-secondary text-sm">Point receiver's camera here</p>
              </div>

              <div className="mt-10 grid gap-3">
                <button
                  type="button"
                  onClick={startSending}
                  className="h-12 w-full rounded-full bg-white text-black font-semibold flex items-center justify-center gap-2"
                >
                  <Play className="h-4 w-4" strokeWidth={2} />
                  Start Sending
                </button>
                <button
                  type="button"
                  onClick={onPickFile}
                  className="h-12 w-full rounded-full border border-border text-white"
                >
                  Choose Different File
                </button>
              </div>
            </div>
          )
        )}
      </main>

      {showChunkSheet && metadata && (
        <Modal onClose={onCloseChunkSheet} position="right">
          <div className="flex items-start justify-between">
            <div>
              <h2 className="text-lg font-semibold text-white">Select Chunk</h2>
              <p className="text-secondary text-sm mt-1">
                Enter chunks (1 - {metadata.totalChunks}). Example: 2, 5-7, 10
              </p>
            </div>
            <button
              type="button"
              onClick={onCloseChunkSheet}
              className="text-secondary hover:text-white"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
          <div className="mt-4 flex gap-3">
            <input
              type="text"
              value={chunkInput}
              onChange={(event) => setChunkInput(event.target.value)}
              placeholder="e.g. 3 or 1,4-6,9"
              className="flex-1 rounded-xl border border-border bg-input-background px-4 py-3 text-sm text-white placeholder:text-secondary focus:outline-none"
            />
            <button
              type="button"
              onClick={onShowChunk}
              className="h-11 rounded-xl bg-white px-5 text-black font-semibold"
            >
              Show
            </button>
          </div>
        </Modal>
      )}

      {showSendAgain && (
        <Modal onClose={() => setShowSendAgain(false)}>
          <div className="text-center">
            <div className="mx-auto mb-4 flex h-12 w-12 items-center justify-center rounded-full bg-[#34C759]/20 text-[#34C759]">
              <RotateCcw className="h-5 w-5" />
            </div>
            <h2 className="text-lg font-semibold text-white">Transmission complete</h2>
            <p className="mt-2 text-secondary text-sm">Did the receiver get all chunks?</p>
            <div className="mt-6 grid gap-3">
              <button
                type="button"
                onClick={() => {
                  setShowSendAgain(false);
                  startSending();
                }}
                className="h-11 rounded-xl bg-white text-black font-semibold"
              >
                Send Again
              </button>
              <button
                type="button"
                onClick={() => setShowSendAgain(false)}
                className="h-11 rounded-xl border border-border text-white"
              >
                Done
              </button>
            </div>
          </div>
        </Modal>
      )}
    </div>
  );
}

function SendingProgress({ currentIndex, total }: { currentIndex: number; total: number }) {
  const chunkIndex = clamp(currentIndex - 1, 0, total);
  const progress = total === 0 ? 0 : chunkIndex / total;

  return (
    <div>
      <div className="flex items-center justify-between text-xs text-white/60">
        <span>QR {chunkIndex + 1} / {total}</span>
        <span>{Math.round(progress * 100)}%</span>
      </div>
      <div className="mt-2 h-1.5 rounded-full bg-white/10 overflow-hidden">
        <div className="h-full bg-white" style={{ width: `${Math.round(progress * 100)}%` }} />
      </div>
    </div>
  );
}

function Chip({ label }: { label: string }) {
  return (
    <span className="rounded-full bg-background px-3 py-1 text-xs text-secondary">
      {label}
    </span>
  );
}

function Modal({
  children,
  onClose,
  position = 'bottom',
}: {
  children: React.ReactNode;
  onClose: () => void;
  position?: 'bottom' | 'right';
}) {
  const isRight = position === 'right';
  return (
    <div className={`fixed inset-0 z-50 flex ${isRight ? 'items-stretch justify-end' : 'items-end justify-center'}`}>
      <button
        type="button"
        className="absolute inset-0 bg-black/60"
        onClick={onClose}
        aria-label="Close"
      />
      <div
        className={`relative bg-card p-6 border border-border ${isRight
          ? 'h-full w-[90vw] max-w-sm rounded-l-3xl'
          : 'w-full max-w-lg rounded-t-3xl'
          }`}
      >
        {children}
      </div>
    </div>
  );
}

function clearLoopTimers(
  intervalRef?: React.MutableRefObject<ReturnType<typeof setInterval> | null>,
  holdTimeoutRef?: React.MutableRefObject<ReturnType<typeof setTimeout> | null>,
) {
  if (intervalRef?.current) {
    clearInterval(intervalRef.current);
    intervalRef.current = null;
  }
  if (holdTimeoutRef?.current) {
    clearTimeout(holdTimeoutRef.current);
    holdTimeoutRef.current = null;
  }
}

function delay(ms: number) {
  return new Promise<void>((resolve) => {
    setTimeout(resolve, ms);
  });
}

function clamp(value: number, min: number, max: number) {
  return Math.min(Math.max(value, min), max);
}

function formatSize(bytes: number) {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
}
