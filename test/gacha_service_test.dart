import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genshin_wish_analysis/global.dart';
import 'package:genshin_wish_analysis/service/gacha_type_enum.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalObjects.init();
  final mhy = GlobalObjects.mhyService;
  final gacha = GlobalObjects.gachaService;
  final log = GlobalObjects.logger;
  test('test fetch gacha list', () async {
    final uri = await mhy.getGachaUrl(
      gachaType: GachaType.limitedTimeCharacter,
    );
    log.d(uri);
    final list = await gacha.fetch(uri);
    log.d(list);
  });
}
