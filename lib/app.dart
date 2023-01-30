import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'global.dart';
import 'page/home/index.dart';
import 'page/setting/setting_page.dart';

final _log = GlobalObjects.logger;

class GenshinWishAnalysisApp extends StatelessWidget {
  const GenshinWishAnalysisApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GenshinWishAnalysis',
      routes: {
        '/': (ctx) => const HomePage(),
        '/setting': (ctx) => const SettingPage(),
      },
      initialRoute: '/',
      builder: EasyLoading.init(),
    );
  }
}
