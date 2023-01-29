import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'cookie_entity.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class DesktopLoginPage extends StatefulWidget {
  // 待自动填充的用户名与密码
  final String? username;
  final String? password;

  const DesktopLoginPage({
    Key? key,
    this.username,
    this.password,
  }) : super(key: key);

  @override
  State<DesktopLoginPage> createState() => _DesktopLoginPageState();
}

class _DesktopLoginPageState extends State<DesktopLoginPage> {
  Webview? webview;
  Future<String> _getWebViewPath() async {
    final document = await getApplicationDocumentsDirectory();
    final path = p.join(document.path, 'desktop_webview_window');
    print('userDataPath: $path');
    return path;
  }

  @override
  void dispose() {
    webview?.close();
    webview = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('米哈游登录')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              TextButton(
                onPressed: () async {
                  if (webview != null) return;

                  webview = await WebviewWindow.create(
                    configuration: CreateConfiguration(
                      title: '登录对话框',
                      titleBarHeight: 40,
                      titleBarTopPadding: 20,
                      userDataFolderWindows: await _getWebViewPath(),
                    ),
                  );
                  webview!
                    ..launch('https://user.mihoyo.com')
                    ..onClose.whenComplete(() {
                      webview = null;
                    });
                },
                child: const Text('打开浏览器登录窗口'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () async {
                  if (webview == null) return;
                  final cookie =
                      await webview!.evaluateJavaScript('document.cookie');

                  if (cookie == null) {
                    return;
                  }
                  final ce = CookieEntity.fromCookieString(cookie);
                  if (!mounted) return;
                  Navigator.of(context).pop(ce);
                },
                child: const Text('获取登录Cookie'),
              ),
              TextButton(
                onPressed: () async {
                  // 切换密码登录
                  await webview?.evaluateJavaScript(
                      "document.getElementsByClassName('tab-item')[1].click();");
                  // 勾选协议
                  await webview?.evaluateJavaScript(
                      "document.getElementsByClassName('box-container')[0].click();");

                  // 输入用户名
                  await webview?.evaluateJavaScript("""
const username = document.querySelector("#root > div > div.mhy-verify-container > div > form > div:nth-child(1) > div > input[type=text]");
username.value='${widget.username}';
username.dispatchEvent(new Event('input'));
""");
                  // 输入密码
                  await webview?.evaluateJavaScript("""
const password = document.querySelector("#root > div > div.mhy-verify-container > div > form > div:nth-child(2) > div > input[type=password]");
password.value = '${widget.password}';
password.dispatchEvent(new Event('input'));
""");
                  // 点击提交
                  await webview?.evaluateJavaScript(
                      "document.querySelector('#root > div > div.mhy-verify-container > div > form > div.mhy-button.login-btn.is-block > button').click()");
                },
                child: const Text('自动快速填充'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
