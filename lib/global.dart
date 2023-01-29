import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:genshin_wish_analysis/service/mhy_service.dart';
import 'package:genshin_wish_analysis/storage/index.dart';
import 'package:genshin_wish_analysis/util/hive_cookie_jar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

class GlobalObjects {
  static late final Dio dio;
  static late final CookieJar cookieJar;
  static late final KvStorage kv;
  static late final MHYService mhyService;

  static late final Logger logger;

  static Future<void> init() async {
    dio = Dio(BaseOptions(
      connectTimeout: 2000,
      sendTimeout: 2000,
      receiveTimeout: 2000,
    ));

    await Hive.initFlutter('hive_boxes');

    cookieJar = PersistCookieJar(
      storage: HiveCookieJar(await Hive.openBox('cookie')),
    );

    dio.interceptors.add(CookieManager(cookieJar));

    kv = KvStorage(await Hive.openBox('kv'));

    mhyService = MHYService(dio: dio, cookieJar: cookieJar);

    logger = Logger(printer: PrettyPrinter());
  }
}
