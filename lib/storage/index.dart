import 'package:hive_flutter/hive_flutter.dart';

import 'account.dart';

class KvStorage {
  final AccountStorage account;
  KvStorage(Box box) : account = AccountStorage(box);
}
