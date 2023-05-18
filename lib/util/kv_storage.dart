import 'dart:convert';
import 'dart:io';

abstract class KvStorage {
  void set<T>(String key, T? value);
  T? get<T>(String key);
  List<String> getKeys();
  void clear();
}

class KvStorageMapImpl implements KvStorage {
  final Map<String, dynamic> data;

  KvStorageMapImpl({this.data = const {}});
  @override
  void set<T>(String key, T? value) {
    if (value == null) {
      data.remove(key);
      return;
    } else {
      data[key] = value;
    }
  }

  @override
  T? get<T>(String key) {
    return data[key] as T?;
  }

  @override
  void clear() {
    data.clear();
  }

  @override
  List<String> getKeys() {
    return data.keys.toList();
  }
}

class KvStorageWithListener extends KvStorage {
  final KvStorage source;
  final void Function(
    String key,
    dynamic value,
    void Function(String key, dynamic value) handle,
  )? onSet;

  final dynamic Function(
    String key,
    dynamic Function(String key) handle,
  )? onGet;

  final void Function(
    void Function() handle,
  )? onClear;

  final List<String> Function(
    List<String> Function() handle,
  )? onGetKeys;

  KvStorageWithListener({
    required this.source,
    this.onSet,
    this.onGet,
    this.onClear,
    this.onGetKeys,
  });

  @override
  void clear() {
    if (onClear != null) {
      onClear!(source.clear);
    } else {
      source.clear();
    }
  }

  @override
  T? get<T>(String key) {
    if (onGet != null) {
      return onGet!(key, source.get);
    } else {
      return source.get(key);
    }
  }

  @override
  void set<T>(String key, T? value) {
    if (onSet != null) {
      onSet!(key, value, source.set);
    } else {
      source.set(key, value);
    }
  }

  @override
  List<String> getKeys() {
    if (onGetKeys != null) {
      return onGetKeys!(source.getKeys);
    } else {
      return source.getKeys();
    }
  }
}

class KvStorageWithNamespace extends KvStorage {
  final KvStorage source;
  final String namespace;

  KvStorageWithNamespace({
    required this.source,
    required this.namespace,
  });

  @override
  void clear() {
    source.clear();
  }

  @override
  T? get<T>(String key) {
    return source.get<T>("$namespace/$key");
  }

  @override
  void set<T>(String key, T? value) {
    source.set("$namespace/$key", value);
  }

  @override
  List<String> getKeys() {
    return source
        .getKeys()
        .where((element) => element.startsWith("$namespace/"))
        .map((e) => e.substring(namespace.length + 1))
        .toList();
  }
}

class KvStorageJsonImpl extends KvStorage {
  final Map<String, dynamic> data = {};
  late final KvStorageMapImpl source = KvStorageMapImpl(data: data);
  final void Function(String json)? onJsonChanged;

  KvStorageJsonImpl({
    this.onJsonChanged,
  });
  @override
  void clear() {
    source.clear();
    onJsonChanged?.call(jsonEncode(data));
  }

  @override
  T? get<T>(String key) {
    return source.get<T>(key);
  }

  @override
  void set<T>(String key, T? value) {
    source.set(key, value);
    onJsonChanged?.call(jsonEncode(data));
  }

  @override
  List<String> getKeys() {
    return source.getKeys();
  }
}

class KvStorageJsonFileImpl extends KvStorageJsonImpl {
  KvStorageJsonFileImpl(File jsonFile)
      : super(onJsonChanged: (json) {
          jsonFile.writeAsStringSync(json);
        });
}
