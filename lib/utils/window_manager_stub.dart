Future<void> initWindowManager() async {
  // 移动端不做任何操作
}

Future<void> showWindow() async {}
Future<void> closeWindow() async {}
Future<void> maximizeWindow() async {}
Future<void> minimizeWindow() async {}
Future<void> unmaximizeWindow() async {}
Future<bool> isWindowMaximized() async => false;