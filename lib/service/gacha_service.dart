import 'package:dio/dio.dart';
import 'package:genshin_wish_analysis/service/gacha_type_enum.dart';
import 'package:intl/intl.dart';

enum GachaResultItemType {
  character,
  weapon;

  const GachaResultItemType();

  @override
  String toString() {
    switch (this) {
      case GachaResultItemType.character:
        return '角色';
      case GachaResultItemType.weapon:
        return '武器';
    }
  }

  factory GachaResultItemType.fromString(String text) {
    switch (text) {
      case '角色':
        return GachaResultItemType.character;
      case '武器':
        return GachaResultItemType.weapon;
      default:
        throw UnsupportedError(text);
    }
  }
}

class GachaRecordEntity {
  /// 抽卡用户
  final String uid;

  /// 卡池
  final GachaType gachaType;

  /// 物品类型
  final GachaResultItemType type;

  /// 记录id
  final String id;

  /// 物品名称
  final String name;

  /// 数量
  final int count;

  /// 时间
  final DateTime time;

  /// 星级
  final int rank;

  GachaRecordEntity({
    required this.uid,
    required this.gachaType,
    required this.type,
    required this.id,
    required this.name,
    required this.count,
    required this.time,
    required this.rank,
  });

  factory GachaRecordEntity.fromGachaUrlResponseJson(
      Map<String, dynamic> json) {
    return GachaRecordEntity(
      uid: json['uid']!,
      gachaType: GachaType.fromId(int.parse(json['gacha_type']!)),
      type: GachaResultItemType.fromString(json['item_type']!),
      id: json['id']!,
      name: json['name'],
      count: int.parse(json['count']!),
      time: DateTime.parse(json['time']!),
      rank: int.parse(json['rank_type']),
    );
  }

  Map<String, String> toJson() {
    return {
      'uid': uid,
      'gacha_type': gachaType.gachaTypeId.toString(),
      'count': count.toString(),
      'time': DateFormat('yyyy-MM-dd HH:mm:ss').format(time),
      'name': name,
      'item_type': type.toString(),
      'rank_type': rank.toString(),
    };
  }

  @override
  String toString() {
    return toJson().toString();
  }
}

class GachaService {
  final Dio dio;
  GachaService(this.dio);

  Future<List<GachaRecordEntity>> fetch(Uri uri) async {
    final response = await dio.getUri<Map<String, dynamic>>(uri);
    return (response.data!['data']['list'] as List)
        .map(
          (e) => GachaRecordEntity.fromGachaUrlResponseJson(e),
        )
        .toList();
  }
}
