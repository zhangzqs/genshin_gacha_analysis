import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'cookie_entity.dart';

class MobileLoginPage extends StatefulWidget {
  final String? username;
  final String? password;

  const MobileLoginPage({super.key, this.username, this.password});

  @override
  State<MobileLoginPage> createState() => _MobileLoginPageState();
}

class _MobileLoginPageState extends State<MobileLoginPage> {
  final _controller = WebViewController();

  String _title = '登录';

  @override
  void initState() {
    super.initState();
    _controller
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) async {
            _title = await _controller.getTitle() ?? '登录';
            setState(() {});
          },
        ),
      )
      // ..enableZoom(true)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.https('user.mihoyo.com'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
      ),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: WebViewWidget(
                controller: _controller,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () async {
                    // 切换密码登录
                    await _controller.runJavaScript(
                        "document.getElementsByClassName('tab-item')[1].click();");
                    // 勾选协议
                    await _controller.runJavaScript(
                        "document.getElementsByClassName('box-container')[0].click();");

                    // 输入用户名
                    await _controller.runJavaScript("""
      const username = document.querySelector("#root > div > div.mhy-verify-container > div > form > div:nth-child(1) > div > input[type=text]");
      username.value='${widget.username}';
      username.dispatchEvent(new Event('input'));
      """);
                    // 输入密码
                    await _controller.runJavaScript("""
      const password = document.querySelector("#root > div > div.mhy-verify-container > div > form > div:nth-child(2) > div > input[type=password]");
      password.value = '${widget.password}';
      password.dispatchEvent(new Event('input'));
      """);
                    // 点击提交
                    await _controller.runJavaScript(
                        "document.querySelector('#root > div > div.mhy-verify-container > div > form > div.mhy-button.login-btn.is-block > button').click()");
                  },
                  child: const Text('快速登录'),
                ),
                TextButton(
                  onPressed: () async {
                    final cookie = await _controller
                        .runJavaScriptReturningResult('document.cookie');
                    final cs = cookie.toString();
                    final ce = CookieEntity.fromCookieString(
                      cs.substring(1, cs.length - 1),
                    );
                    print('原cookie: $cookie');
                    print('获取到cookie: $ce');
                    if (!mounted) return;
                    Navigator.of(context).pop(ce);
                  },
                  child: const Text('获取Cookie'),
                ),
                TextButton(
                  onPressed: () {
                    _controller.loadRequest(
                      Uri.parse('https://user.mihoyo.com/'),
                    );
                  },
                  child: const Text('刷新'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
