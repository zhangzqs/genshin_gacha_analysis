enum GachaType {
  /// 限时角色池
  limitedTimeCharacter(gachaTypeId: 301, description: '角色活动祈愿'),

  /// 限时武器池
  limitedTimeWeapon(gachaTypeId: 302, description: '武器活动祈愿'),

  /// 常驻池
  permanent(gachaTypeId: 200, description: '常驻祈愿'),

  /// 新手池
  novice(gachaTypeId: 100, description: '新手祈愿');

  const GachaType({
    required this.gachaTypeId,
    required this.description,
  });

  final int gachaTypeId;
  final String description;

  factory GachaType.fromId(int id) {
    return {
      301: GachaType.limitedTimeCharacter,
      302: GachaType.limitedTimeWeapon,
      200: GachaType.permanent,
      100: GachaType.novice,
    }[id]!;
  }
}
