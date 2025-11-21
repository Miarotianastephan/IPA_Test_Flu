import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindowManager() async {
  if (!Platform.isWindows && !Platform.isLinux && !Platform.isMacOS) {
    // 移动端直接返回
    return;
  }

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(900, 600),
    center: true,
    title: "Bogo",
    backgroundColor: Colors.transparent,
    titleBarStyle: TitleBarStyle.hidden, // 隐藏系统标题栏
  );

  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(const Size(400, 600));
    await windowManager.show();
    await windowManager.focus();
  });
}

Future<void> showWindow() async => windowManager.show();

Future<void> closeWindow() async => windowManager.close();

Future<void> maximizeWindow() async => windowManager.maximize();

Future<void> minimizeWindow() async => windowManager.minimize();

Future<void> unmaximizeWindow() async => windowManager.unmaximize();

Future<bool> isWindowMaximized() async => windowManager.isMaximized();
