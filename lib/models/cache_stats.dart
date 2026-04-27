class CacheStats {
  final int count;
  final int totalSize;
  final String formattedSize;

  const CacheStats({
    required this.count,
    required this.totalSize,
    required this.formattedSize,
  });

  factory CacheStats.empty() {
    return const CacheStats(count: 0, totalSize: 0, formattedSize: '0 B');
  }

  @override
  String toString() {
    return 'CacheStats(count: $count, totalSize: $totalSize, formattedSize: $formattedSize)';
  }
}
