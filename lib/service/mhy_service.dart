import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:genshin_wish_analysis/global.dart';

import 'gacha_type_enum.dart';

late final _log = GlobalObjects.logger;

class LoginByCookieResponse {
  String accountId;
  String webLoginToken;

  LoginByCookieResponse({
    required this.accountId,
    required this.webLoginToken,
  });
}

class GetUserGameRolesByCookieResponseItem {
  String gameBiz;
  String region;
  String gameUid;

  GetUserGameRolesByCookieResponseItem({
    required this.gameBiz,
    required this.region,
    required this.gameUid,
  });
}

class AuthException implements Exception {
  final String? message;
  AuthException({this.message});
  @override
  String toString() {
    return 'AuthException{message: $message}';
  }
}

class MHYService {
  final Dio dio;
  final CookieJar cookieJar;

  LoginByCookieResponse? _loginByCookieResponse;
  bool _getMultiTokenByLoginTicketFinished = false;

  Map<String, GetUserGameRolesByCookieResponseItem>?
      _getUserGameRolesByCookieResponse;

  Map<String, String>? _authKeyMap;

  MHYService({
    required this.dio,
    required this.cookieJar,
  });

  /// 尝试使用cookie登录
  Future<LoginByCookieResponse> loginByCookie() async {
    if (_loginByCookieResponse != null) {
      return _loginByCookieResponse!;
    }
    final uri = Uri(
      scheme: "https",
      host: "webapi.account.mihoyo.com",
      path: "/Api/login_by_cookie",
      queryParameters: {
        "t": DateTime.now().millisecondsSinceEpoch.toString(),
      },
    );
    final response = await dio.getUri<Map<String, dynamic>>(uri);

    _log.d(response);

    final code = response.data!['code'];
    if (code == 400) {
      throw AuthException(message: response.data!['data']['msg']);
    } else if (code == 200) {
      if (response.data!['data']['status'] == -263) {
        throw AuthException(message: response.data!['data']['msg']);
      }
    }
    final accountInfo = response.data!['data']['account_info'];

    _loginByCookieResponse = LoginByCookieResponse(
      accountId: accountInfo['account_id'].toString(),
      webLoginToken: accountInfo['weblogin_token'],
    );
    return _loginByCookieResponse!;
  }

  Future<void> _getMultiTokenByLoginTicket() async {
    if (_getMultiTokenByLoginTicketFinished) return;

    if (_loginByCookieResponse == null) await loginByCookie();

    final loginToken = _loginByCookieResponse!;

    final uri = Uri(
      scheme: "https",
      host: "api-takumi.mihoyo.com",
      path: "/auth/api/getMultiTokenByLoginTicket",
      queryParameters: {
        "login_ticket": loginToken.webLoginToken,
        "token_types": '3',
        "uid": loginToken.accountId,
      },
    );
    final response = await dio.getUri<Map<String, dynamic>>(uri);

    _log.d(response);

    final cookies = [
      Cookie('stuid', loginToken.accountId)
        ..domain = '.mihoyo.com'
        ..path = '/',
      ...(response.data!['data']['list'] as List)
          .cast<Map>()
          .map((e) => e.cast<String, String>())
          .map(
            (e) => Cookie(e['name']!, e['token']!)
              ..domain = '.mihoyo.com'
              ..path = '/',
          )
          .toList()
    ];

    await cookieJar.saveFromResponse(
      Uri.https('api-takumi.mihoyo.com'),
      cookies,
    );
    _getMultiTokenByLoginTicketFinished = true;
  }

  /// 获取用户的游戏角色
  Future<Map<String, GetUserGameRolesByCookieResponseItem>>
      getUserGameRolesByCookie() async {
    if (_getUserGameRolesByCookieResponse != null) {
      return _getUserGameRolesByCookieResponse!;
    }
    if (!_getMultiTokenByLoginTicketFinished) {
      await _getMultiTokenByLoginTicket();
    }
    final uri = Uri(
      scheme: "https",
      host: "api-takumi.mihoyo.com",
      path: "/binding/api/getUserGameRolesByCookie",
      queryParameters: {"game_biz": "hk4e_cn"},
    );
    final response = await dio.getUri<Map<String, dynamic>>(uri);
    _log.d(response);
    _getUserGameRolesByCookieResponse = Map.fromEntries(
      (response.data!['data']['list'] as List)
          .map((e) => GetUserGameRolesByCookieResponseItem(
                gameBiz: e['game_biz'],
                region: e['region'],
                gameUid: e['game_uid'],
              ))
          .map((e) => MapEntry(e.gameUid, e)),
    );
    return _getUserGameRolesByCookieResponse!;
  }

  /// 生成签名
  String _genDs() {
    const chars = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678";
    const salt = "ulInCDohgEs557j0VsPDYnQaaz6KJcv5";
    final time = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
    final str = Iterable.generate(6, (i) {
      return chars[Random.secure().nextInt(chars.length)];
    }).join();
    final key = 'salt=$salt&t=$time&r=$str';
    final md5sign = md5.convert(ascii.encode(key)).toString();
    return '$time,$str,$md5sign';
  }

  /// 生成获取authkey字段
  Future<Map<String, String>> _genAuthKey() async {
    if (_authKeyMap != null) return _authKeyMap!;

    if (_getUserGameRolesByCookieResponse == null) {
      await getUserGameRolesByCookie();
    }
    final uri = Uri(
      scheme: "https",
      host: "api-takumi.mihoyo.com",
      path: "/binding/api/genAuthKey",
    );

    _authKeyMap ??= {};

    for (final item in _getUserGameRolesByCookieResponse!.values) {
      final response = await dio.postUri<Map<String, dynamic>>(
        uri,
        data: {
          'auth_appid': 'webview_gacha',
          'game_biz': item.gameBiz,
          'game_uid': item.gameUid,
          'region': item.region,
        },
        options: Options(
          contentType: 'application/json;charset=utf-8',
          headers: {
            "Host": "api-takumi.mihoyo.com",
            "Accept": "application/json, text/plain, */*",
            "x-rpc-app_version": "2.28.1",
            "x-rpc-client_type": "5",
            "x-rpc-device_id": "CBEC8312-AA77-489E-AE8A-8D498DE24E90",
            "DS": _genDs(),
          },
        ),
      );
      _log.d(response);
      _authKeyMap![item.gameUid] = response.data!['data']['authkey'];
    }
    return _authKeyMap!;
  }

  /// 构造抽卡地址
  Future<Uri> getGachaUrl({
    String? gameUid,
    GachaType gachaType = GachaType.permanent,
    int endId = 0,
    int page = 1,
    int size = 20,
    String gameVersion = 'CNRELiOS3.0.0_R10283122_S10446836_D10316937',
  }) async {
    if (_authKeyMap == null) await _genAuthKey();

    gameUid ??= _authKeyMap!.keys.first;

    final role = _getUserGameRolesByCookieResponse![gameUid]!;
    final authKey = _authKeyMap![gameUid];
    final platformType = Platform.isAndroid
        ? 'android'
        : Platform.isIOS
            ? 'ios'
            : 'pc';
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final uri = Uri(
      scheme: "https",
      host: "hk4e-api.mihoyo.com",
      path: "/event/gacha_info/api/getGachaLog",
      queryParameters: {
        "win_mode": "fullscreen",
        "authkey_ver": '1',
        "sign_type": '2',
        "auth_appid": "webview_gacha",
        "init_type": '301',
        "gacha_id": "b4ac24d133739b7b1d55173f30ccf980e0b73fc1",
        "lang": "zh-cn",
        "device_type": platformType == 'pc' ? 'pc' : 'mobile',
        "game_version": gameVersion,
        "plat_type": platformType,
        "game_biz": role.gameBiz,
        "size": size.toString(),
        "authkey": authKey!,
        "region": role.region,
        "timestamp": timestamp.toString(),
        "gacha_type": gachaType.gachaTypeId.toString(),
        "page": page.toString(),
        "end_id": endId.toString(),
      },
    );
    return uri;
  }
}
