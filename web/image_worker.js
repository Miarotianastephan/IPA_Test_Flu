const entryCache = new Map();
const pendingEntries = new Map();
const maxEntryCacheSize = 64;
const svgFallbackWidth = 3;
const svgFallbackHeight = 4;
const imageCacheDbName = 'image_cache_db';
const imageCacheStoreName = 'images';
const imageCacheDbVersion = 2;
const textDecoder = new TextDecoder();
let imageCacheDb = null;
let imageCacheInitPromise = null;

function entryKey(url, encryptionKey) {
  return `${url}::${encryptionKey || ''}`;
}

self.onmessage = async (event) => {
  const message = event.data || [];
  const id = message[0];
  const action = message[1];
  const url = message[2];
  const fileType = message[3];
  const encryptionKey = message[4];
  const targetWidth = message[5];

  try {
    if (!url) {
      throw new Error('Missing image url');
    }

    const entry = await ensureEntry(url, fileType, encryptionKey);

    if (action === 'loadLayout') {
      self.postMessage([
        id,
        true,
        'layout',
        entry.isSvg,
        entry.width,
        entry.height,
        null,
      ]);
      return;
    }

    if (action === 'loadImage') {
      if (entry.isSvg) {
        self.postMessage([
          id,
          true,
          'svg',
          true,
          entry.width,
          entry.height,
          entry.svgText,
        ]);
        return;
      }

      const blob = await buildDisplayBlob(entry, targetWidth);
      self.postMessage([
        id,
        true,
        'raster',
        false,
        entry.width,
        entry.height,
        blob,
      ]);
      return;
    }

    throw new Error(`Unsupported image worker action: ${action}`);
  } catch (error) {
    self.postMessage([
      id,
      false,
      'error',
      false,
      0,
      0,
      error instanceof Error ? error.message : String(error),
    ]);
  }
};

async function ensureEntry(url, fileType, encryptionKey) {
  const cacheKey = entryKey(url, encryptionKey);
  const cached = touchEntry(cacheKey);
  if (cached) {
    return cached;
  }

  const pending = pendingEntries.get(cacheKey);
  if (pending) {
    return pending;
  }

  const promise = loadEntry(url, fileType, encryptionKey);
  pendingEntries.set(cacheKey, promise);

  try {
    const entry = await promise;
    putEntry(cacheKey, entry);
    return entry;
  } finally {
    pendingEntries.delete(cacheKey);
  }
}

function touchEntry(cacheKey) {
  const entry = entryCache.get(cacheKey);
  if (!entry) {
    return null;
  }

  entryCache.delete(cacheKey);
  entryCache.set(cacheKey, entry);
  return entry;
}

function putEntry(cacheKey, entry) {
  entryCache.delete(cacheKey);
  entryCache.set(cacheKey, entry);

  while (entryCache.size > maxEntryCacheSize) {
    const oldestKey = entryCache.keys().next().value;
    entryCache.delete(oldestKey);
  }
}

async function loadEntry(url, fileType, encryptionKey) {
  let decryptedBytes = await getPersistentImageBytes(url, encryptionKey);
  if (!decryptedBytes) {
    const response = await fetch(url, {
      cache: 'force-cache',
      credentials: 'same-origin',
    });

    if (!response.ok) {
      throw new Error(`Failed to load image ${url}: ${response.status}`);
    }

    const rawBytes = new Uint8Array(await response.arrayBuffer());
    decryptedBytes = await decryptBytes(rawBytes, fileType, encryptionKey);
    void putPersistentImageBytes(url, encryptionKey, decryptedBytes);
  }

  const isSvg = isSvgUrl(url) || isSvgBytes(decryptedBytes);

  if (isSvg) {
    const svgText = textDecoder.decode(decryptedBytes);
    const svgSize = parseSvgSize(svgText);
    return {
      blob: new Blob([decryptedBytes], { type: 'image/svg+xml' }),
      height: svgSize.height,
      isSvg: true,
      mimeType: 'image/svg+xml',
      svgText,
      width: svgSize.width,
    };
  }

  const imageSize = extractImageDimensions(decryptedBytes) || {
    width: svgFallbackWidth,
    height: svgFallbackHeight,
  };

  return {
    blob: new Blob([decryptedBytes], {
      type: detectMimeType(decryptedBytes, url),
    }),
    height: imageSize.height,
    isSvg: false,
    mimeType: detectMimeType(decryptedBytes, url),
    svgText: null,
    width: imageSize.width,
  };
}

async function initImageCacheDb() {
  if (imageCacheDb) {
    return imageCacheDb;
  }

  if (imageCacheInitPromise) {
    return imageCacheInitPromise;
  }

  imageCacheInitPromise = new Promise((resolve, reject) => {
    try {
      const indexedDb = self.indexedDB || indexedDB;
      if (!indexedDb) {
        resolve(null);
        return;
      }

      const request = indexedDb.open(imageCacheDbName, imageCacheDbVersion);

      request.onupgradeneeded = () => {
        const db = request.result;
        if (!db.objectStoreNames.contains(imageCacheStoreName)) {
          db.createObjectStore(imageCacheStoreName);
        }
      };

      request.onsuccess = () => {
        imageCacheDb = request.result;
        resolve(imageCacheDb);
      };

      request.onerror = () => {
        reject(new Error('Failed to open IndexedDB in image worker'));
      };
    } catch (error) {
      reject(error);
    }
  });

  try {
    return await imageCacheInitPromise;
  } finally {
    imageCacheInitPromise = null;
  }
}

async function getPersistentImageBytes(url, encryptionKey) {
  try {
    const db = await initImageCacheDb();
    if (!db) {
      return null;
    }

    return await new Promise((resolve) => {
      const transaction = db.transaction(imageCacheStoreName, 'readonly');
      const store = transaction.objectStore(imageCacheStoreName);
      const request = store.get(entryKey(url, encryptionKey));

      request.onsuccess = () => {
        resolve(normalizeCachedBytes(request.result));
      };

      request.onerror = () => {
        resolve(null);
      };
    });
  } catch (_) {
    return null;
  }
}

async function putPersistentImageBytes(url, encryptionKey, bytes) {
  try {
    const db = await initImageCacheDb();
    if (!db) {
      return;
    }

    await new Promise((resolve, reject) => {
      const transaction = db.transaction(imageCacheStoreName, 'readwrite');
      const store = transaction.objectStore(imageCacheStoreName);
      const request = store.put(bytes, entryKey(url, encryptionKey));

      request.onsuccess = () => {
        resolve();
      };

      request.onerror = () => {
        reject(new Error('Failed to store image bytes in IndexedDB'));
      };
    });
  } catch (_) {
    // Ignore write failures and fall back to network on next request.
  }
}

function normalizeCachedBytes(value) {
  if (!value) {
    return null;
  }

  if (value instanceof Uint8Array) {
    return value;
  }

  if (value instanceof ArrayBuffer) {
    return new Uint8Array(value);
  }

  if (ArrayBuffer.isView(value)) {
    return new Uint8Array(
      value.buffer,
      value.byteOffset,
      value.byteLength,
    );
  }

  return null;
}

async function buildDisplayBlob(entry, targetWidth) {
  const safeTargetWidth = normalizeTargetWidth(targetWidth, entry.width);
  if (
    !safeTargetWidth ||
    entry.width <= safeTargetWidth * 1.1 ||
    typeof createImageBitmap !== 'function' ||
    typeof OffscreenCanvas === 'undefined'
  ) {
    return entry.blob;
  }

  const safeTargetHeight = Math.max(
    1,
    Math.round((safeTargetWidth * entry.height) / entry.width),
  );

  try {
    const bitmap = await createImageBitmap(entry.blob, {
      resizeHeight: safeTargetHeight,
      resizeQuality: 'medium',
      resizeWidth: safeTargetWidth,
    });

    const canvas = new OffscreenCanvas(safeTargetWidth, safeTargetHeight);
    const context = canvas.getContext('2d', { alpha: true });
    if (!context) {
      bitmap.close?.();
      return entry.blob;
    }

    context.drawImage(bitmap, 0, 0, safeTargetWidth, safeTargetHeight);
    bitmap.close?.();

    return await canvas.convertToBlob({
      quality: 0.86,
      type: outputMimeType(entry.mimeType),
    });
  } catch (_) {
    return entry.blob;
  }
}

function normalizeTargetWidth(targetWidth, originalWidth) {
  if (
    typeof targetWidth !== 'number' ||
    !Number.isFinite(targetWidth) ||
    targetWidth <= 0
  ) {
    return null;
  }

  if (
    typeof originalWidth !== 'number' ||
    !Number.isFinite(originalWidth) ||
    originalWidth <= 0
  ) {
    return null;
  }

  const rounded = Math.round(targetWidth);
  if (rounded <= 0) {
    return null;
  }
  return Math.min(rounded, originalWidth);
}

function outputMimeType(inputMimeType) {
  if (inputMimeType === 'image/png' || inputMimeType === 'image/webp') {
    return inputMimeType;
  }
  return 'image/jpeg';
}

async function decryptBytes(rawBytes, fileType, encryptionKey) {
  // if (fileType === 'pdf') {
  //   return decryptPdfBytes(rawBytes);
  // }

  if (fileType === 'enc' || fileType === 'pdf') {
    return decryptEncBytes(rawBytes, encryptionKey);
  }

  return rawBytes;
}

async function decryptEncBytes(rawBytes, encryptionKey) {
  if (!encryptionKey) {
    throw new Error('Missing encryption key');
  }

  const subtle = self.crypto && self.crypto.subtle;
  if (!subtle) {
    throw new Error('WebCrypto subtle API is unavailable in image worker');
  }

  if (rawBytes.length <= 16) {
    throw new Error('Encrypted image payload is too small');
  }

  const iv = rawBytes.slice(0, 16);
  const encrypted = rawBytes.slice(16);
  const keyBytes = normalizeKey(base64ToBytes(encryptionKey));
  const cryptoKey = await subtle.importKey(
    'raw',
    keyBytes,
    { name: 'AES-CBC' },
    false,
    ['decrypt'],
  );

  const decryptedBuffer = await subtle.decrypt(
    { name: 'AES-CBC', iv },
    cryptoKey,
    encrypted,
  );

  return new Uint8Array(decryptedBuffer);
}

function decryptPdfBytes(rawBytes) {
  const output = new Uint8Array(rawBytes.length);
  for (let i = 0; i < rawBytes.length; i += 1) {
    output[i] = rawBytes[i] ^ 0xff;
  }
  return output;
}

function base64ToBytes(value) {
  const normalized = value.replace(/-/g, '+').replace(/_/g, '/');
  const padded =
    normalized.length % 4 === 0
      ? normalized
      : normalized + '='.repeat(4 - (normalized.length % 4));
  const binary = atob(padded);
  const bytes = new Uint8Array(binary.length);

  for (let i = 0; i < binary.length; i += 1) {
    bytes[i] = binary.charCodeAt(i);
  }

  return bytes;
}

function normalizeKey(rawKey) {
  if (rawKey.length === 16) {
    return rawKey;
  }

  if (rawKey.length > 16) {
    return rawKey.slice(0, 16);
  }

  const padded = new Uint8Array(16);
  padded.set(rawKey);
  return padded;
}

function isSvgUrl(url) {
  const lower = url.toLowerCase();
  return (
    lower.endsWith('.svg.enc') ||
    lower.endsWith('.svg.pdf') ||
    lower.endsWith('.svg')
  );
}

function isSvgBytes(bytes) {
  if (bytes.length < 5) {
    return false;
  }

  const header = textDecoder.decode(bytes.slice(0, 256)).trimStart();
  return header.startsWith('<svg') || header.startsWith('<?xml');
}

function parseSvgSize(svgText) {
  const viewBoxMatch = /viewBox\s*=\s*['"]\s*[-\d.]+\s+[-\d.]+\s+([-\d.]+)\s+([-\d.]+)\s*['"]/i.exec(
    svgText,
  );
  if (viewBoxMatch) {
    const width = Number.parseFloat(viewBoxMatch[1]);
    const height = Number.parseFloat(viewBoxMatch[2]);
    if (width > 0 && height > 0) {
      return { width, height };
    }
  }

  const widthMatch = /width\s*=\s*['"]\s*([-\d.]+)/i.exec(svgText);
  const heightMatch = /height\s*=\s*['"]\s*([-\d.]+)/i.exec(svgText);
  if (widthMatch && heightMatch) {
    const width = Number.parseFloat(widthMatch[1]);
    const height = Number.parseFloat(heightMatch[1]);
    if (width > 0 && height > 0) {
      return { width, height };
    }
  }

  return { width: svgFallbackWidth, height: svgFallbackHeight };
}

function detectMimeType(bytes, url) {
  if (isPng(bytes)) {
    return 'image/png';
  }
  if (isJpeg(bytes)) {
    return 'image/jpeg';
  }
  if (isGif(bytes)) {
    return 'image/gif';
  }
  if (isWebp(bytes)) {
    return 'image/webp';
  }
  if (isBmp(bytes)) {
    return 'image/bmp';
  }

  const lower = url.toLowerCase();
  if (lower.endsWith('.png.enc') || lower.endsWith('.png')) {
    return 'image/png';
  }
  if (lower.endsWith('.webp.enc') || lower.endsWith('.webp')) {
    return 'image/webp';
  }
  if (lower.endsWith('.gif.enc') || lower.endsWith('.gif')) {
    return 'image/gif';
  }
  return 'image/jpeg';
}

function extractImageDimensions(bytes) {
  return (
    tryReadPngDimensions(bytes) ||
    tryReadJpegDimensions(bytes) ||
    tryReadGifDimensions(bytes) ||
    tryReadWebpDimensions(bytes) ||
    tryReadBmpDimensions(bytes)
  );
}

function isPng(bytes) {
  return (
    bytes.length >= 8 &&
    bytes[0] === 137 &&
    bytes[1] === 80 &&
    bytes[2] === 78 &&
    bytes[3] === 71 &&
    bytes[4] === 13 &&
    bytes[5] === 10 &&
    bytes[6] === 26 &&
    bytes[7] === 10
  );
}

function isJpeg(bytes) {
  return bytes.length >= 2 && bytes[0] === 0xff && bytes[1] === 0xd8;
}

function isGif(bytes) {
  if (bytes.length < 6) {
    return false;
  }
  const header = textDecoder.decode(bytes.slice(0, 6));
  return header === 'GIF87a' || header === 'GIF89a';
}

function isBmp(bytes) {
  return bytes.length >= 2 && bytes[0] === 0x42 && bytes[1] === 0x4d;
}

function isWebp(bytes) {
  return (
    bytes.length >= 12 &&
    textDecoder.decode(bytes.slice(0, 4)) === 'RIFF' &&
    textDecoder.decode(bytes.slice(8, 12)) === 'WEBP'
  );
}

function tryReadPngDimensions(bytes) {
  if (!isPng(bytes) || bytes.length < 24) {
    return null;
  }

  const width = readUint32Be(bytes, 16);
  const height = readUint32Be(bytes, 20);
  if (width <= 0 || height <= 0) {
    return null;
  }

  return { width, height };
}

function tryReadGifDimensions(bytes) {
  if (!isGif(bytes) || bytes.length < 10) {
    return null;
  }

  const width = readUint16Le(bytes, 6);
  const height = readUint16Le(bytes, 8);
  if (width <= 0 || height <= 0) {
    return null;
  }

  return { width, height };
}

function tryReadBmpDimensions(bytes) {
  if (!isBmp(bytes) || bytes.length < 26) {
    return null;
  }

  const width = Math.abs(readInt32Le(bytes, 18));
  const height = Math.abs(readInt32Le(bytes, 22));
  if (width <= 0 || height <= 0) {
    return null;
  }

  return { width, height };
}

function tryReadWebpDimensions(bytes) {
  if (!isWebp(bytes) || bytes.length < 30) {
    return null;
  }

  const chunkType = textDecoder.decode(bytes.slice(12, 16));
  if (chunkType === 'VP8X' && bytes.length >= 30) {
    return {
      width: 1 + readUint24Le(bytes, 24),
      height: 1 + readUint24Le(bytes, 27),
    };
  }

  if (chunkType === 'VP8 ' && bytes.length >= 30) {
    const width = readUint16Le(bytes, 26) & 0x3fff;
    const height = readUint16Le(bytes, 28) & 0x3fff;
    if (width > 0 && height > 0) {
      return { width, height };
    }
  }

  if (chunkType === 'VP8L' && bytes.length >= 25) {
    const b0 = bytes[21];
    const b1 = bytes[22];
    const b2 = bytes[23];
    const b3 = bytes[24];
    const width = 1 + (((b1 & 0x3f) << 8) | b0);
    const height =
      1 + (((b3 & 0x0f) << 10) | (b2 << 2) | ((b1 & 0xc0) >> 6));
    if (width > 0 && height > 0) {
      return { width, height };
    }
  }

  return null;
}

function tryReadJpegDimensions(bytes) {
  if (!isJpeg(bytes) || bytes.length < 4) {
    return null;
  }

  let offset = 2;
  while (offset + 9 < bytes.length) {
    if (bytes[offset] !== 0xff) {
      offset += 1;
      continue;
    }

    const marker = bytes[offset + 1];
    if (marker === 0xd8 || marker === 0xd9) {
      offset += 2;
      continue;
    }

    if (marker === 0x01 || (marker >= 0xd0 && marker <= 0xd7)) {
      offset += 2;
      continue;
    }

    if (offset + 4 >= bytes.length) {
      return null;
    }

    const segmentLength = readUint16Be(bytes, offset + 2);
    if (segmentLength < 2 || offset + 2 + segmentLength > bytes.length) {
      return null;
    }

    if (isJpegSofMarker(marker)) {
      const height = readUint16Be(bytes, offset + 5);
      const width = readUint16Be(bytes, offset + 7);
      if (width > 0 && height > 0) {
        return { width, height };
      }
      return null;
    }

    offset += 2 + segmentLength;
  }

  return null;
}

function isJpegSofMarker(marker) {
  return [
    0xc0,
    0xc1,
    0xc2,
    0xc3,
    0xc5,
    0xc6,
    0xc7,
    0xc9,
    0xca,
    0xcb,
    0xcd,
    0xce,
    0xcf,
  ].includes(marker);
}

function readUint16Be(bytes, offset) {
  return (bytes[offset] << 8) | bytes[offset + 1];
}

function readUint16Le(bytes, offset) {
  return bytes[offset] | (bytes[offset + 1] << 8);
}

function readUint24Le(bytes, offset) {
  return bytes[offset] | (bytes[offset + 1] << 8) | (bytes[offset + 2] << 16);
}

function readUint32Be(bytes, offset) {
  return (
    ((bytes[offset] << 24) >>> 0) |
    (bytes[offset + 1] << 16) |
    (bytes[offset + 2] << 8) |
    bytes[offset + 3]
  );
}

function readInt32Le(bytes, offset) {
  return (
    bytes[offset] |
    (bytes[offset + 1] << 8) |
    (bytes[offset + 2] << 16) |
    (bytes[offset + 3] << 24)
  );
}
