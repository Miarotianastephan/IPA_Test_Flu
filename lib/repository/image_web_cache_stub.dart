import 'dart:typed_data';

class ImageWebCache {
  Future<void> init() async {}
  Future<Uint8List?> get(String url) async => null;
  Future<void> put(String url, Uint8List bytes) async {}
  Future<void> clear() async {}
  Future<int> getCount() async => 0;
}
