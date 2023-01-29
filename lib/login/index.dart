import 'package:flutter/material.dart';
import 'package:genshin_wish_analysis/login/desktop_login.dart';
import 'package:universal_platform/universal_platform.dart';

import 'cookie_entity.dart';

/// 登录米游设获取cookie
Future<CookieEntity?> loginGetCookie(
  BuildContext context, {
  String? username,
  String? password,
}) async {
  if (UniversalPlatform.isDesktop) {
    return await Navigator.of(context).push<CookieEntity>(MaterialPageRoute(
      builder: (context) {
        return DesktopLoginPage(
          username: username,
          password: password,
        );
      },
    ));
  }
  if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
    throw UnimplementedError();
  }
  throw UnimplementedError();
}
