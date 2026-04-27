// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

Widget buildGameWebView(String url) {
  final viewType = 'game-iframe-${url.hashCode}';
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allow = 'autoplay; fullscreen; clipboard-write'
      ..setAttribute('allowfullscreen', 'true');
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
