import 'package:cookie_jar/cookie_jar.dart';
import 'kv_storage.dart';

class KvStorageCookieJar implements Storage {
  final KvStorage kvStorage;

  const KvStorageCookieJar(this.kvStorage);

  @override
  Future<void> init(bool persistSession, bool ignoreExpires) async {}

  @override
  Future<void> write(String key, String value) async =>
      kvStorage.set(key, value);

  @override
  Future<String?> read(String key) async => kvStorage.get(key);

  @override
  Future<void> delete(String key) async => kvStorage.set(key, null);

  @override
  Future<void> deleteAll(List<String> keys) async => kvStorage.clear();
}
