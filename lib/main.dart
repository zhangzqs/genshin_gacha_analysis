import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:genshin_wish_analysis/app.dart';
import 'package:genshin_wish_analysis/global.dart';
import 'package:universal_platform/universal_platform.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  if (UniversalPlatform.isDesktop && runWebViewTitleBarWidget(args)) return;
  await GlobalObjects.init();

  runApp(const GenshinWishAnalysisApp());
}
