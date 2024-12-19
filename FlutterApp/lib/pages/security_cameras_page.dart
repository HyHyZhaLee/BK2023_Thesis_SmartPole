import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'dart:html' as html;

class SecurityCamerasPage extends StatelessWidget {
  const SecurityCamerasPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String viewType = 'twitch-player';
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final iframe = html.IFrameElement()
        ..src = 'https://player.twitch.tv/?channel=duyvtvnpro&parent=localhost'
        ..style.border = 'none'
        ..width = '100%'
        ..height = '100%';

      return iframe;
    });

    return Scaffold(
      body: Center(
        child: HtmlElementView(viewType: viewType),
      ),
    );
  }
}
