import 'dart:ui_web' as ui_web;

import 'package:flutter/widgets.dart';
import 'package:web/web.dart' as web;

final _registered = <String>{};

/// Shows [url] in the page (for example a PDF in the browser's viewer).
Widget embeddedFrame(String url) {
  final viewType = 'serverpod-admin-frame-${Uri.encodeComponent(url)}';
  if (_registered.add(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int _) {
      return web.HTMLIFrameElement()
        ..src = url
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%';
    });
  }
  return HtmlElementView(viewType: viewType);
}
