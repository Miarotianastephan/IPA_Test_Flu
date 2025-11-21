String formatDuration(int seconds) {
  final int hours = seconds ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  final int secs = seconds % 60;

  String twoDigits(int n) => n.toString().padLeft(2, '0');

  if (hours > 0) {
    return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(secs)}';
  } else {
    return '${twoDigits(minutes)}:${twoDigits(secs)}';
  }
}