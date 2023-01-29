class CookieEntity {
  String? mhyUUID;
  String? loginTicket;
  String? loginUid;
  String? devicefpSeedId;
  String? devicefpSeedTime;

  CookieEntity();

  factory CookieEntity.fromCookieString(String cookie) {
    final map = Map.fromEntries(cookie.split('; ').map((e) {
      final kv = e.split('=');
      return MapEntry(kv[0], kv[1]);
    }));
    return CookieEntity()
      ..mhyUUID = map['_MHYUUID']
      ..loginTicket = map['login_ticket']
      ..loginUid = map['login_uid']
      ..devicefpSeedId = map['DEVICEFP_SEED_ID']
      ..devicefpSeedTime = map['DEVICEFP_SEED_TIME'];
  }

  Map<String, String> toMap() {
    return {
      if (mhyUUID != null) '_MHYUUID': mhyUUID!,
      if (loginTicket != null) 'login_ticket': loginTicket!,
      if (loginUid != null) 'login_uid': loginUid!,
      if (devicefpSeedId != null) 'DEVICEFP_SEED_ID': devicefpSeedId!,
      if (devicefpSeedTime != null) 'DEVICEFP_SEED_TIME': devicefpSeedTime!,
    };
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
