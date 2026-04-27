import 'dart:io' as io;
import 'dart:typed_data';

import '../utils/decrypt_utils.dart';
import '../utils/text_util.dart';

class ReadAndDecryptParams {
  final String filePath;
  final String url;
  final String encryptionKey;

  const ReadAndDecryptParams({
    required this.filePath,
    required this.url,
    required this.encryptionKey,
  });
}

Uint8List readAndDecryptFileInBackground(ReadAndDecryptParams params) {
  final bytes = io.File(params.filePath).readAsBytesSync();
  final fileType = getImageFileType(params.url);

  if (fileType == null) {
    throw UnsupportedError(
      'Unsupported file type: ${params.url}. Only .pdf and .enc are allowed.',
    );
  }

  switch (fileType) {
    case ImageFileType.enc:
      return decryptBufferSync(bytes, params.encryptionKey);
    case ImageFileType.pdf:
      return decryptBufferSync(bytes, params.encryptionKey);
  }
}
