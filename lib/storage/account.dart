import 'package:hive_flutter/hive_flutter.dart';

class AccountStorage {
  static const _keyNamespace = '/account';
  static const usernameKey = '$_keyNamespace/username';
  static const passwordKey = '$_keyNamespace/password';

  final Box box;
  const AccountStorage(this.box);

  String? get username => box.get(usernameKey);
  String? get password => box.get(passwordKey);

  set username(String? v) => box.put(usernameKey, v);
  set password(String? v) => box.put(passwordKey, v);
}
