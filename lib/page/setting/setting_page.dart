import 'package:flutter/material.dart';
import 'package:genshin_wish_analysis/global.dart';

Future<String?> inputText(
  BuildContext context, {
  String? title = '请输入',
  String initialValue = '',
}) async {
  final controller = TextEditingController()..text = initialValue;
  return await showDialog<String>(
    context: context,
    builder: (context) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title != null)
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              TextFormField(
                controller: controller,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(controller.text);
                },
                child: const Text('确认修改'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              )
            ],
          ),
        ),
      );
    },
  );
}

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final account = GlobalObjects.kv.account;

  String? username;
  String? password;

  @override
  void initState() {
    super.initState();
    username = account.username;
    password = account.password;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.restore),
            )
          ],
        ),
        body: ListView(
          children: [
            ListTile(
              title: const Text('账号'),
              subtitle: Text(username != null ? username! : '未设置'),
              onTap: () async {
                final newUsername = await inputText(
                  context,
                  title: '设置账号',
                  initialValue: username != null ? username! : '',
                );
                if (newUsername == null) return;
                setState(() {
                  account.username =
                      username = newUsername.isEmpty ? null : newUsername;
                });
              },
            ),
            ListTile(
              title: const Text('密码'),
              subtitle: Text(password != null ? password! : '未设置'),
              onTap: () async {
                final newPassword = await inputText(
                  context,
                  title: '设置密码',
                  initialValue: password != null ? password! : '',
                );
                if (newPassword == null) return;
                setState(() {
                  account.password =
                      password = newPassword.isEmpty ? null : newPassword;
                });
              },
            )
          ],
        ));
  }
}
