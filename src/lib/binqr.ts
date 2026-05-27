import SparkMD5 from 'spark-md5';

export const CHUNK_SIZE = 1700;

export interface BinQRMetadata {
  appName: string;
  fileName: string;
  fileExtension: string;
  fileSize: number;
  totalChunks: number;
}

export function binqrMetadataToQRString(metadata: BinQRMetadata): string {
  return JSON.stringify({
    app: metadata.appName,
    name: metadata.fileName,
    ext: metadata.fileExtension,
    size: metadata.fileSize,
    total: metadata.totalChunks,
    type: 'meta',
  });
}

export function parseBinQRMetadata(raw: string): BinQRMetadata | null {
  try {
    const parsed = JSON.parse(raw) as Record<string, unknown>;
    if (parsed.type !== 'meta') return null;
    return {
      appName: String(parsed.app ?? ''),
      fileName: String(parsed.name ?? ''),
      fileExtension: String(parsed.ext ?? ''),
      fileSize: Number(parsed.size ?? 0),
      totalChunks: Number(parsed.total ?? 0),
    };
  } catch {
    return null;
  }
}

export function isBinQRMetadata(raw: string): boolean {
  return parseBinQRMetadata(raw) !== null;
}

export interface BinQREncodeResult {
  qrStrings: string[];
  metadata: BinQRMetadata;
}

export async function encodeFileToQRStrings(file: File): Promise<BinQREncodeResult> {
  const buffer = await file.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  const { baseName, extension } = splitFileName(file.name);
  const totalChunks = Math.ceil(bytes.length / CHUNK_SIZE);

  const metadata: BinQRMetadata = {
    appName: 'binqr',
    fileName: baseName,
    fileExtension: extension,
    fileSize: bytes.length,
    totalChunks,
  };

  const qrStrings: string[] = [binqrMetadataToQRString(metadata)];

  for (let index = 0; index < totalChunks; index += 1) {
    const start = index * CHUNK_SIZE;
    const end = Math.min(start + CHUNK_SIZE, bytes.length);
    const slice = bytes.subarray(start, end);
    const sliceBuffer = slice.buffer.slice(slice.byteOffset, slice.byteOffset + slice.byteLength);
    const checksum = SparkMD5.ArrayBuffer.hash(sliceBuffer);
    const data = arrayBufferToBase64(sliceBuffer);

    qrStrings.push(`${index}|${totalChunks}|${checksum}|${data}`);
  }

  return { qrStrings, metadata };
}

function splitFileName(fileName: string): { baseName: string; extension: string } {
  const lastDot = fileName.lastIndexOf('.');
  if (lastDot <= 0) {
    return { baseName: fileName, extension: '' };
  }

  return {
    baseName: fileName.slice(0, lastDot),
    extension: fileName.slice(lastDot),
  };
}

function arrayBufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  const chunkSize = 0x8000;

  for (let i = 0; i < bytes.length; i += chunkSize) {
    const chunk = bytes.subarray(i, i + chunkSize);
    binary += String.fromCharCode(...chunk);
  }

  return btoa(binary);
}
