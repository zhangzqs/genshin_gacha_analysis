import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:genshin_wish_analysis/global.dart';
import 'package:genshin_wish_analysis/page/card/index.dart';
import 'package:genshin_wish_analysis/page/login/index.dart';
import 'package:genshin_wish_analysis/service/gacha_type_enum.dart';
import 'package:genshin_wish_analysis/service/mhy_service.dart';

final _log = GlobalObjects.logger;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> login() async {
    final account = GlobalObjects.kv.account;
    final cookieJar = GlobalObjects.cookieJar;

    final cookieEntity = await loginGetCookie(
      context,
      username: account.username,
      password: account.password,
    );
    await cookieJar.saveFromResponse(
      Uri.https('user.mihoyo.com'),
      cookieEntity!
          .toMap()
          .entries
          .map(
            (e) => Cookie(e.key, e.value)
              ..domain = '.mihoyo.com'
              ..path = '/',
          )
          .toList(),
    );
  }

  Future<void> makeSureLogin() async {
    final service = GlobalObjects.mhyService;
    EasyLoading.show(status: '正在尝试登录');
    try {
      await service.loginByCookie();
      EasyLoading.showSuccess('登录态有效');
    } on AuthException catch (e) {
      EasyLoading.dismiss();
      await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('登录态失效', style: Theme.of(context).textTheme.titleLarge),
                Text(e.message!),
                const SizedBox(height: 20),
                ElevatedButton(
                    onPressed: () async {
                      await login();
                      if (!mounted) return;
                      Navigator.of(context).pop();
                    },
                    child: const Text('转到登录页')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('取消'))
              ],
            ),
          );
        },
      );
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  Future<void> getUrl() async {
    await makeSureLogin();
    final service = GlobalObjects.mhyService;
    try {
      Uri uri = await service.getGachaUrl();
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '成功取得抽卡地址',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextFormField(initialValue: uri.toString()),
                ElevatedButton(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(
                      text: uri.toString(),
                    ));
                    EasyLoading.showSuccess('已成功复制');
                    if (!mounted) return;
                    Navigator.of(context).pop();
                  },
                  child: const Text('复制到剪切板'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('取消'),
                ),
              ],
            ),
          );
        },
      );
    } catch (e) {
      EasyLoading.showError('发生错误：$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('原神祈愿工具'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/setting');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.login),
            title: const Text('登录米哈游账号'),
            onTap: login,
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('查看抽卡记录'),
            onTap: () async {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const GachaHistoryView();
              }));
            },
          ),
          ListTile(
            leading: const Icon(Icons.abc),
            title: const Text('测试本地cookie是否有效'),
            onTap: makeSureLogin,
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('获取祈愿地址'),
            onTap: getUrl,
          )
        ],
      ),
    );
  }
}
