import 'package:genshin_wish_analysis/util/kv_storage.dart';

class AccountStorage {
  static const usernameKey = 'username';
  static const passwordKey = 'password';

  final KvStorage kv;
  const AccountStorage(this.kv);

  String? get username => kv.get<String>(usernameKey);
  String? get password => kv.get<String>(passwordKey);

  set username(String? v) => kv.set(usernameKey, v);
  set password(String? v) => kv.set(passwordKey, v);
}
