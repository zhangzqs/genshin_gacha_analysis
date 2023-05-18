import 'package:genshin_wish_analysis/util/kv_storage.dart';

import 'account.dart';

class AppKvStorage {
  final KvStorage kvStorage;
  late final AccountStorage account = AccountStorage(KvStorageWithNamespace(
    source: kvStorage,
    namespace: 'account',
  ));
  AppKvStorage(this.kvStorage);
}
