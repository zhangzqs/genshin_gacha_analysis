import 'dart:io';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:genshin_wish_analysis/service/gacha_service.dart';
import 'package:genshin_wish_analysis/service/mhy_service.dart';
import 'package:genshin_wish_analysis/storage/index.dart';
import 'package:genshin_wish_analysis/util/kv_storage.dart';
import 'package:genshin_wish_analysis/util/kv_storage_cookie_jar.dart';
import 'package:logger/logger.dart';

class GlobalObjects {
  static final Dio dio = () {
    final dio = Dio(BaseOptions(
      connectTimeout: 2000,
      sendTimeout: 2000,
      receiveTimeout: 2000,
    ));
    dio.interceptors.add(CookieManager(cookieJar));
    return dio;
  }();
  static final CookieJar cookieJar = PersistCookieJar(
    storage: KvStorageCookieJar(
      KvStorageWithNamespace(
        source: kv,
        namespace: "cookie",
      ),
    ),
  );
  static final KvStorage kv = KvStorageJsonFileImpl(File("kv.json"));
  static final AppKvStorage appData = AppKvStorage(kv);
  static final MHYService mhyService = MHYService(
    dio: dio,
    cookieJar: cookieJar,
  );
  static final GachaService gachaService = GachaService(dio);
  static final Logger logger = Logger(printer: PrettyPrinter());
}
