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


String formatMessageTime(DateTime time) {
  final now = DateTime.now();

  final diff = now.difference(time);
  final oneDay = Duration(days: 1);
  final oneMonth = Duration(days: 30);
  final oneYear = Duration(days: 365);

  // 超过 1 年 → 显示年-月-日 时:分
  if (diff > oneYear) {
    return "${time.year}-${time.month.toString().padLeft(2,'0')}-${time.day.toString().padLeft(2,'0')} "
        "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
  }

  // 超过 1 个月 → 显示 月-日 时:分
  if (diff > oneMonth) {
    return "${time.month.toString().padLeft(2,'0')}-${time.day.toString().padLeft(2,'0')} "
        "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
  }

  // 超过 1 天 → 显示 月-日 时:分
  if (diff > oneDay) {
    return "${time.month.toString().padLeft(2,'0')}-${time.day.toString().padLeft(2,'0')} "
        "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
  }

  // 同一天 → 只显示时间
  return "${time.hour.toString().padLeft(2,'0')}:${time.minute.toString().padLeft(2,'0')}";
}